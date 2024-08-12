{
  config,
  pkgs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;

  cfg = config.${namespace}.windowManagers.sway;
  nag = "swaynag";
  left = "h";
  right = "l";
  up = "k";
  down = "j";
  modifier = "Mod4";

  # TODO: This assumes I'll be using rofi and kitty. Should make more generic.
  menu = "rofi -show run";
  emoji_picker = "rofi -show emoji";
  terminal = "kitty";

  generate_grimshot_command = target: ''
    exec mkdir -p ~/screenshots \
    && ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save ${target} \
    ~/screenshots/"$(date -u --iso-8601=seconds)".png
  '';
in {
  options.${namespace}.windowManagers.sway = {
    enable = mkEnableOption "sway";

    wallpaperPath = mkOption {
      type = types.str;
      default = "sway/wallpaper.jpg";
      description = ''
        Path to wallpaper, relative to xdg.dataHome
      '';
    };
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      fonts.enable = true;
      programs = {
        kitty.enable = true;
        rofi.enable = true;
        swaylock.enable = true;
        waybar.enable = true;
      };
      services = {
        gammastep.enable = true;
        playerctld.enable = true;
        swayidle.enable = true;
        swaync.enable = true;
      };
    };

    home.packages = with pkgs; [
      feh
      grim
      slurp
      sway-contrib.grimshot
      wev
      wl-clipboard
      xdg-utils
    ];

    catppuccin.pointerCursor = {
      enable = true;
      accent = "dark";
    };
    gtk.catppuccin = {
      enable = true;
      icon.enable = true;
    };
    qt.style.catppuccin = {
      enable = true;
      apply = true;
    };

    # For screen sharing to work
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-wlr xdg-desktop-portal-gtk];
      config.common.default = "*";
    };

    xdg.dataFile.${cfg.wallpaperPath}.source = ./wallpaper.jpg;

    wayland.windowManager.sway = {
      # WORKAROUND: https://github.com/nix-community/home-manager/issues/5311
      checkConfig = false;

      enable = true;
      catppuccin.enable = true;
      swaynag.enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      systemd.enable = true; # needed this for screen sharing to work

      config = {
        inherit terminal menu left right up down modifier;
        workspaceAutoBackAndForth = true;

        # Use catppuccin colors
        colors = {
          background = "$base";
          focused = {
            border = "$lavender";
            background = "$base";
            text = "$text";
            indicator = "$rosewater";
            childBorder = "$lavender";
          };
          focusedInactive = {
            border = "$overlay0";
            background = "$base";
            text = "$text";
            indicator = "$rosewater";
            childBorder = "$overlay0";
          };
          unfocused = {
            border = "$overlay0";
            background = "$base";
            text = "$text";
            indicator = "$rosewater";
            childBorder = "$overlay0";
          };
          urgent = {
            border = "$peach";
            background = "$base";
            text = "$peach";
            indicator = "$overlay0";
            childBorder = "$peach";
          };
          placeholder = {
            border = "$overlay0";
            background = "$base";
            text = "$text";
            indicator = "$overlay0";
            childBorder = "$overlay0";
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
          "*".bg = "${config.xdg.dataHome}/${cfg.wallpaperPath} fill";
          "eDP-1".scale = "1";
          "Dell Inc. DELL S2721QS 4FR7M43".position = "0 0";
          "Dell Inc. DELL S2721QS 47W7M43".position = "0 2160";
        };

        modes = {
          resize = {
            # left will shrink the containers width
            # right will grow the containers width
            # up will shrink the containers height
            # down will grow the containers height
            "${left}" = "resize shrink width 50px";
            "${down}" = "resize grow height 50px";
            "${up}" = "resize shrink height 50px";
            "${right}" = "resize grow width 50px";

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
          "${modifier}+s" = "mode resize";

          # Misc
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+c" = "kill";
          "${modifier}+p" = "exec ${menu}";
          "${modifier}+d" = "exec ${emoji_picker}";
          "${modifier}+z" = "reload";
          "${modifier}+x" = "exec swaylock";

          # Volume control
          "XF86AudioRaiseVolume" = " exec 'pamixer --increase 5'";
          "XF86AudioLowerVolume" = " exec 'pamixer --decrease 5'";
          "XF86AudioMute" = " exec 'pamixer --toggle-mute'";

          # Music player control
          "XF86AudioPrev" = "exec 'playerctl previous'";
          "XF86AudioNext" = "exec 'playerctl next'";
          "XF86AudioPlay" = "exec 'playerctl play-pause'";
          "${modifier}+Down" = "exec 'playerctl pause'";
          "${modifier}+Up" = "exec 'playerctl play'";
          "${modifier}+Right" = "exec 'playerctl next'";
          "${modifier}+Left" = "exec 'playerctl previous'";

          # Backlight keys
          "XF86MonBrightnessDown" = "exec 'light -U 5'";
          "XF86MonBrightnessUp" = "exec 'light -A 5'";

          # Navigation

          ## Focus

          ### Move your focus around
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";

          ### Move the focused window with the same, but add Shift
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";

          ## Workspaces

          ### Switch to a workspace
          "${modifier}+q" = "workspace number 1";
          "${modifier}+w" = "workspace number 2";
          "${modifier}+e" = "workspace number 3";
          "${modifier}+r" = "workspace number 4";
          "${modifier}+t" = "workspace number 5";
          "${modifier}+y" = "workspace number 6";
          "${modifier}+u" = "workspace number 7";
          "${modifier}+i" = "workspace number 8";
          "${modifier}+o" = "workspace number 9";

          ### Move focused container to workspace
          "${modifier}+Shift+q" = "move container to workspace number 1";
          "${modifier}+Shift+w" = "move container to workspace number 2";
          "${modifier}+Shift+e" = "move container to workspace number 3";
          "${modifier}+Shift+r" = "move container to workspace number 4";
          "${modifier}+Shift+t" = "move container to workspace number 5";
          "${modifier}+Shift+y" = "move container to workspace number 6";
          "${modifier}+Shift+u" = "move container to workspace number 7";
          "${modifier}+Shift+i" = "move container to workspace number 8";
          "${modifier}+Shift+o" = "move container to workspace number 9";

          # Layout

          ## Split direction
          "${modifier}+v" = "splith";
          "${modifier}+g" = "splitv";

          ## Switch the current container between different layout styles
          "${modifier}+b" = "layout stacking";
          "${modifier}+n" = "layout tabbed";
          "${modifier}+m" = "layout toggle split";

          ## Make the current focus fullscreen
          "${modifier}+f" = "fullscreen";

          ## move container between displays
          "${modifier}+semicolon" = "move workspace to output up";

          ## Toggle the current focus between tiling and floating mode
          "${modifier}+Shift+f" = "floating toggle";

          ## Swap focus between the tiling area and the floating area
          "${modifier}+space" = "focus mode_toggle";

          ## Move focus to the parent container
          "${modifier}+a" = "focus parent";

          # Notifications

          ## Toggle notification center
          "${modifier}+Shift+n" = "exec '${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw'";

          ## Toggle Do Not Disturb
          "${modifier}+Shift+d" = "exec '${pkgs.swaynotificationcenter}/bin/swaync-client -d  -sw'";

          # Screenshots

          ## Current window
          "${modifier}+period" = generate_grimshot_command "active";

          ## Area selection
          "${modifier}+Shift+period" = generate_grimshot_command "area";

          ## Current output
          "${modifier}+Alt+period" = generate_grimshot_command "output";

          ## Window selection
          "${modifier}+Ctrl+period" = generate_grimshot_command "window";

          # Scratchpad
          # Move the currently focused window to the scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";
          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          "${modifier}+minus" = "scratchpad show";

          # TODO: Get keyboard navigation working with this
          # Exit sway (logs you out of your Wayland session)
          "${modifier}+Shift+z" = ''
            exec ${nag} -t warning \
            -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' \
            -b 'Yes, exit sway' 'swaymsg exit' \
            -b 'Reload' 'swaymsg reload'
          '';
        };
      };
    };
  };
}
