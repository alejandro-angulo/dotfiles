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
        image = "${config.xdg.dataHome}/${config.${namespace}.windowManagers.sway.wallpaperPath}";
      };
    };
  };
}
