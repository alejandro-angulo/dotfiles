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
    monitor = [
      {
        output = "HDMI-A-1";
        mode = "preferred";
        position = "auto";
        scale = 1.25;
      }
    ];
  };
  aa.windowManagers.sway.enable = lib.mkForce false;
  aa.services.hypridle.suspendEnable = false;
}
