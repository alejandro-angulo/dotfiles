{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aa.services.nextcloud;

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
      map (attrs: mkNextcloudSecret attrs) [
        {
          name = "restic/nextcloud-password";
          path = ../../../../secrets/nextcloud_restic_password.age;
        }
        {
          name = "restic/nextcloud-env";
          path = ../../../../secrets/nextcloud_restic_env.age;
        }
        {
          name = "restic/nextcloud-repo";
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
      package = pkgs.nextcloud35;
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
      };
      # NOTE: `services.nextcloud.config.adminuser`/`adminpassFile` were removed
      # from the NixOS module (they only affected initial installation). The
      # admin credential is still deployed as `age.secrets.nextcloud_admin`.
      # On a fresh install, create the admin user manually:
      #   nextcloud-occ user:add alejandro --password-from-env
      #   nextcloud-occ group:adduser admin alejandro
    };

    # nextcloud module configures nginx, just need to specify SSL stuffs here
    services.nginx.virtualHosts.${config.services.nextcloud.hostName} =
      lib.mkIf (cfg.acmeCertName != "")
        {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };

    aa.services.restic.jobs.nextcloud = {
      user = "nextcloud";
      paths = [ config.services.nextcloud.datadir ];
      repositoryAgeSecret = "restic/nextcloud-repo";
      passwordAgeSecret = "restic/nextcloud-password";
      environmentAgeSecret = "restic/nextcloud-env";
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
