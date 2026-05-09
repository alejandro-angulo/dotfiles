{
  inputs,
  den,
  lib,
  ...
}:
let
  pkgsLib = import ./_lib/pkgs.nix { inherit inputs lib; };
  inherit (pkgsLib) namespace nixpkgsConfig defaultOverlay;

  username = "alejandro";
  homeDirectory = "/home/${username}";

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
      system.stateVersion = lib.mkDefault "24.05";
    };

    homeManager = {
      imports = commonHomeModules;
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault homeDirectory;
      home.stateVersion = lib.mkDefault "24.05";
      _module.args = specialArgs;
    };
  };

  den.ctx.hm-host.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

  den.aspects.${username}.includes = [
    den.provides.primary-user
  ];
}
