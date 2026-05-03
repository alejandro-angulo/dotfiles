{
  description = "My Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    den.url = "github:vic/den";

    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim.url = "git+https://git.alejandr0angul0.dev/alejandro-angulo/nixvim-config?ref=main";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    zsh-syntax-highlighting.flake = false;

    powerlevel10k.url = "github:romkatv/powerlevel10k/master";
    powerlevel10k.flake = false;

    catppuccin-nix-palette.url = "git+https://git.alejandr0angul0.dev/alejandro-angulo/catppuccin-nix-palette?ref=main";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      lib = inputs.nixpkgs.lib;
      namespace = "aa";
      username = "alejandro";
      homeDirectory = "/home/${username}";

      nixpkgsConfig = {
        android_sdk.accept_license = true;
        allowUnfree = true;
      };

      packageDefinitions = pkgs: {
        catppuccin-swaync = pkgs.callPackage ./packages/catppuccin-swaync { };
        catppuccin-waybar = pkgs.callPackage ./packages/catppuccin-waybar { };
        teslamate-grafana-dashboards = pkgs.callPackage ./packages/teslamate-grafana-dashboards { };
      };

      packageOverlay = final: prev: {
        ${namespace} = (prev.${namespace} or { }) // packageDefinitions final;
      };

      neovimOverlay = import ./overlays/neovim { inherit (inputs) nixvim; };
      signalDesktopOverlay = import ./overlays/signal-desktop { };
      defaultOverlay = lib.composeManyExtensions [
        packageOverlay
        neovimOverlay
        signalDesktopOverlay
      ];

      collectDefaultModules =
        root:
        let
          collect =
            prefix: dir:
            let
              entries = builtins.readDir dir;
              thisModule =
                if entries ? "default.nix" && entries."default.nix" == "regular" then
                  {
                    ${lib.concatStringsSep "/" prefix} = dir + "/default.nix";
                  }
                else
                  { };
              childModules = lib.mapAttrsToList (
                name: type: if type == "directory" then collect (prefix ++ [ name ]) (dir + "/${name}") else { }
              ) entries;
            in
            lib.foldl' lib.recursiveUpdate thisModule childModules;
        in
        collect [ ] root;

      localNixosModules = collectDefaultModules ./modules/nixos;
      localHomeModules = collectDefaultModules ./modules/home;

      specialArgs = {
        inherit inputs namespace;
      };

      commonNixosModules =
        builtins.attrValues localNixosModules
        ++ (with inputs; [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin
        ]);

      commonHomeModules =
        builtins.attrValues localHomeModules
        ++ (with inputs; [
          catppuccin.homeModules.catppuccin
          spicetify-nix.homeManagerModules.spicetify
        ]);

      baseNixosModule = {
        nixpkgs.config = nixpkgsConfig;
        nixpkgs.overlays = [ defaultOverlay ];

        home-manager.useGlobalPkgs = true;
        home-manager.sharedModules = commonHomeModules;
      };

      mkHomeModule = homePath: {
        ${namespace}.home.extraOptions = {
          imports = [ homePath ];
          home.username = username;
          home.homeDirectory = homeDirectory;
        };
      };

      mkNixosConfiguration =
        {
          system,
          hostPath,
          homePath,
        }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // {
            inherit system;
          };
          modules = commonNixosModules ++ [
            baseNixosModule
            {
              home-manager.extraSpecialArgs = specialArgs // {
                inherit system;
              };
            }
            (mkHomeModule homePath)
            hostPath
          ];
        };

      mkHomeConfiguration =
        {
          system,
          homePath,
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [ defaultOverlay ];
          };
          extraSpecialArgs = specialArgs // {
            inherit system;
          };
          modules = commonHomeModules ++ [
            homePath
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };

      helpers = import ./lib/helpers/default.nix { inherit lib; };

      denConfig =
        (lib.evalModules {
          modules = [
            (inputs.import-tree ./den)
            inputs.den.flakeOutputs.flake
          ];
          specialArgs = { inherit inputs; };
        }).config;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        systems =
          assert denConfig.den.aspects ? phase1-smoke;
          [
            "x86_64-linux"
            "aarch64-linux"
          ];

        perSystem =
          { system, pkgs, ... }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = nixpkgsConfig;
              overlays = [ defaultOverlay ];
            };

            packages = packageDefinitions pkgs;

            devShells.default = inputs.devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                ./devenv.nix
              ];
            };
          };

        flake = {
          lib = lib // helpers;

          overlays = {
            default = defaultOverlay;
            neovim = neovimOverlay;
            signal-desktop = signalDesktopOverlay;
            "package/catppuccin-swaync" = final: prev: {
              ${namespace} = (prev.${namespace} or { }) // {
                catppuccin-swaync = (packageDefinitions final).catppuccin-swaync;
              };
            };
            "package/catppuccin-waybar" = final: prev: {
              ${namespace} = (prev.${namespace} or { }) // {
                catppuccin-waybar = (packageDefinitions final).catppuccin-waybar;
              };
            };
            "package/teslamate-grafana-dashboards" = final: prev: {
              ${namespace} = (prev.${namespace} or { }) // {
                teslamate-grafana-dashboards = (packageDefinitions final).teslamate-grafana-dashboards;
              };
            };
          };

          nixosModules = localNixosModules;
          homeModules = localHomeModules;

          nixosConfigurations = {
            carbon = mkNixosConfiguration {
              system = "x86_64-linux";
              hostPath = ./systems/x86_64-linux/carbon;
              homePath = ./homes/x86_64-linux + "/alejandro@carbon";
            };
            framework = mkNixosConfiguration {
              system = "x86_64-linux";
              hostPath = ./systems/x86_64-linux/framework;
              homePath = ./homes/x86_64-linux + "/alejandro@framework";
            };
            git = mkNixosConfiguration {
              system = "x86_64-linux";
              hostPath = ./systems/x86_64-linux/git;
              homePath = ./homes/x86_64-linux + "/alejandro@git";
            };
            gospel = mkNixosConfiguration {
              system = "x86_64-linux";
              hostPath = ./systems/x86_64-linux/gospel;
              homePath = ./homes/x86_64-linux + "/alejandro@gospel";
            };
            node = mkNixosConfiguration {
              system = "x86_64-linux";
              hostPath = ./systems/x86_64-linux/node;
              homePath = ./homes/x86_64-linux + "/alejandro@node";
            };
            pi4 = mkNixosConfiguration {
              system = "aarch64-linux";
              hostPath = ./systems/aarch64-linux/pi4;
              homePath = ./homes/aarch64-linux + "/alejandro@pi4";
            };
          };

          homeConfigurations = {
            "alejandro@carbon" = mkHomeConfiguration {
              system = "x86_64-linux";
              homePath = ./homes/x86_64-linux + "/alejandro@carbon";
            };
            "alejandro@framework" = mkHomeConfiguration {
              system = "x86_64-linux";
              homePath = ./homes/x86_64-linux + "/alejandro@framework";
            };
            "alejandro@git" = mkHomeConfiguration {
              system = "x86_64-linux";
              homePath = ./homes/x86_64-linux + "/alejandro@git";
            };
            "alejandro@gospel" = mkHomeConfiguration {
              system = "x86_64-linux";
              homePath = ./homes/x86_64-linux + "/alejandro@gospel";
            };
            "alejandro@minimal" = denConfig.flake.homeConfigurations."alejandro@minimal";
            "alejandro@node" = mkHomeConfiguration {
              system = "x86_64-linux";
              homePath = ./homes/x86_64-linux + "/alejandro@node";
            };
            "alejandro@pi4" = mkHomeConfiguration {
              system = "aarch64-linux";
              homePath = ./homes/aarch64-linux + "/alejandro@pi4";
            };
          };

          deploy.nodes = {
            node = {
              hostname = "node";
              profiles.system = {
                user = "root";
                sshUser = "alejandro";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos config.flake.nixosConfigurations.node;
                sshOpts = [ "-A" ];
              };
            };

            gospel = {
              hostname = "gospel";
              profiles.system = {
                user = "root";
                sshUser = "alejandro";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos config.flake.nixosConfigurations.gospel;
                sshOpts = [ "-A" ];
              };
            };

            git = {
              hostname = "git.alejandr0angul0.dev";
              profiles.system = {
                user = "root";
                sshUser = "alejandro";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos config.flake.nixosConfigurations.git;
                sshOpts = [ "-A" ];
              };
            };

            pi4 =
              let
                system = "aarch64-linux";
                pkgs = import inputs.nixpkgs { inherit system; };
                deployPkgs = import inputs.nixpkgs {
                  inherit system;
                  overlays = [
                    inputs.deploy-rs.overlays.default
                    (self: super: {
                      deploy-rs = {
                        inherit (pkgs) deploy-rs;
                        lib = inputs.deploy-rs.lib;
                      };
                    })
                  ];
                };
              in
              {
                hostname = "pi4";
                profiles.system = {
                  user = "root";
                  sshUser = "alejandro";
                  path = deployPkgs.deploy-rs.lib.aarch64-linux.activate.nixos config.flake.nixosConfigurations.pi4;
                  remoteBuild = true;
                };
              };
          };

          domains = helpers.getDomainsPerHost [
            "gospel"
            "node"
            "pi4"
          ] config.flake.nixosConfigurations;
        };
      }
    );
}
