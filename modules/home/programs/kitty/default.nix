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
      catppuccin.enable = true;
      font = {
        size = 12;
        package = pkgs.nerdfonts.override {fonts = ["Hack"];};
        name = "Hack Nerd Font";
      };
      settings = {
        background_opacity = "0.95";
      };
    };
  };
}
