{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.fonts;
in
{
  options.${namespace}.fonts = {
    enable = lib.mkEnableOption "font config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.hack
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Hack Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
      };
    };
  };
}
