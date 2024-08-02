{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aa.suites.desktop;
in {
  options.aa.suites.desktop = {
    enable = mkEnableOption "common desktop configuration";
  };

  config = mkIf cfg.enable {
    aa = {
      desktop = {
        sway.enable = true;
      };
    };
  };
}
