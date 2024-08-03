{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;

  cfg = config.${namespace}.services.gitea;
  gitea_cfg = config.services.gitea;
in {
  options.${namespace}.services.gitea = {
    enable = mkEnableOption "gitea";
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
    services.gitea = {
      enable = true;
      appName = "Internal Gitea server";
      database = {
        type = "postgres";
      };

      useWizard = false;

      settings = {
        server = {
          DOMAIN = "gitea.kilonull.com";
          ROOT_URL = "https://gitea.kilonull.com";
          HTTP_PORT = 3001;
        };

        session.COOKIE_SECURE = true;
        service.DISABLE_REGISTRATION = true;
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."gitea.kilonull.com" =
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString gitea_cfg.settings.server.HTTP_PORT}";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };
  };
}
