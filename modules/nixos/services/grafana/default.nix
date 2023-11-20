{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.grafana;
  server_settings = config.services.grafana.settings.server;
in {
  options.aa.services.grafana = with types; {
    enable = mkEnableOption "grafana";
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
    services.grafana = {
      enable = true;
      settings.server = {
        domain = "grafana.kilonull.com";
        http_port = 2342;
        http_addr = "0.0.0.0";
      };

      provision = {
        enable = true;
        datasources = {
          # This assumes prometheus, loki, and grafana are all running on the
          # same host.
          settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
            }
          ];
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${server_settings.domain}" =
        {
          locations."/" = {
            proxyPass = "http://${server_settings.http_addr}:${toString server_settings.http_port}";
            proxyWebsockets = true;
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
