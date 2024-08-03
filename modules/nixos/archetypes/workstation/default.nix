{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aa.archetypes.workstation;
in {
  options.aa.archetypes.workstation = {
    enable = mkEnableOption "workstation archetype";
  };

  config = mkIf cfg.enable {
    aa = {
      suites = {
        desktop.enable = true;
        development.enable = true;
        utils.enable = true;
      };
    };
  };
}
