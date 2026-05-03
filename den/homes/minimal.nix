{ den, inputs, ... }:
let
  system = "x86_64-linux";
  namespace = "aa";
in
{
  den.homes.${system}."alejandro@minimal" = {
    aspect = den.aspects."alejandro@minimal";
    userName = "alejandro";

    instantiate =
      { pkgs, modules }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules;
        extraSpecialArgs = {
          inherit inputs namespace system;
        };
      };
  };
}
