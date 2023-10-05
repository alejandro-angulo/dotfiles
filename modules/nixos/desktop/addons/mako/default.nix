{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.mako;
in {
  options.aa.desktop.addons.mako = with types; {
    enable = mkEnableOption "mako";
  };

  config = mkIf cfg.enable {
    aa.system.fonts.enable = true;

    environment.systemPackages = with pkgs; [mako libnotify];

    aa.home.extraOptions = {
      services.mako = {
        enable = true;

        font = "'Hack Nerd Font' Regular 9";

        backgroundColor = "#1D2021F0";
        textColor = "#FFFFDF";
        borderColor = "#1C1C1C";
        borderRadius = 10;

        padding = "10";
      };
    };
  };
}
