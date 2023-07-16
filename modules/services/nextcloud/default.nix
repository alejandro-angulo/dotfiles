{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.nextcloud;
in {
  options.aa.services.nextcloud = with types; {
    enable = mkEnableOption "nextcloud";
  };

  config = mkIf cfg.enable {
    age.secrets.nextcloud_admin = {
      file = ../../../secrets/nextcloud_admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      hostName = "nextcloud.kilonull.com";
      https = true;
      database.createLocally = true;
      datadir = "/tank/nextcloud";
      # Arbitrary large size
      maxUploadSize = "16G";
      configureRedis = true;
      logType = "file";
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
    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      useACMEHost = "kilonull.com";
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
