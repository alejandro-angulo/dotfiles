{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.octoprint;
in {
  options.aa.services.octoprint = with types; {
    enable = mkEnableOption "octoprint";
    acmeCertName = mkOption {
      type = str;
      default = "";
      description = ''
        If set to a non-empty string, foces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.octoprint.enable = true;

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."octoprint.kilonull.com" =
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.octoprint.port}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 32m;
            '';
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
