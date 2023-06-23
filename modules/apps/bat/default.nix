{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.bat;
in {
  options.aa.apps.bat = with types; {
    enable = mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.bat = {
        enable = true;
        config.theme = "gruvbox-dark";
      };
    };
  };
}
