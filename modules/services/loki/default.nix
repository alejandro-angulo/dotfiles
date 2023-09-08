{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.loki;
  loki = config.services.loki;
in {
  options.aa.services.loki = with types; {
    enable = mkEnableOption "loki";
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
    services.loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3030;
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          # Any chunk not receiving new logs in this time will be flushed
          chunk_idle_period = "1h";
          # All chunks will be flushed when they hit this age
          max_chunk_age = "1h";
          # Loki will attempt to build chunks up to this size, flushing first
          # if chunk_idle_period or max_chunk_age is reached first
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = {
          max_look_back_period = "0s";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          shared_store = "filesystem";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };

    services.nginx = mkIf (cfg.acmeCertName != "") {
      enable = true;
      # Confirm with /loki/api/v1/status/buildinfo
      virtualHosts."loki.${cfg.acmeCertName}" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString loki.configuration.server.http_listen_port}";
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
