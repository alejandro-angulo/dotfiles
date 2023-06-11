{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.system.monitoring;
in {
  options.aa.system.monitoring = with types; {
    enable = mkEnableOption "monitoring";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      htop
      lm_sensors
      powertop
      zenith
    ];

    powerManagement.powertop.enable = true;

    aa.apps.btop.enable = true;
  };
}
