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
      type = types.listOf (types.attrsOf types.anything);
      default = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
      example = [
        {
          output = "DP-1";
          mode = "1920x1080@144";
          position = "0x0";
          scale = 1;
        }
      ];
      description = ''
        Monitor configuration for Hyprland. Each entry is rendered as an
        `hl.monitor(...)` call, see `HL.MonitorSpec` in Hyprland's Lua API.
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

    # The catppuccin hyprland module requires the global `catppuccin.enable`.
    # `autoEnable` is set to keep every other port opt-in (otherwise setting
    # the global enable would default-enable all catppuccin ports).
    catppuccin.enable = true;
    # catppuccin.autoEnable = false;
    # catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      systemd.variables = [ "--all" ];

      settings =
        let
          inherit (lib.generators) mkLuaInline;

          # hl.bind(mod .. " + <key>", <dispatcher>)
          mkModBind = key: dispatcher: {
            _args = [
              (mkLuaInline ''mod .. " + ${key}"'')
              (mkLuaInline dispatcher)
            ];
          };

          # hl.bind("<key>", <dispatcher>, { locked = true })
          mkLockedBind = key: dispatcher: {
            _args = [
              key
              (mkLuaInline dispatcher)
              { locked = true; }
            ];
          };
        in
        {
          # `local mod = "SUPER"`, referenced by the bindings below
          mod._var = modifier;

          # Monitor configuration
          monitor = cfg.monitor;

          # General settings (rendered as a single `hl.config(...)` call)
          config = {
            general = {
              gaps_in = 5;
              gaps_out = 20;
              border_size = 2;
              col = {
                active_border = mkLuaInline "colors.lavender";
                inactive_border = mkLuaInline "colors.overlay0";
              };
              layout = "dwindle";
              allow_tearing = false;
            };

            # Prevent giving focus to a window just by hovering over it.
            input.follow_mouse = false;

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
            animations.enabled = true;

            # Dwindle layout
            dwindle.preserve_split = true;

            # Master layout
            master.orientation = "center";
          };

          # Animation curve, rendered before `hl.animation(...)` calls
          # ("curve" is in the default `importantPrefixes`)
          curve = {
            _args = [
              "myBezier"
              {
                type = "bezier";
                points = [
                  [
                    0.05
                    0.9
                  ]
                  [
                    0.1
                    1.05
                  ]
                ];
              }
            ];
          };

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 7;
              bezier = "myBezier";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 7;
              bezier = "default";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "borderangle";
              enabled = true;
              speed = 8;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 7;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "default";
            }
          ];

          # Window rules
          window_rule = [
            {
              suppress_event = "maximize";
              match.class = ".*";
            }
            {
              idle_inhibit = "fullscreen";
              match.class = ".*";
            }
          ];

          # Startup
          on = {
            _args = [
              "hyprland.start"
              (mkLuaInline ''
                function()
                  hl.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync")
                  hl.exec_cmd("${pkgs.waybar}/bin/waybar")
                  hl.exec_cmd("${pkgs.hyprpaper}/bin/hyprpaper")
                end
              '')
            ];
          };

          # Keybindings
          bind = [
            # Applications
            (mkModBind "Return" ''hl.dsp.exec_cmd("${terminal}")'')
            (mkModBind "c" "hl.dsp.window.close()")
            (mkModBind "p" ''hl.dsp.exec_cmd("${menu}")'')
            (mkModBind "d" ''hl.dsp.exec_cmd("${emoji_picker}")'')
            (mkModBind "z" ''hl.dsp.exec_cmd("hyprctl reload")'')

            # Move workspace across monitors
            (mkModBind "semicolon" ''hl.dsp.workspace.move({ monitor = "+1" })'')

            # Focus
            (mkModBind "${left}" ''hl.dsp.focus({ direction = "left" })'')
            (mkModBind "${down}" ''hl.dsp.focus({ direction = "down" })'')
            (mkModBind "${up}" ''hl.dsp.focus({ direction = "up" })'')
            (mkModBind "${right}" ''hl.dsp.focus({ direction = "right" })'')

            # Move windows
            (mkModBind "SHIFT + ${left}" ''hl.dsp.window.move({ direction = "left" })'')
            (mkModBind "SHIFT + ${down}" ''hl.dsp.window.move({ direction = "down" })'')
            (mkModBind "SHIFT + ${up}" ''hl.dsp.window.move({ direction = "up" })'')
            (mkModBind "SHIFT + ${right}" ''hl.dsp.window.move({ direction = "right" })'')

            # Workspaces (qwertyuio)
            (mkModBind "q" "hl.dsp.focus({ workspace = 1 })")
            (mkModBind "w" "hl.dsp.focus({ workspace = 2 })")
            (mkModBind "e" "hl.dsp.focus({ workspace = 3 })")
            (mkModBind "r" "hl.dsp.focus({ workspace = 4 })")
            (mkModBind "t" "hl.dsp.focus({ workspace = 5 })")
            (mkModBind "y" "hl.dsp.focus({ workspace = 6 })")
            (mkModBind "u" "hl.dsp.focus({ workspace = 7 })")
            (mkModBind "i" "hl.dsp.focus({ workspace = 8 })")
            (mkModBind "o" "hl.dsp.focus({ workspace = 9 })")

            # Move to workspaces
            (mkModBind "SHIFT + q" ''hl.dsp.window.move({ workspace = "1", follow = true })'')
            (mkModBind "SHIFT + w" ''hl.dsp.window.move({ workspace = "2", follow = true })'')
            (mkModBind "SHIFT + e" ''hl.dsp.window.move({ workspace = "3", follow = true })'')
            (mkModBind "SHIFT + r" ''hl.dsp.window.move({ workspace = "4", follow = true })'')
            (mkModBind "SHIFT + t" ''hl.dsp.window.move({ workspace = "5", follow = true })'')
            (mkModBind "SHIFT + y" ''hl.dsp.window.move({ workspace = "6", follow = true })'')
            (mkModBind "SHIFT + u" ''hl.dsp.window.move({ workspace = "7", follow = true })'')
            (mkModBind "SHIFT + i" ''hl.dsp.window.move({ workspace = "8", follow = true })'')
            (mkModBind "SHIFT + o" ''hl.dsp.window.move({ workspace = "9", follow = true })'')

            # Layout
            (mkModBind "g" ''hl.dsp.exec_cmd("${layout_toggle_script}/bin/layout-toggle")'')
            (mkModBind "f" "hl.dsp.window.fullscreen()")
            (mkModBind "SHIFT + f" ''hl.dsp.window.float({ action = "toggle" })'')

            # Screenshots
            (mkModBind "period" ''
              hl.dsp.exec_cmd([[${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/screenshots/"$(date -u --iso-8601=seconds)".png && ${pkgs.libnotify}/bin/notify-send "Screenshot saved"]])
            '')
            (mkModBind "SHIFT + period" ''
              hl.dsp.exec_cmd([[${pkgs.grim}/bin/grim ~/screenshots/"$(date -u --iso-8601=seconds)".png && ${pkgs.libnotify}/bin/notify-send "Screenshot saved"]])
            '')

            # Notifications
            (mkModBind "SHIFT + n" ''
              hl.dsp.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw")
            '')
            (mkModBind "SHIFT + d" ''
              hl.dsp.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw")
            '')

            (mkModBind "SHIFT + x" "hl.dsp.exit()")
            (mkModBind "x" ''hl.dsp.exec_cmd("${pkgs.hyprlock}/bin/hyprlock")'')

            # Scratchpad
            (mkModBind "SHIFT + minus" ''hl.dsp.window.move({ workspace = "special:magic" })'')
            (mkModBind "minus" ''hl.dsp.workspace.toggle_special("magic")'')

            # Media keys
            (mkLockedBind "XF86AudioRaiseVolume" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --output-volume 5")
            '')
            (mkLockedBind "XF86AudioLowerVolume" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --output-volume -5")
            '')
            (mkLockedBind "XF86AudioMute" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle")
            '')
            (mkLockedBind "XF86AudioPrev" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --playerctl previous")
            '')
            (mkLockedBind "XF86AudioNext" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --playerctl next")
            '')
            (mkLockedBind "XF86AudioPlay" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --playerctl play-pause")
            '')
            (mkLockedBind "XF86MonBrightnessDown" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --brightness lower")
            '')
            (mkLockedBind "XF86MonBrightnessUp" ''
              hl.dsp.exec_cmd("${pkgs.swayosd}/bin/swayosd-client --brightness raise")
            '')
          ];

          gesture = {
            fingers = 3;
            direction = "horizontal";
            action = "workspace";
          };
        };
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
