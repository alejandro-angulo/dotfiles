{ lib, ... }:
{
  aa.isHeadless = false;
  aa.programs.opencode.enable = true;
  services.spotifyd = {
    enable = true;
    settings.global.bitrate = 320;
  };
  aa.windowManagers.hyprland = {
    enable = true;
    monitor = [ "HDMI-A-1,preferred,auto,1.25" ];
  };
  aa.windowManagers.sway.enable = lib.mkForce false;
}
