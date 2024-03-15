{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.hardware.tlp;
in {
  options.aa.hardware.tlp = with types; {
    enable = mkEnableOption "tlp";
  };

  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        # Run `tlp fullcharge` to temporarily allow charging to 100%
        STOP_CHARGE_THRESH_BAT0 = 80;
        RESTORE_THRESHOLDS_ON_BAT = 1;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
  };
}
