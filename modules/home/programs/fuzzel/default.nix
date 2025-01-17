{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.fuzzel;
in {
  options.${namespace}.programs.fuzzel = {
    enable = lib.mkEnableOption "fuzzel";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.bemoji];

    catppuccin.fuzzel.enable = true;
    programs.fuzzel.enable = true;
  };
}
