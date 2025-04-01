{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.apps.btop;
in
{
  options.${namespace}.apps.btop = {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    catppuccin.btop.enable = true;
    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        vim_keys = true;
      };
    };
  };
}
