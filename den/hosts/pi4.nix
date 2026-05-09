{ den, inputs, ... }:
let
  system = "aarch64-linux";
  namespace = "aa";
in
{
  den.hosts.${system}.pi4 = {
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
