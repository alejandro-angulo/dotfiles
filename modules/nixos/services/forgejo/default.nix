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

  cfg = config.${namespace}.services.forgejo;
  forgejo_cfg = config.services.forgejo;
in
{
  options.${namespace}.services.forgejo = {
    enable = mkEnableOption "forgejo";
    domain = mkOption {
      type = types.str;
      description = ''
        The domain name to use for this instance
      '';
    };
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
    catppuccin.forgejo.enable = true;

    services.forgejo = {
      enable = true;
      database = {
        type = "sqlite3";
      };

      useWizard = false;

      settings = {
        server = {
          DOMAIN = cfg.domain;
          ROOT_URL = "https://${cfg.domain}";
          HTTP_PORT = 3001;
        };

        session.COOKIE_SECURE = true;
        service.DISABLE_REGISTRATION = true;

        # webhook.ALLOWED_HOST_LIST = "hydra.kilonull.com";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString forgejo_cfg.settings.server.HTTP_PORT}";
        };
        locations."= /" = {
          return = "301 /explore/repos";
        };
      }
      // lib.optionalAttrs (cfg.acmeCertName != "") {
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };
  };
}
