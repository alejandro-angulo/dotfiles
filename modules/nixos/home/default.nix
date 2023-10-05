{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.aa.home;
in {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];

  options.aa.home = with types; {
    file = mkOption {
      type = attrs;
      default = {};
      description = "A set of files to be manged by home-manager's <option>home.file</option> option.";
    };
    configFile = mkOption {
      type = attrs;
      default = {};
      description = "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    };
    dataFile = mkOption {
      type = attrs;
      default = {};
      description = "A set of files to be managed by home-manager's <option>xdg.dataFile</option>.";
    };
    extraOptions = mkOption {
      type = attrs;
      default = {};
      description = "Options to pass directly to home-manager.";
    };
  };

  config = {
    aa.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.aa.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.aa.home.configFile;
      xdg.dataFile = mkAliasDefinitions options.aa.home.dataFile;
    };

    home-manager = {
      useUserPackages = true;

      users.${config.aa.user.name} =
        mkAliasDefinitions options.aa.home.extraOptions;
    };
  };
}
