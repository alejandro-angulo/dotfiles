{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aa.desktop.addons.swaync;
in {
  options.aa.desktop.addons.swaync = {
    enable = lib.mkEnableOption "sway notification center";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [libnotify];

    aa.home.extraOptions = {
      services.swaync = {
        enable = true;
        settings = {
          widgets = ["title" "dnd" "notifications" "mpris"];
        };
      };
    };
  };
}
