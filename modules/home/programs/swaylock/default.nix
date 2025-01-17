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
    catppuccin.swaylock.enable = true;
    programs.swaylock.enable = true;
  };
}
