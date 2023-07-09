{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Fixes #133
    # See: https://github.com/gytis-ivaskevicius/flake-utils-plus/issues/133
    flake-utils-plus.url = github:ravensiris/flake-utils-plus?ref=ravensiris/fix-devshell-legacy-packages;

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";
    snowfall-lib.inputs.flake-utils-plus.follows = "flake-utils-plus";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      overlay-package-namespace = "aa";

      channels-config.allowUnfree = true;

      systems.modules = with inputs; [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
      ];

      deploy.nodes.node = {
        hostname = "node";
        profiles.system = {
          user = "root";
          sshUser = "alejandro";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.node;
          sshOpts = ["-A"];
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    };
}
