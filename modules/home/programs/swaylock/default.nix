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
      catppuccin.enable = true;
    };
  };
}
