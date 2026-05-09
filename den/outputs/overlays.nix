# Exposes overlays as flake outputs
# Overlays: default, neovim, signal-desktop, package/catppuccin-swaync,
#           package/catppuccin-waybar, package/teslamate-grafana-dashboards
{
  inputs,
  lib,
  ...
}:
let
  namespace = "aa";

  packageDefinitions = pkgs: {
    catppuccin-swaync = pkgs.callPackage ../../packages/catppuccin-swaync { };
    catppuccin-waybar = pkgs.callPackage ../../packages/catppuccin-waybar { };
    teslamate-grafana-dashboards = pkgs.callPackage ../../packages/teslamate-grafana-dashboards { };
  };

  packageOverlay = final: prev: {
    ${namespace} = (prev.${namespace} or { }) // packageDefinitions final;
  };

  neovimOverlay = import ../../overlays/neovim { inherit (inputs) nixvim; };
  signalDesktopOverlay = import ../../overlays/signal-desktop { };

  defaultOverlay = lib.composeManyExtensions [
    packageOverlay
    neovimOverlay
    signalDesktopOverlay
  ];
in
{
  flake.overlays = {
    default = defaultOverlay;
    neovim = neovimOverlay;
    signal-desktop = signalDesktopOverlay;
    "package/catppuccin-swaync" = final: prev: {
      ${namespace} = (prev.${namespace} or { }) // {
        catppuccin-swaync = (packageDefinitions final).catppuccin-swaync;
      };
    };
    "package/catppuccin-waybar" = final: prev: {
      ${namespace} = (prev.${namespace} or { }) // {
        catppuccin-waybar = (packageDefinitions final).catppuccin-waybar;
      };
    };
    "package/teslamate-grafana-dashboards" = final: prev: {
      ${namespace} = (prev.${namespace} or { }) // {
        teslamate-grafana-dashboards = (packageDefinitions final).teslamate-grafana-dashboards;
      };
    };
  };
}
