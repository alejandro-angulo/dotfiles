{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aa.system.monitoring;
in
{
  options.aa.system.monitoring = {
    enable = mkEnableOption "monitoring";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop
      htop
      lm_sensors
      powertop
    ];

    powerManagement.powertop.enable = true;
  };
}
