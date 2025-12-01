{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aa.services.nextcloud;
  secrets = config.age.secrets;

  mkNextcloudSecret = attrs: {
    name = attrs.name;
    value = {
      file = attrs.path;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
in
{
  options.aa.services.nextcloud = with lib; {
    enable = mkEnableOption "nextcloud";
    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = builtins.listToAttrs (
      builtins.map (attrs: mkNextcloudSecret attrs) [
        {
          name = "restic/password";
          path = ../../../../secrets/nextcloud_restic_password.age;
        }
        {
          name = "restic/env";
          path = ../../../../secrets/nextcloud_restic_env.age;
        }
        {
          name = "restic/repo";
          path = ../../../../secrets/nextcloud_restic_repo.age;
        }
        {
          name = "nextcloud_admin";
          path = ../../../../secrets/nextcloud_admin.age;
        }
      ]
    );

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      hostName = "nextcloud.kilonull.com";
      https = true;
      database.createLocally = true;
      datadir = "/tank/nextcloud";
      # Arbitrary large size
      maxUploadSize = "16G";
      configureRedis = true;
      settings.log_type = "file";
      poolSettings = {
        pm = "dynamic";
        "pm.max_children" = "64";
        "pm.max_requests" = "500";
        "pm.max_spare_servers" = "25";
        "pm.min_spare_servers" = "10";
        "pm.start_servers" = "15";
      };
      config = {
        dbtype = "pgsql";
        adminuser = "alejandro";
        adminpassFile = secrets.nextcloud_admin.path;
      };
    };

    # nextcloud module configures nginx, just need to specify SSL stuffs here
    services.nginx.virtualHosts.${config.services.nextcloud.hostName} =
      lib.mkIf (cfg.acmeCertName != "")
        {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };

    services.restic.backups = {
      nextcloud = {
        user = "nextcloud";
        initialize = true;
        paths = [ config.services.nextcloud.datadir ];
        environmentFile = secrets."restic/env".path;
        repositoryFile = secrets."restic/repo".path;
        passwordFile = secrets."restic/password".path;
        timerConfig = {
          OnCalendar = "00:05";
          Persistent = true;
          RandomizedDelaySec = "5h";
        };
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 9001"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
