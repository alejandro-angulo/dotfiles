{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.services.swaync;
in {
  options.${namespace}.services.swaync = {
    enable = mkEnableOption "sway notification center";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.libnotify];

    services.swaync = {
      enable = true;
      settings = {
        widgets = ["title" "dnd" "notifications" "mpris"];
      };
    };

    xdg.configFile."swaync/style.css".source = "${pkgs.aa.catppuccin-swaync}/catppuccin.css";
  };
}
