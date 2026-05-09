# Exposes packages as flake outputs
# Packages: catppuccin-swaync, catppuccin-waybar, teslamate-grafana-dashboards
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

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  mkPackagesForSystem =
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    packageDefinitions pkgs;
in
{
  flake.packages = lib.genAttrs systems mkPackagesForSystem;
}
