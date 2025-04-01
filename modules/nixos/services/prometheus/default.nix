{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.aa.services.prometheus;
  exporters = config.services.prometheus.exporters;
in
{
  options.aa.services.prometheus = with lib; {
    enable = mkEnableOption "prometheus";
    enableServer = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to enable the prometheus server";
    };
    enableNodeExporter = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable the node exporter";
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = cfg.enableServer;
      exporters = {
        node = {
          enable = cfg.enableNodeExporter;
          enabledCollectors = [ "systemd" ];
          port = 9002;
          openFirewall = true;
        };
      };
      scrapeConfigs = mkIf cfg.enableServer [
        {
          job_name = "node";
          static_configs = [
            {
              # TODO: How to automatically generate this whenever an exporter
              # is configured
              targets = [
                "node:${toString exporters.node.port}"
                "gospel:${toString exporters.node.port}"
                "pi4:${toString exporters.node.port}"
              ];
            }
          ];
        }
      ];
    };

    networking.firewall = mkIf cfg.enableServer {
      allowedTCPPorts = [ config.services.prometheus.port ];
    };
  };
}
