{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.playerctl;
in {
  options.aa.desktop.addons.playerctl = with types; {
    enable = mkEnableOption "playerctl";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [playerctl];

    aa.home.extraOptions = {
      services.playerctld.enable = true;
    };
  };
}
