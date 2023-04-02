{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.archetypes.workstation;
in {
  options.aa.archetypes.workstation = with types; {
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
