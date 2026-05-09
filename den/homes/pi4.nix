{
  den,
  inputs,
  lib,
  ...
}:
let
  system = "aarch64-linux";
  pkgsLib = import ../_lib/pkgs.nix { inherit inputs lib; };
  inherit (pkgsLib) namespace mkPkgs;
in
{
  den.homes.${system}."alejandro@pi4" = {
    aspect = den.aspects."alejandro@pi4";
    userName = "alejandro";

    instantiate =
      { pkgs, modules }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        inherit modules;
        extraSpecialArgs = {
          inherit inputs namespace system;
        };
      };
  };
}
