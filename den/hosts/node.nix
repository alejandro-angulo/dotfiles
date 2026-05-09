{ den, inputs, ... }:
let
  system = "x86_64-linux";
  namespace = "aa";
in
{
  den.hosts.${system}.node = {
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
      hostname = "node";
      user = "root";
      sshUser = "alejandro";
      sshOpts = [ "-A" ];
      remoteBuild = false;
    };

    # Domain extraction metadata
    extractDomains = true;
  };
}
