{ lib, pkgs, ... }:
let

  clamshell_script = pkgs.writeShellScriptBin "clamshell" ''
    if ${pkgs.hyprland}/bin/hyprctl monitors | ${pkgs.ripgrep}/bin/rg -q '\sDP-'; then
        if [[ "$1" == "open" ]]; then
            ${pkgs.hyprland}/bin/hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = false, mode = "preferred", position = "auto", scale = 2 })'
        else
            ${pkgs.hyprland}/bin/hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
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
        scale = 2;
      }
      {
        output = "desc:Dell Inc. DELL U4025QW BH2F734";
        mode = "5120x2160@120";
        position = "auto";
        scale = 1.6;
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

  aa.programs.spicetify.enable = true;

  catppuccin.zathura.enable = true;
  programs.zathura.enable = true;
}
