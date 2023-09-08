{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.promtail;
  loki = config.services.loki;
in {
  options.aa.services.promtail = with types; {
    enable = mkEnableOption "promtail";
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
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "node";
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    services.nginx = mkIf (cfg.acmeCertName != "") {
      enable = true;
      # Confirm with /loki/api/v1/status/buildinfo
      virtualHosts."promtail.${cfg.acmeCertName}" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.promtail.configuration.server.http_listen_port}";
        };
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
