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
  anubis_cfg = config.services.anubis.instances.forgejo;
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

    anubis.enable = mkEnableOption "anubis protection";
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

    services.anubis = lib.mkIf cfg.anubis.enable {
      instances.forgejo = {
        enable = true;
        # NOTE: Is this needed?
        user = config.services.nginx.user;
        settings = {
          TARGET = "http://127.0.0.1:${toString (forgejo_cfg.settings.server.HTTP_PORT - 1)}";
        };
      };
    };

    # Give nginx access to anubis socket
    users.users.nginx.extraGroups = lib.mkIf cfg.anubis.enable [ config.users.groups.anubis.name ];

    services.nginx =
      if cfg.anubis.enable then
        {
          enable = true;
          upstreams.anubis.servers."unix:${anubis_cfg.settings.BIND}" = { };

          virtualHosts."${cfg.domain}" = {
            forceSSL = true; # Creates SSL listener on 443 + HTTP redirect on 80
            enableACME = true;

            # http2 on; equivalent
            http2 = true;
            locations."/" = {
              proxyPass = "http://anubis";
              recommendedProxySettings = true;
            };
          };

          virtualHosts."${cfg.domain}-backend" = {
            # I need to listen but not sure what to listen on
            listen = [
              {
                addr = "127.0.0.1";
                port = (forgejo_cfg.settings.server.HTTP_PORT - 1);
              }
            ];

            extraConfig = ''
              port_in_redirect off;
            '';

            locations."/".proxyPass = "http://127.0.0.1:${toString forgejo_cfg.settings.server.HTTP_PORT}";
            locations."= /".return = "301 /explore/repos";
          };
        }
      else
        {
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
