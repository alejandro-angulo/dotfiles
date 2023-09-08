{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.prometheus;
  exporters = config.services.prometheus.exporters;
in {
  options.aa.services.prometheus = with types; {
    enable = mkEnableOption "prometheus";
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
    services.prometheus = {
      enable = true;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };
      scrapeConfigs = [
        {
          job_name = "foo";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString exporters.node.port}"];
            }
          ];
        }
      ];
    };

    services.nginx = {
      enable = true;
      virtualHosts."prometheus.${cfg.acmeCertName}" =
        {
          locations."/" = {
            proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
