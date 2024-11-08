{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aa.services.nextcloud;
in {
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
    age.secrets.nextcloud_admin = {
      file = ../../../../secrets/nextcloud_admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
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
        adminpassFile = config.age.secrets.nextcloud_admin.path;
      };
    };

    # nextcloud module configures nginx, just need to specify SSL stuffs here
    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = lib.mkIf (cfg.acmeCertName != "") {
      forceSSL = true;
      useACMEHost = cfg.acmeCertName;
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
