{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.hardware.logitech;
  username = config.${namespace}.user.name;
in
{
  options.${namespace}.hardware.logitech = {
    enable = mkEnableOption "logitech devices";
  };

  config = mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    systemd.user.services.solaar = {
      description = "Linux device manager for Logitech devices";
      documentation = [ "https://pwr-solaar.github.io/Solaar/" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
      };
    };
    systemd.user.services.solaar.wantedBy =
      mkIf config.home-manager.users.${username}.wayland.windowManager.sway.enable
        [ "sway-session.target" ];
  };
}
