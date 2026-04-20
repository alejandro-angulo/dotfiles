{
  config,
  lib,
  ...
}:
let
  cfg = config.aa.services.grafana-alloy;
in
{
  options.aa.services.grafana-alloy = with lib; {
    enable = mkEnableOption "grafana-alloy";
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
    };

    environment.etc."alloy/config.alloy".text = ''
      discovery.relabel "journal" {
      	targets = []

      	rule {
      		source_labels = ["__journal__systemd_unit"]
      		target_label  = "unit"
      	}
      }

      loki.source.journal "journal" {
      	max_age       = "12h0m0s"
      	relabel_rules = discovery.relabel.journal.rules
      	forward_to    = [loki.write.default.receiver]
      	labels        = {
      		host = "${config.networking.hostName}",
      		job  = "systemd-journal",
      	}
      }

      loki.write "default" {
      	endpoint {
      		url = "http://192.168.113.13:3030/loki/api/v1/push"
      	}
      	external_labels = {}
      }
    '';
  };

}
