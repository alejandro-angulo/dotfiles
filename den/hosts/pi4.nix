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

    # Deploy metadata for deploy-rs
    deploy = {
      enable = true;
      hostname = "pi4";
      user = "root";
      sshUser = "alejandro";
      sshOpts = [ ];
      remoteBuild = true; # Pi4 requires remote build
    };

    # Domain extraction metadata
    extractDomains = true;
  };
}
