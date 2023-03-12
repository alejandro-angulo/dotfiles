{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.sway;
  sway_cfg = config.aa.home.extraOptions.wayland.windowManager.sway;
in {
  options.aa.desktop.sway = with types; {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    aa.desktop.addons = {
      alacritty.enable = true;
      fonts.enable = true;
      rofi.enable = true;

      # TODO
      # playerctl
      # light
      # pamixer
    };

    aa.home.extraOptions = {
      wayland.windowManager.sway = {
        enable = true;
        swaynag.enable = true;
        wrapperFeatures.gtk = true; # so that gtk works properly

        config = {
          modifier = "Mod4";
          terminal = "alacritty";
          menu = "rofi -show run";
          workspaceAutoBackAndForth = true;

          colors = {
            focused = {
              border = "#2B3C44";
              background = "#4E3D45";
              text = "#FFFFFF";
              indicator = "#333333";
              childBorder = "#000000";
            };
            focusedInactive = {
              border = "#484848";
              background = "#333333";
              text = "#FFFFFF";
              indicator = "#000000";
              childBorder = "#000000";
            };
            unfocused = {
              border = "#484848";
              background = "#333333";
              text = "#FFFFFF";
              indicator = "#000000";
              childBorder = "#000000";
            };
          };

          window = {
            titlebar = true;
            commands = [
              {
                command = "inhibit_idle fullscreen";
                criteria = {class = ".*";};
              }
            ];
          };

          focus.followMouse = false;

          fonts = {
            names = ["Hack Nerd Font"];
            size = 10.0;
          };

          # TODO: Should this live at the system configuration level?
          output = {
            # TODO: Set up wallpaper
            # "*".bg = "${wallpaper} fill";
            "eDP-1".scale = "1";

            "Unknown ASUS VG24V 0x00007AAC" = {
              mode = "1920x1080@120Hz";
              position = "0 830";
            };

            "Dell Inc. DELL S2721QS 47W7M43" = {
              transform = "270";
              position = "1920 0";
            };
            "Dell Inc. DELL S2721QS 4FR7M43".position = "4080 830";
          };

          modes = {
            resize = {
              # left will shrink the containers width
              # right will grow the containers width
              # up will shrink the containers height
              # down will grow the containers height
              "${sway_cfg.left}" = "resize shrink width 50px";
              "${sway_cfg.down}" = "resize grow height 50px";
              "${sway_cfg.up}" = "resize shrink height 50px";
              "${sway_cfg.right}" = "resize grow width 50px";

              # Ditto, with arrow keys
              "Left" = "resize shrink width 50px";
              "Down" = "resize grow height 50px";
              "Up" = "resize shrink height 50px";
              "Right" = "resize grow width 50px";

              # Exit resize mode
              "Insert" = "mode default";
              "Escape" = "mode default";
              "Return" = "mode default";
            };

            nag = {
              "Ctrl+d" = "mode default";

              "Ctrl+c" = "exec ${nag} --exit";
              "q" = "exec ${nag} --exit";
              "Escape" = "exec ${nag} --exit";

              "Return" = "exec ${nag} --confirm";

              "j" = "exec ${nag} --next";
              "Tab" = "exec ${nag} --next";
              "Up" = "exec ${nag} --next";

              "k" = "exec ${nag} --prev";
              "Shift+Tab" = "exec ${nag} prev";
              "Down" = "exec ${nag} prev";
            };
          };

          keybindings = {
            # Activate modes
            "${sway_cfg.modifier}+s" = "mode resize";

            # Misc
            "${sway_cfg.modifier}+Return" = "exec ${sway_cfg.terminal}";
            "${sway_cfg.modifier}+c" = "kill";
            "${sway_cfg.modifier}+p" = "exec ${sway_cfg.menu}";
            "${sway_cfg.modifier}+z" = "reload";
            "${sway_cfg.modifier}+x" = "exec swaylock -i ${config.home.homeDirectory}/dotfiles/users/alejandro/sway/wallpaper.png";

            # Volume control
            "XF86AudioRaiseVolume" = " exec 'pamixer --increase 5'";
            "XF86AudioLowerVolume" = " exec 'pamixer --decrease 5'";
            "XF86AudioMute" = " exec 'pamixer --toggle-mute'";

            # Music player control
            "XF86AudioPrev" = "exec 'playerctl previous'";
            "XF86AudioNext" = "exec 'playerctl next'";
            "XF86AudioPlay" = "exec 'playerctl play-pause'";
            "${sway_cfg.modifier}+Down" = "exec 'playerctl pause'";
            "${sway_cfg.modifier}+Up" = "exec 'playerctl play'";
            "${sway_cfg.modifier}+Right" = "exec 'playerctl next'";
            "${sway_cfg.modifier}+Left" = "exec 'playerctl previous'";

            # Backlight keys
            "XF86MonBrightnessDown" = "exec 'light -U 5'";
            "XF86MonBrightnessUp" = "exec 'light -A 5'";

            # Navigation

            ## Focus

            ### Move your focus around
            "${sway_cfg.modifier}+${sway_cfg.left}" = "focus left";
            "${sway_cfg.modifier}+${sway_cfg.down}" = "focus down";
            "${sway_cfg.modifier}+${sway_cfg.up}" = "focus up";
            "${sway_cfg.modifier}+${sway_cfg.right}" = "focus right";

            ### Move the focused window with the same, but add Shift
            "${sway_cfg.modifier}+Shift+${sway_cfg.left}" = "move left";
            "${sway_cfg.modifier}+Shift+${sway_cfg.down}" = "move down";
            "${sway_cfg.modifier}+Shift+${sway_cfg.up}" = "move up";
            "${sway_cfg.modifier}+Shift+${sway_cfg.right}" = "move right";

            ## Workspaces

            ### Switch to a workspace
            "${sway_cfg.modifier}+q" = "workspace number 1";
            "${sway_cfg.modifier}+w" = "workspace number 2";
            "${sway_cfg.modifier}+e" = "workspace number 3";
            "${sway_cfg.modifier}+r" = "workspace number 4";
            "${sway_cfg.modifier}+t" = "workspace number 5";
            "${sway_cfg.modifier}+y" = "workspace number 6";
            "${sway_cfg.modifier}+u" = "workspace number 7";
            "${sway_cfg.modifier}+i" = "workspace number 8";
            "${sway_cfg.modifier}+o" = "workspace number 9";

            ### Move focused container to workspace
            "${sway_cfg.modifier}+Shift+q" = "move container to workspace number 1";
            "${sway_cfg.modifier}+Shift+w" = "move container to workspace number 2";
            "${sway_cfg.modifier}+Shift+e" = "move container to workspace number 3";
            "${sway_cfg.modifier}+Shift+r" = "move container to workspace number 4";
            "${sway_cfg.modifier}+Shift+t" = "move container to workspace number 5";
            "${sway_cfg.modifier}+Shift+y" = "move container to workspace number 6";
            "${sway_cfg.modifier}+Shift+u" = "move container to workspace number 7";
            "${sway_cfg.modifier}+Shift+i" = "move container to workspace number 8";
            "${sway_cfg.modifier}+Shift+o" = "move container to workspace number 9";

            # Layout

            ## Split direction
            "${sway_cfg.modifier}+v" = "splith";
            "${sway_cfg.modifier}+g" = "splitv";

            ## Switch the current container between different layout styles
            "${sway_cfg.modifier}+b" = "layout stacking";
            "${sway_cfg.modifier}+n" = "layout tabbed";
            "${sway_cfg.modifier}+m" = "layout toggle split";

            ## Make the current focus fullscreen
            "${sway_cfg.modifier}+f" = "fullscreen";

            ## move container between displays
            "${sway_cfg.modifier}+semicolon" = "move workspace to output right";

            ## Toggle the current focus between tiling and floating mode
            "${sway_cfg.modifier}+Shift+f" = "floating toggle";

            ## Swap focus between the tiling area and the floating area
            "${sway_cfg.modifier}+space" = "focus mode_toggle";

            ## Move focus to the parent container
            "${sway_cfg.modifier}+a" = "focus parent";

            # Scratchpad
            # Move the currently focused window to the scratchpad
            "${sway_cfg.modifier}+Shift+minus" = "move scratchpad";
            # Show the next scratchpad window or hide the focused scratchpad window.
            # If there are multiple scratchpad windows, this command cycles through them.
            "${sway_cfg.modifier}+minus" = "scratchpad show";

            # Exit sway (logs you out of your Wayland session)
            "${sway_cfg.modifier}+Shift+z" = "exec ${nag} -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit' -b 'Reload' 'swaymsg reload'";
          };
        };
      };
    };
  };
}
