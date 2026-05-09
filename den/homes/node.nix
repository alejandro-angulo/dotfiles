{
  den,
  inputs,
  lib,
  ...
}:
let
  system = "x86_64-linux";
  pkgsLib = import ../_lib/pkgs.nix { inherit inputs lib; };
  inherit (pkgsLib) namespace mkPkgs;
in
{
  den.homes.${system}."alejandro@node" = {
    aspect = den.aspects."alejandro@node";
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
