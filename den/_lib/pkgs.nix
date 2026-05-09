# Shared nixpkgs configuration for Den modules
# Called directly from defaults.nix and homes/*.nix, not as a module
{ inputs, lib, ... }:
let
  namespace = "aa";

  nixpkgsConfig = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

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

  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = [ defaultOverlay ];
    };
in
{
  inherit
    namespace
    nixpkgsConfig
    defaultOverlay
    mkPkgs
    ;
}
