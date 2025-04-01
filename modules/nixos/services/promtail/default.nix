{
  config,
  lib,
  ...
}:
let
  cfg = config.aa.services.promtail;
in
{
  options.aa.services.promtail = with lib; {
    enable = mkEnableOption "promtail";
  };

  config = lib.mkIf cfg.enable {
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
            # TODO: Don't hardcode this?
            url = "http://node:3030/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    # networking.firewall = {
    #   allowedTCPPorts = [80 443];
    # };
  };
}
