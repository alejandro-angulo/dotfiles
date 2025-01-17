{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.yazi;
in {
  options.${namespace}.programs.yazi = {
    enable = lib.mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi.enable = true;
    catppuccin.yazi.enable = true;
  };
}
