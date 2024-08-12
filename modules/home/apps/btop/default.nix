{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.apps.btop;
in {
  options.${namespace}.apps.btop = {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        theme_background = false;
        vim_keys = true;
      };
    };
  };
}
