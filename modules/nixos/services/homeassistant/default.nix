{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.${namespace}.services.homeassistant;
  hass_cfg = config.services.home-assistant;
in
{
  options.${namespace}.services.homeassistant = {
    enable = mkEnableOption "home assistant";
    acmeCertName = mkOption {
      type = types.str;
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
      extraPackages =
        python3packages: with python3packages; [
          # postgresql support
          psycopg2

          # homekit support
          hap-python
        ];

      extraComponents = [
        "3_day_blinds"
        "motion_blinds"

        "opower"
        "smud"

        "cast"
        "homekit_controller"
        "hue"
        "met"
        "mqtt"
        "octoprint"
        "roborock"
        "shelly"
        "zeroconf"
      ];

      customComponents = with pkgs.home-assistant-custom-components; [
        adaptive_lighting
      ];

      config = {
        default_config = { };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };

        recorder.db_url = "postgresql://@/hass";

        "automation ui" = "!include automations.yaml";
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
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
