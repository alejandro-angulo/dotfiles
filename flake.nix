{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ssbm-nix.url = github:djanatyn/ssbm-nix;
  };

  outputs = {
    nixpkgs,
    home-manager,
    ssbm-nix,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    lib = nixpkgs.lib;
  in {
    homeManagerConfigurations = {
      alejandro = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "alejandro";
        homeDirectory = "/home/alejandro";
        stateVersion = "22.05";
        configuration = {
          imports = [
            ./users/alejandro/home.nix
          ];
        };
      };
    };

    nixosConfigurations = {
      virtual = lib.nixosSystem {
        inherit system;

        modules = [
          ./system/virtual/configuration.nix
        ];
      };

      carbon = lib.nixosSystem {
        inherit system;

        modules = [
          ./system/carbon/configuration.nix
          ./common/yubikey.nix
        ];
      };

      gospel = lib.nixosSystem {
        inherit system;

        modules = [
          ssbm-nix.nixosModule
          ./system/gospel/configuration.nix
          ./common/yubikey.nix
        ];
      };
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        name = "nixosbuildshell";
        buildInputs = with pkgs; [
          git
          git-crypt
          nixVersions.stable
          alejandra
          pre-commit
          direnv
        ];

        shellHook = ''
          echo "You can apply this flake to your system with nixos-rebuild switch --flake .#"

            PATH=${pkgs.writeShellScriptBin "nix" ''
            ${pkgs.nixVersions.stable}/bin/nix --experimental-features "nix-command flakes" "$@"
          ''}/bin:$PATH
        '';
      };
    };
  };
}
