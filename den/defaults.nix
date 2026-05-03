{
  inputs,
  den,
  lib,
  ...
}:
let
  namespace = "aa";
  username = "alejandro";
  homeDirectory = "/home/${username}";

  nixpkgsConfig = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

  packageDefinitions = pkgs: {
    catppuccin-swaync = pkgs.callPackage ../packages/catppuccin-swaync { };
    catppuccin-waybar = pkgs.callPackage ../packages/catppuccin-waybar { };
    teslamate-grafana-dashboards = pkgs.callPackage ../packages/teslamate-grafana-dashboards { };
  };

  packageOverlay = final: prev: {
    ${namespace} = (prev.${namespace} or { }) // packageDefinitions final;
  };

  neovimOverlay = import ../overlays/neovim { inherit (inputs) nixvim; };
  signalDesktopOverlay = import ../overlays/signal-desktop { };
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

  localNixosModules = collectDefaultModules ../modules/nixos;
  localHomeModules = collectDefaultModules ../modules/home;

  specialArgs = {
    inherit inputs namespace;
  };

  commonNixosModules =
    builtins.attrValues localNixosModules
    ++ (with inputs; [
      agenix.nixosModules.default
      catppuccin.nixosModules.catppuccin
    ]);

  commonHomeModules =
    builtins.attrValues localHomeModules
    ++ (with inputs; [
      catppuccin.homeModules.catppuccin
      spicetify-nix.homeManagerModules.spicetify
    ]);
in
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    includes = [
      den.provides.define-user
    ];

    nixos = {
      imports = commonNixosModules;
      nixpkgs.config = nixpkgsConfig;
      nixpkgs.overlays = [ defaultOverlay ];
      _module.args = specialArgs;
    };

    homeManager = {
      imports = commonHomeModules;
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault homeDirectory;
      _module.args = specialArgs;
    };
  };

  den.ctx.hm-host.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = commonHomeModules;
    extraSpecialArgs = specialArgs;
  };

  den.aspects.${username}.includes = [
    den.provides.primary-user
  ];
}
