{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.suites.desktop;
in {
  options.aa.suites.desktop = with lib.types; {
    enable = mkEnableOption "common desktop configuration";
  };

  config = mkIf cfg.enable {
    aa = {
      desktop = {
        sway.enable = true;
      };

      apps = {
        firefox.enable = true;
      };
    };
  };
}
