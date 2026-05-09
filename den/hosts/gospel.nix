{ den, inputs, ... }:
let
  system = "x86_64-linux";
  namespace = "aa";
in
{
  den.hosts.${system}.gospel = {
    instantiate =
      args:
      inputs.nixpkgs.lib.nixosSystem (
        args
        // {
          specialArgs = {
            inherit inputs namespace system;
          };
        }
      );

    users.alejandro = { };
  };
}
