{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.swaylock;
in {
  options.${namespace}.programs.swaylock = {
    enable = mkEnableOption "swaylock";
  };

  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        # TODO: Set wallpaper
        # image = "${config.xdg.dataHome}/${config.${namespace}.desktop.sway.wallpaperPath}";
      };
    };
  };
}
