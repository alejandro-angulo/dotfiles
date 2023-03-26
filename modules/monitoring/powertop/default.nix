{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.monitoring.powertop;
in {
  options.aa.monitoring.powertop = with types; {
    enable = mkEnableOption "powertop";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [powertop];

    powerManagement.powertop.enable = true;
  };
}
