{ lib, ... }:
{
  aa.isHeadless = false;
  aa.windowManagers.sway.clamshell.enable = true;
  aa.programs.opencode.enable = true;
  aa.windowManagers.hyprland.enable = true;
  aa.windowManagers.sway.enable = lib.mkForce false;
}
