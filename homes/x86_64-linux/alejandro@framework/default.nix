{ lib, pkgs, ... }:
let

  internal_display_settings = "eDP-1,preferred,auto,2";
  clamshell_script = pkgs.writeShellScriptBin "clamshell" ''
    if ${pkgs.hyprland}/bin/hyprctl monitors | ${pkgs.ripgrep}/bin/rg -q '\sDP-'; then
        if [[ "$1" == "open" ]]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor ${internal_display_settings}
        else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,disable"
        fi
    fi
  '';
in
{
  aa.isHeadless = false;
  aa.windowManagers.sway.clamshell.enable = true;
  aa.programs.opencode.enable = true;
  aa.windowManagers.hyprland = {
    enable = true;
    monitor = [
      internal_display_settings
      "desc:Dell Inc. DELL U4025QW BH2F734,preferred,auto,1.6"
      ",preferred,auto,1"
    ];
  };
  aa.services.hypridle.suspendInhibitWhenPluggedIn = true;
  aa.windowManagers.sway.enable = lib.mkForce false;

  wayland.windowManager.hyprland.settings.bindl = [
    ", switch:off:Lid Switch, exec, ${clamshell_script}/bin/clamshell open"
    ", switch:on:Lid Switch, exec, ${clamshell_script}/bin/clamshell close"
  ];

  catppuccin.zathura.enable = true;
  programs.zathura.enable = true;
}
