{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aa.services.tailscale;
in {
  options.aa.services.tailscale = with lib; {
    enable = mkEnableOption "tailscale";
    configureClientRouting = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Configures tailscale as a client.

        See `options.services.tailscale.useRoutingFeatures` for more information.
      '';
    };
    configureServerRouting = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Configures tailscale as a server.

        See `options.services.tailscale.useRoutingFeatures` for more information.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tailscale
      tailscale-systray
    ];
    networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
    services.tailscale = {
      enable = true;
      useRoutingFeatures = mkIf (cfg.configureClientRouting || cfg.configureServerRouting) (
        if (cfg.configureClientRouting && cfg.configureServerRouting)
        then "both"
        else
          (
            if cfg.configureClientRouting
            then "client"
            else "server"
          )
      );
    };
  };
}
