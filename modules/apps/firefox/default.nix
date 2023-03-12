{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.firefox;
in {
  options.aa.apps.firefox = with types; {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {environment.systemPackages = with pkgs; [firefox];};
}
