{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.kitty;
in {
  options.${namespace}.programs.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      # Set theme with `extraConfig` instead of `theme` to avoid IFD.
      # See here: https://github.com/nix-community/home-manager/issues/5110
      extraConfig = ''
        include ${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf
      '';
      font = {
        size = 12;
        package = pkgs.nerdfonts.override {fonts = ["Hack"];};
        name = "Hack Nerd Font";
      };
      settings = {
        background_opacity = "0.95";
      };
      keybindings = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "cmd+=" = "change_font_size current +2.0";
          "cmd+minus" = "change_font_size current -2.0";
          "cmd+0" = "change_font_size current 0";
        })
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          "ctrl+=" = "change_font_size current +2.0";
          "ctrl+minus" = "change_font_size current -2.0";
          "ctrl+0" = "change_font_size current 0";
        })
      ];
    };
  };
}
