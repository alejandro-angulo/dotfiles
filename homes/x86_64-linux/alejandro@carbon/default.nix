{ lib, pkgs, ... }:
let

  internal_display_settings = "eDP-1,preferred,auto,1.6";
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
      {
        output = "eDP-1";
        mode = "preferred";
        position = "auto";
        scale = 1.6;
      }
      {
        output = "desc:Dell Inc. DELL U4025QW BH2F734";
        mode = "preferred";
        position = "auto";
        scale = 1.25;
      }
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];
  };
  aa.services.hypridle.suspendInhibitWhenPluggedIn = true;
  aa.windowManagers.sway.enable = lib.mkForce false;

  aa.programs.spicetify.enable = true;

  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        "switch:off:Lid Switch"
        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${clamshell_script}/bin/clamshell open")'')
        { locked = true; }
      ];
    }
    {
      _args = [
        "switch:on:Lid Switch"
        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${clamshell_script}/bin/clamshell close")'')
        { locked = true; }
      ];
    }
  ];

  catppuccin.zathura.enable = true;
  programs.zathura.enable = true;
}
