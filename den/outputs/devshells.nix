# Exposes devShells as flake outputs
# Uses devenv for the default shell
{
  inputs,
  lib,
  ...
}:
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

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  mkDevShellForSystem =
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = [ defaultOverlay ];
      };
    in
    {
      default = inputs.devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ../../devenv.nix
        ];
      };
    };
in
{
  flake.devShells = lib.genAttrs systems mkDevShellForSystem;
}
