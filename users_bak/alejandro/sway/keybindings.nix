{
  config,
  pkgs,
  ...
}: let
  cfg = config.wayland.windowManager.sway.config;
  nag = "swaynag";
  leaveModeKeys = {
    "Insert" = "mode default";
    "Escape" = "mode default";
    "Return" = "mode default";
  };
in {
  config.wayland.windowManager.sway.config = {
    modes = {
      resize =
        {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          "${cfg.left}" = "resize shrink width 50px";
          "${cfg.down}" = "resize grow height 50px";
          "${cfg.up}" = "resize shrink height 50px";
          "${cfg.right}" = "resize grow width 50px";

          # Ditto, with arrow keys
          "Left" = "resize shrink width 50px";
          "Down" = "resize grow height 50px";
          "Up" = "resize shrink height 50px";
          "Right" = "resize grow width 50px";
        }
        // leaveModeKeys;

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
      "${cfg.modifier}+s" = "mode resize";

      # Misc
      "${cfg.modifier}+Return" = "exec ${cfg.terminal}";
      "${cfg.modifier}+c" = "kill";
      "${cfg.modifier}+p" = "exec ${cfg.menu}";
      "${cfg.modifier}+z" = "reload";
      "${cfg.modifier}+x" = "exec swaylock -i ${config.home.homeDirectory}/dotfiles/users/alejandro/sway/wallpaper.png";

      # Volume control
      "XF86AudioRaiseVolume" = " exec 'pamixer --increase 5'";
      "XF86AudioLowerVolume" = " exec 'pamixer --decrease 5'";
      "XF86AudioMute" = " exec 'pamixer --toggle-mute'";

      # Music player control
      "XF86AudioPrev" = "exec 'playerctl previous'";
      "XF86AudioNext" = "exec 'playerctl next'";
      "XF86AudioPlay" = "exec 'playerctl play-pause'";
      "${cfg.modifier}+Down" = "exec 'playerctl pause'";
      "${cfg.modifier}+Up" = "exec 'playerctl play'";
      "${cfg.modifier}+Right" = "exec 'playerctl next'";
      "${cfg.modifier}+Left" = "exec 'playerctl previous'";

      # Backlight keys
      "XF86MonBrightnessDown" = "exec 'light -U 5'";
      "XF86MonBrightnessUp" = "exec 'light -A 5'";

      # Navigation

      ## Focus

      ### Move your focus around
      "${cfg.modifier}+${cfg.left}" = "focus left";
      "${cfg.modifier}+${cfg.down}" = "focus down";
      "${cfg.modifier}+${cfg.up}" = "focus up";
      "${cfg.modifier}+${cfg.right}" = "focus right";

      ### Move the focused window with the same, but add Shift
      "${cfg.modifier}+Shift+${cfg.left}" = "move left";
      "${cfg.modifier}+Shift+${cfg.down}" = "move down";
      "${cfg.modifier}+Shift+${cfg.up}" = "move up";
      "${cfg.modifier}+Shift+${cfg.right}" = "move right";

      ## Workspaces

      ### Switch to a workspace
      "${cfg.modifier}+q" = "workspace number 1";
      "${cfg.modifier}+w" = "workspace number 2";
      "${cfg.modifier}+e" = "workspace number 3";
      "${cfg.modifier}+r" = "workspace number 4";
      "${cfg.modifier}+t" = "workspace number 5";
      "${cfg.modifier}+y" = "workspace number 6";
      "${cfg.modifier}+u" = "workspace number 7";
      "${cfg.modifier}+i" = "workspace number 8";
      "${cfg.modifier}+o" = "workspace number 9";

      ### Move focused container to workspace
      "${cfg.modifier}+Shift+q" = "move container to workspace number 1";
      "${cfg.modifier}+Shift+w" = "move container to workspace number 2";
      "${cfg.modifier}+Shift+e" = "move container to workspace number 3";
      "${cfg.modifier}+Shift+r" = "move container to workspace number 4";
      "${cfg.modifier}+Shift+t" = "move container to workspace number 5";
      "${cfg.modifier}+Shift+y" = "move container to workspace number 6";
      "${cfg.modifier}+Shift+u" = "move container to workspace number 7";
      "${cfg.modifier}+Shift+i" = "move container to workspace number 8";
      "${cfg.modifier}+Shift+o" = "move container to workspace number 9";

      # Layout

      ## Split direction
      "${cfg.modifier}+v" = "splith";
      "${cfg.modifier}+g" = "splitv";

      ## Switch the current container between different layout styles
      "${cfg.modifier}+b" = "layout stacking";
      "${cfg.modifier}+n" = "layout tabbed";
      "${cfg.modifier}+m" = "layout toggle split";

      ## Make the current focus fullscreen
      "${cfg.modifier}+f" = "fullscreen";

      ## move container between displays
      "${cfg.modifier}+semicolon" = "move workspace to output right";

      ## Toggle the current focus between tiling and floating mode
      "${cfg.modifier}+Shift+f" = "floating toggle";

      ## Swap focus between the tiling area and the floating area
      "${cfg.modifier}+space" = "focus mode_toggle";

      ## Move focus to the parent container
      "${cfg.modifier}+a" = "focus parent";

      # Scratchpad
      # Move the currently focused window to the scratchpad
      "${cfg.modifier}+Shift+minus" = "move scratchpad";
      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      "${cfg.modifier}+minus" = "scratchpad show";

      # Exit sway (logs you out of your Wayland session)
      "${cfg.modifier}+Shift+z" = "exec ${nag} -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit' -b 'Reload' 'swaymsg reload'";
    };
  };
}
