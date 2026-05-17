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

  layout_toggle_script = pkgs.writeShellScriptBin "layout-toggle" ''
    current_layout="$(${pkgs.hyprland}/bin/hyprctl getoption general:layout -j | ${pkgs.jq}/bin/jq -r .str)"
    case "$current_layout" in
        master) ${pkgs.hyprland}/bin/hyprctl -q keyword general:layout dwindle ;;
        dwindle) ${pkgs.hyprland}/bin/hyprctl -q keyword general:layout master ;;
    esac
  '';

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
      default = "hyprland/wallpaper.png";
      description = ''
        Path to wallpaper, relative to xdg.dataHome
      '';
    };

    monitor = mkOption {
      type = types.listOf types.str;
      default = [
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
        hyprlock.enable = true;
      };
      services = {
        gammastep.enable = true;
        playerctld.enable = true;
        swaync.enable = true;
        hypridle.enable = true;
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

    xdg.dataFile.${cfg.wallpaperPath}.source = ./wallpaper.png;

    # catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      systemd.variables = [ "--all" ];

      extraConfig = ''
        -- Catppuccin Mocha color palette
        local colors = {
          rosewater = "rgb(f5e0dc)",
          flamingo = "rgb(f2cdcd)",
          pink = "rgb(f5c2e7)",
          mauve = "rgb(cba6f7)",
          red = "rgb(f38ba8)",
          maroon = "rgb(eba0ac)",
          peach = "rgb(fab387)",
          yellow = "rgb(f9e2af)",
          green = "rgb(a6e3a1)",
          teal = "rgb(94e2d5)",
          sky = "rgb(89dceb)",
          sapphire = "rgb(74c7ec)",
          blue = "rgb(89b4fa)",
          lavender = "rgb(b4befe)",
          text = "rgb(cdd6f4)",
          subtext1 = "rgb(bac2de)",
          subtext0 = "rgb(a6adc8)",
          overlay2 = "rgb(9399b2)",
          overlay1 = "rgb(7f849c)",
          overlay0 = "rgb(6c7086)",
          surface2 = "rgb(585b70)",
          surface1 = "rgb(45475a)",
          surface0 = "rgb(313244)",
          base = "rgb(1e1e2e)",
          mantle = "rgb(181825)",
          crust = "rgb(11111b)",
        }

        -- Accent color (mauve)
        local accent = colors.mauve

        -- Modifier key
        local mod = "${modifier}"

        -- Startup commands
        hl.exec_once("${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_once("${pkgs.swaynotificationcenter}/bin/swaync")
        hl.exec_once("${pkgs.waybar}/bin/waybar")
        hl.exec_once("${pkgs.hyprpaper}/bin/hyprpaper")

        -- Monitor configuration
        ${lib.concatMapStringsSep "\n" (
          m:
          let
            parts = lib.splitString "," m;
            output = builtins.elemAt parts 0;
            mode = builtins.elemAt parts 1;
            position = builtins.elemAt parts 2;
            scale = builtins.elemAt parts 3;
          in
          ''
            hl.monitor({
              output = "${output}",
              mode = "${mode}",
              position = "${position}",
              scale = ${scale},
            })''
        ) cfg.monitor}

        -- General configuration
        hl.config({
          general = {
            gaps_in = 5,
            gaps_out = 20,
            border_size = 2,
            ["col.active_border"] = colors.lavender,
            ["col.inactive_border"] = colors.overlay0,
            layout = "dwindle",
            allow_tearing = false,
          },

          input = {
            follow_mouse = false,
          },

          decoration = {
            rounding = 10,
            blur = {
              enabled = true,
              size = 3,
              passes = 1,
            },
          },

          animations = {
            enabled = true,
          },

          dwindle = {
            pseudotile = true,
            preserve_split = true,
          },

          master = {
            orientation = "center",
          },
        })

        -- Bezier curves and animations
        hl.bezier({ name = "myBezier", points = { 0.05, 0.9, 0.1, 1.05 } })
        hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
        hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
        hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
        hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

        -- Window rules
        hl.windowrule({ rule = "suppress_event maximize", match = { class = ".*" } })
        hl.windowrule({ rule = "idleinhibit fullscreen", match = { class = ".*" } })

        -- Gesture
        hl.gesture({ fingers = 3, direction = "horizontal", action = hl.dsp.workspace("m+1") })

        -- Keybindings: Applications
        hl.bind(mod .. ", Return", hl.dsp.exec("${terminal}"))
        hl.bind(mod .. ", c", hl.dsp.killactive())
        hl.bind(mod .. ", p", hl.dsp.exec("${menu}"))
        hl.bind(mod .. ", d", hl.dsp.exec("${emoji_picker}"))
        hl.bind(mod .. ", z", hl.dsp.exec("hyprctl reload"))

        -- Move workspace across monitors
        hl.bind(mod .. ", semicolon", hl.dsp.movecurrentworkspacetomonitor("+1"))

        -- Focus movement
        hl.bind(mod .. ", ${left}", hl.dsp.movefocus("l"))
        hl.bind(mod .. ", ${down}", hl.dsp.movefocus("d"))
        hl.bind(mod .. ", ${up}", hl.dsp.movefocus("u"))
        hl.bind(mod .. ", ${right}", hl.dsp.movefocus("r"))

        -- Window movement
        hl.bind(mod .. " + SHIFT, ${left}", hl.dsp.movewindow("l"))
        hl.bind(mod .. " + SHIFT, ${down}", hl.dsp.movewindow("d"))
        hl.bind(mod .. " + SHIFT, ${up}", hl.dsp.movewindow("u"))
        hl.bind(mod .. " + SHIFT, ${right}", hl.dsp.movewindow("r"))

        -- Workspace navigation (qwertyuio)
        hl.bind(mod .. ", q", hl.dsp.workspace(1))
        hl.bind(mod .. ", w", hl.dsp.workspace(2))
        hl.bind(mod .. ", e", hl.dsp.workspace(3))
        hl.bind(mod .. ", r", hl.dsp.workspace(4))
        hl.bind(mod .. ", t", hl.dsp.workspace(5))
        hl.bind(mod .. ", y", hl.dsp.workspace(6))
        hl.bind(mod .. ", u", hl.dsp.workspace(7))
        hl.bind(mod .. ", i", hl.dsp.workspace(8))
        hl.bind(mod .. ", o", hl.dsp.workspace(9))

        -- Move to workspace
        hl.bind(mod .. " + SHIFT, q", hl.dsp.movetoworkspace(1))
        hl.bind(mod .. " + SHIFT, w", hl.dsp.movetoworkspace(2))
        hl.bind(mod .. " + SHIFT, e", hl.dsp.movetoworkspace(3))
        hl.bind(mod .. " + SHIFT, r", hl.dsp.movetoworkspace(4))
        hl.bind(mod .. " + SHIFT, t", hl.dsp.movetoworkspace(5))
        hl.bind(mod .. " + SHIFT, y", hl.dsp.movetoworkspace(6))
        hl.bind(mod .. " + SHIFT, u", hl.dsp.movetoworkspace(7))
        hl.bind(mod .. " + SHIFT, i", hl.dsp.movetoworkspace(8))
        hl.bind(mod .. " + SHIFT, o", hl.dsp.movetoworkspace(9))

        -- Layout
        hl.bind(mod .. ", g", hl.dsp.exec("${layout_toggle_script}/bin/layout-toggle"))
        hl.bind(mod .. ", v", hl.dsp.togglesplit())
        hl.bind(mod .. ", f", hl.dsp.fullscreen())
        hl.bind(mod .. " + SHIFT, f", hl.dsp.togglefloating())

        -- Screenshots
        hl.bind(mod .. ", period", hl.dsp.exec('${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/screenshots/"$(date -u --iso-8601=seconds)".png && ${pkgs.libnotify}/bin/notify-send "Screenshot saved"'))
        hl.bind(mod .. " + SHIFT, period", hl.dsp.exec('${pkgs.grim}/bin/grim ~/screenshots/"$(date -u --iso-8601=seconds)".png && ${pkgs.libnotify}/bin/notify-send "Screenshot saved"'))

        -- Notifications
        hl.bind(mod .. " + SHIFT, n", hl.dsp.exec("${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"))
        hl.bind(mod .. " + SHIFT, d", hl.dsp.exec("${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw"))

        -- Session management
        hl.bind(mod .. " + SHIFT, x", hl.dsp.exit())
        hl.bind(mod .. ", x", hl.dsp.exec("${pkgs.hyprlock}/bin/hyprlock"))

        -- Special workspace (scratchpad)
        hl.bind(mod .. " + SHIFT, minus", hl.dsp.movetoworkspace("special:magic"))
        hl.bind(mod .. ", minus", hl.dsp.togglespecialworkspace("magic"))

        -- Media keys (locked bindings)
        hl.bind(", XF86AudioRaiseVolume", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --output-volume 5"), { locked = true })
        hl.bind(", XF86AudioLowerVolume", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --output-volume -5"), { locked = true })
        hl.bind(", XF86AudioMute", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"), { locked = true })
        hl.bind(", XF86AudioPrev", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --playerctl previous"), { locked = true })
        hl.bind(", XF86AudioNext", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --playerctl next"), { locked = true })
        hl.bind(", XF86AudioPlay", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --playerctl play-pause"), { locked = true })
        hl.bind(", XF86MonBrightnessDown", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --brightness lower"), { locked = true })
        hl.bind(", XF86MonBrightnessUp", hl.dsp.exec("${pkgs.swayosd}/bin/swayosd-client --brightness raise"), { locked = true })
      '';
    };

    # Hyprpaper configuration for wallpaper
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = true;
        splash = false;
        wallpaper = [
          {
            path = "${config.xdg.dataHome}/${cfg.wallpaperPath}";
            monitor = "";
          }
        ];
      };
    };

    xdg.configFile."swayosd/style.css".text = ''
      window#osd {
        border-radius: 999px;
        border: none;
        background: rgba(30, 30, 46, 0.8); }
        window#osd #container {
          margin: 16px; }
        window#osd image,
        window#osd label {
          color: #cdd6f4; }
        window#osd progressbar:disabled,
        window#osd image:disabled {
          opacity: 0.5; }
        window#osd progressbar,
        window#osd segmentedprogress {
          min-height: 6px;
          border-radius: 999px;
          background: transparent;
          border: none; }
        window#osd trough,
        window#osd segment {
          min-height: inherit;
          border-radius: inherit;
          border: none;
          background: rgba(49, 50, 68, 0.8); }
        window#osd progress,
        window#osd segment.active {
          min-height: inherit;
          border-radius: inherit;
          border: none;
          background: #9399b2; }
        window#osd segment {
          margin-left: 8px; }
          window#osd segment:first-child {
            margin-left: 0; }
    '';

    services.swayosd = {
      enable = true;
      stylePath = "${config.xdg.configHome}/${config.xdg.configFile."swayosd/style.css".target}";
    };
  };
}
