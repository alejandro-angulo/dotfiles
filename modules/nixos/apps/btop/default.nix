{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.apps.btop;
in {
  options.aa.apps.btop = with types; {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions.programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        vim_keys = true;
        color_theme = "gruvbox_dark_v2";
      };
    };
  };
}
