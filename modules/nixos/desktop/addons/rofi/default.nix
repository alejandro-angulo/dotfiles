{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.rofi;
in {
  options.aa.desktop.addons.rofi = with types; {
    enable = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.rofi = {
        enable = true;
        font = "Hack Nerd Font 10";
        theme = "gruvbox-dark-hard";
        extraConfig = {
          show-icons = true;
        };
      };
    };
  };
}
