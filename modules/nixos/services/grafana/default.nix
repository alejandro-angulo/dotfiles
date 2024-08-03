{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;

  cfg = config.${namespace}.services.grafana;
  server_settings = config.services.grafana.settings.server;
  grafana_dashboards = pkgs.${namespace}.teslamate-grafana-dashboards;
in {
  options.${namespace}.services.grafana = {
    enable = mkEnableOption "grafana";
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
    age.secrets = {
      teslamate_db_for_grafana = {
        file = ../../../../secrets/teslamate_db.age;
        owner = "grafana";
      };
    };

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
            {
              name = "TeslaMate";
              type = "postgres";
              access = "proxy";
              url = "localhost:5432";
              user = "teslamate";
              database = "teslamate";
              secureJsonData = {
                password = "$__file{${config.age.secrets.teslamate_db_for_grafana.path}}";
              };
              jsonData = {
                # TODO: Automate this somehow?
                postgresVersion = "1400";
                sslmode = "disable";
              };
            }
          ];
        };

        dashboards = {
          settings.providers = [
            {
              name = "teslamate";
              orgId = 1;
              folder = "TeslaMate";
              folderUid = "Nr4ofiDZk";
              type = "file";
              disableDeletion = false;
              editable = true;
              updateIntervalSeconds = 86400;
              options.path = "${grafana_dashboards}/dashboards";
            }
            {
              name = "teslamate_internal";
              orgId = 1;
              folder = "TeslaMate/Internal";
              folderUid = "Nr5ofiDZk";
              type = "file";
              disableDeletion = false;
              editable = true;
              updateIntervalSeconds = 86400;
              options.path = "${grafana_dashboards}/dashboards/internal";
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
