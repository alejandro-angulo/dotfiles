{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.homeassistant;
  hass_cfg = config.services.home-assistant;
in {
  options.aa.services.homeassistant = with types; {
    enable = mkEnableOption "home assistant";
    acmeCertName = mkOption {
      type = str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      extraPackages = python3packages:
        with python3packages; [
          # postgresql support
          psycopg2
        ];
      extraComponents = [
        "hue"
        "tuya"
        "vizio"
        "zeroconf"
      ];
      config = {
        default_config = {};
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1"];
        };

        recorder.db_url = "postgresql://@/hass";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."hass.kilonull.com" =
        {
          locations."/" = {
            recommendedProxySettings = true;
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:${toString hass_cfg.config.http.server_port}";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    services.postgresql = {
      ensureDatabases = ["hass"];
      ensureUsers = [
        {
          name = "hass";
          ensurePermissions = {
            "DATABASE hass" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };
}
