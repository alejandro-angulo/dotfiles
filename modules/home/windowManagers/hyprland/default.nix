{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.${namespace}.windowManagers.hyprland;
  left = "h";
  right = "l";
  up = "k";
  down = "j";
  modifier = "SUPER";

  menu = "${pkgs.fuzzel}/bin/fuzzel";
  emoji_picker = "${pkgs.bemoji}/bin/bemoji -t";
  terminal = "${pkgs.kitty}/bin/kitty";

  generate_grim_command = target: ''
    exec mkdir -p ~/screenshots \
    && ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" \
    ~/screenshots/"$(date -u --iso-8601=seconds)".png && \
    ${pkgs.libnotify}/bin/notify-send "Screenshot saved"
  '';
in
{
  options.${namespace}.windowManagers.hyprland = {
    enable = mkEnableOption "Hyprland";

    wallpaperPath = mkOption {
      type = types.str;
      default = "hyprland/wallpaper.jpg";
      description = ''
        Path to wallpaper, relative to xdg.dataHome
      '';
    };

    monitor = mkOption {
      type = types.listOf types.str;
      default = [
        "eDP-1,preferred,auto,1.6"
        ",preferred,auto,1"
      ];
      description = ''
        Monitor configuration for Hyprland
      '';
    };
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      fonts.enable = true;
      programs = {
        kitty.enable = true;
        fuzzel.enable = true;
        waybar.enable = true;
      };
      services = {
        gammastep.enable = true;
        playerctld.enable = true;
        swaync.enable = true;
      };
    };

    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      wtype
      xdg-utils
      libnotify
    ];

    catppuccin.cursors = {
      enable = true;
      accent = "dark";
    };
    catppuccin.gtk.icon.enable = true;
    catppuccin.kvantum = {
      enable = true;
      apply = true;
    };

    xdg.dataFile.${cfg.wallpaperPath}.source = ./wallpaper.jpg;

    catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = [ "--all" ];

      settings = {
        "$mod" = modifier;

        # Monitor configuration
        monitor = cfg.monitor;

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "$lavender";
          "col.inactive_border" = "$overlay0";
          layout = "dwindle";
          allow_tearing = false;
        };

        # Decoration
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };

        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Window rules
        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "idleinhibit fullscreen, class:.*"
        ];

        # Startup
        exec-once = [
          "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "${pkgs.swaynotificationcenter}/bin/swaync"
          "hyprpaper"
        ];

        # Keybindings
        bind = [
          # Applications
          "$mod, Return, exec, ${terminal}"
          "$mod, c, killactive"
          "$mod, p, exec, ${menu}"
          "$mod, d, exec, ${emoji_picker}"
          "$mod, z, exec, hyprctl reload"

          # Focus
          "$mod, ${left}, movefocus, l"
          "$mod, ${down}, movefocus, d"
          "$mod, ${up}, movefocus, u"
          "$mod, ${right}, movefocus, r"

          # Move windows
          "$mod SHIFT, ${left}, movewindow, l"
          "$mod SHIFT, ${down}, movewindow, d"
          "$mod SHIFT, ${up}, movewindow, u"
          "$mod SHIFT, ${right}, movewindow, r"

          # Workspaces (qwertyuio)
          "$mod, q, workspace, 1"
          "$mod, w, workspace, 2"
          "$mod, e, workspace, 3"
          "$mod, r, workspace, 4"
          "$mod, t, workspace, 5"
          "$mod, y, workspace, 6"
          "$mod, u, workspace, 7"
          "$mod, i, workspace, 8"
          "$mod, o, workspace, 9"

          # Move to workspaces
          "$mod SHIFT, q, movetoworkspace, 1"
          "$mod SHIFT, w, movetoworkspace, 2"
          "$mod SHIFT, e, movetoworkspace, 3"
          "$mod SHIFT, r, movetoworkspace, 4"
          "$mod SHIFT, t, movetoworkspace, 5"
          "$mod SHIFT, y, movetoworkspace, 6"
          "$mod SHIFT, u, movetoworkspace, 7"
          "$mod SHIFT, i, movetoworkspace, 8"
          "$mod SHIFT, o, movetoworkspace, 9"

          # Layout
          "$mod, v, togglesplit"
          "$mod, f, fullscreen"
          "$mod SHIFT, f, togglefloating"
          # "$mod, space, focusmode, toggle"
          # "$mod, a, focusparent"

          # Screenshots
          "$mod, period, exec, ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ~/screenshots/\"$(date -u --iso-8601=seconds)\".png && ${pkgs.libnotify}/bin/notify-send \"Screenshot saved\""
          "$mod SHIFT, period, exec, ${pkgs.grim}/bin/grim ~/screenshots/\"$(date -u --iso-8601=seconds)\".png && ${pkgs.libnotify}/bin/notify-send \"Screenshot saved\""

          # Notifications
          "$mod SHIFT, n, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"
          "$mod SHIFT, d, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw"

          # Scratchpad
          "$mod SHIFT, minus, movetoworkspace, special:magic"
          "$mod, minus, togglespecialworkspace, magic"
        ];

        # Media keys
        bindl = [
          ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --increase 5"
          ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer --decrease 5"
          ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 5"
          ", XF86MonBrightnessUp, exec, ${pkgs.light}/bin/light -A 5"
        ];
      };
    };

    # Hyprpaper configuration for wallpaper
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = [
          "${config.xdg.dataHome}/${cfg.wallpaperPath}"
        ];

        wallpaper = [
          ",${config.xdg.dataHome}/${cfg.wallpaperPath}"
        ];
      };
    };
  };
}
