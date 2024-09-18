{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim.url = "github:alejandro-angulo/nixvim-config";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    zsh-syntax-highlighting.flake = false;

    powerlevel10k.url = "github:romkatv/powerlevel10k/master";
    powerlevel10k.flake = false;
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # overlay-package-namespace = "aa";
      snowfall.namespace = "aa";

      channels-config.android_sdk.accept_license = true;
      channels-config.allowUnfree = true;

      systems.modules.nixos = with inputs; [
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
      ];

      homes.modules = with inputs; [catppuccin.homeManagerModules.catppuccin];

      deploy.nodes = {
        node = {
          hostname = "node";
          profiles.system = {
            user = "root";
            sshUser = "alejandro";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.node;
            sshOpts = ["-A"];
          };
        };

        pi4 = let
          system = "aarch64-linux";
          pkgs = import inputs.nixpkgs {inherit system;};
          deployPkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.deploy-rs.overlay
              (self: super: {
                deploy-rs = {
                  inherit (pkgs) deploy-rs;
                  lib = inputs.deploy-rs.lib;
                };
              })
            ];
          };
        in {
          hostname = "pi4";
          profiles.system = {
            user = "root";
            sshUser = "alejandro";
            path = deployPkgs.deploy-rs.lib.aarch64-linux.activate.nixos inputs.self.nixosConfigurations.pi4;
            # Usually deploy from an x86_64 machine and don't want to bother
            # trying to build an aarch64 derivation
            remoteBuild = true;
          };
        };
      };

      # TODO: Re-enable this when I figure out how to prevent needing to build
      # dependencies for architectures other than the host machine
      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;

      hydraJobs = let
        systems_to_build = [
          "gospel"
          "node"
          "carbon"
        ];
      in {
        # Only have a builder for x86_64-linux atm
        packages = inputs.self.packages.x86_64-linux;

        systems = inputs.nixpkgs.lib.attrsets.genAttrs systems_to_build (
          name:
            inputs.self.nixosConfigurations."${name}".config.system.build.toplevel
        );
      };
    };
}
