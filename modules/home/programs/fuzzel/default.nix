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

    programs.fuzzel = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
