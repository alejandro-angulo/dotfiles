{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.fonts;
in {
  options.${namespace}.fonts = {
    enable = lib.mkEnableOption "font config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["Hack"];})
      noto-fonts
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["Hack Nerd Font"];
        emoji = ["Noto Color Emoji"];
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
      };
    };
  };
}
