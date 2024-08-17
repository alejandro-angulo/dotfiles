{
  config,
  lib,
  pkgs,
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

        webhook.ALLOWED_HOST_LIST = "hydra.kilonull.com";

        ui.THEMES = ''
          catppuccin-latte-rosewater,catppuccin-latte-flamingo,catppuccin-latte-pink,catppuccin-latte-mauve,catppuccin-latte-red,catppuccin-latte-maroon,catppuccin-latte-peach,catppuccin-latte-yellow,catppuccin-latte-green,catppuccin-latte-teal,catppuccin-latte-sky,catppuccin-latte-sapphire,catppuccin-latte-blue,catppuccin-latte-lavender,catppuccin-frappe-rosewater,catppuccin-frappe-flamingo,catppuccin-frappe-pink,catppuccin-frappe-mauve,catppuccin-frappe-red,catppuccin-frappe-maroon,catppuccin-frappe-peach,catppuccin-frappe-yellow,catppuccin-frappe-green,catppuccin-frappe-teal,catppuccin-frappe-sky,catppuccin-frappe-sapphire,catppuccin-frappe-blue,catppuccin-frappe-lavender,catppuccin-macchiato-rosewater,catppuccin-macchiato-flamingo,catppuccin-macchiato-pink,catppuccin-macchiato-mauve,catppuccin-macchiato-red,catppuccin-macchiato-maroon,catppuccin-macchiato-peach,catppuccin-macchiato-yellow,catppuccin-macchiato-green,catppuccin-macchiato-teal,catppuccin-macchiato-sky,catppuccin-macchiato-sapphire,catppuccin-macchiato-blue,catppuccin-macchiato-lavender,catppuccin-mocha-rosewater,catppuccin-mocha-flamingo,catppuccin-mocha-pink,catppuccin-mocha-mauve,catppuccin-mocha-red,catppuccin-mocha-maroon,catppuccin-mocha-peach,catppuccin-mocha-yellow,catppuccin-mocha-green,catppuccin-mocha-teal,catppuccin-mocha-sky,catppuccin-mocha-sapphire,catppuccin-mocha-blue,catppuccin-mocha-lavender
        '';
      };
    };

    systemd.tmpfiles.rules = [
      "d '${gitea_cfg.customDir}/public' 0750 ${gitea_cfg.user} ${gitea_cfg.group} - -"
      "z '${gitea_cfg.customDir}/public' 0750 ${gitea_cfg.user} ${gitea_cfg.group} - -"
      "d '${gitea_cfg.customDir}/public/assets' 0750 ${gitea_cfg.user} ${gitea_cfg.group} - -"
      "z '${gitea_cfg.customDir}/public/assets' 0750 ${gitea_cfg.user} ${gitea_cfg.group} - -"
      "L+ '${gitea_cfg.customDir}/public/assets/css' - - - - ${pkgs.aa.catppuccin-gitea}/share/gitea-themes"
    ];

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
