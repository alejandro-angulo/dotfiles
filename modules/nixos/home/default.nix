{
  options,
  config,
  lib,
  inputs,
  namespace,
  ...
}:
let
  inherit (lib) mkAliasDefinitions mkOption;
  inherit (lib.types) attrs;
in
{
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];

  options.${namespace}.home = {
    file = mkOption {
      type = attrs;
      default = { };
      description = "A set of files to be manged by home-manager's <option>home.file</option> option.";
    };
    configFile = mkOption {
      type = attrs;
      default = { };
      description = "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    };
    dataFile = mkOption {
      type = attrs;
      default = { };
      description = "A set of files to be managed by home-manager's <option>xdg.dataFile</option>.";
    };
    extraOptions = mkOption {
      type = attrs;
      default = { };
      description = "Options to pass directly to home-manager.";
    };
  };

  config = {
    ${namespace}.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.aa.home.file;
      xdg = {
        enable = true;
        configFile = mkAliasDefinitions options.aa.home.configFile;
        dataFile = mkAliasDefinitions options.aa.home.dataFile;
      };
    };

    home-manager = {
      useUserPackages = true;

      users.${config.aa.user.name} = mkAliasDefinitions options.aa.home.extraOptions;
    };
  };
}
