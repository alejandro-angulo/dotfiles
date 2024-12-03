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
      # Set theme explicity instead of using catppuccin flake until relevant PR
      # is merged.
      #
      # https://github.com/catppuccin/nix/pull/337
      themeFile = "Catppuccin-Mocha";
      font = {
        size = 12;
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };
      settings = {
        background_opacity = "0.95";
      };
      keybindings = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "cmd+=" = "change_font_size current +1.0";
          "cmd+minus" = "change_font_size current -1.0";
          "cmd+0" = "change_font_size current 0";
        })
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          "ctrl+=" = "change_font_size current +1.0";
          "ctrl+minus" = "change_font_size current -1.0";
          "ctrl+0" = "change_font_size current 0";
        })
      ];
    };
  };
}
