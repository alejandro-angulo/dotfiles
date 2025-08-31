{ lib, ... }:
{
  aa.isHeadless = false;
  aa.programs.opencode.enable = true;
  services.spotifyd = {
    enable = true;
    settings.global.bitrate = 320;
  };
  aa.windowManagers.hyprland.enable = true;
  aa.windowManagers.sway.enable = lib.mkForce false;
}
