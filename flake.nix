{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = github:nix-community/NUR;
    ssbm-nix.url = github:djanatyn/ssbm-nix;
  };

  outputs = {
    nixpkgs,
    home-manager,
    nur,
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
        inherit pkgs;
        modules = [
          ./users/alejandro/home.nix
          {
            home = {
              username = "alejandro";
              homeDirectory = "/home/alejandro";

              # This value determines the Home Manager release that your
              # configuration is compatible with. This helps avoid breakage
              # when a new Home Manager release introduces backwards
              # incompatible changes.
              #
              # You can update Home Manager without changing this value. See
              # the Home Manager release notes for a list of state version
              # changes in each release.
              stateVersion = "22.05";
            };
          }
        ];
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
          nur.nixosModules.nur
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
