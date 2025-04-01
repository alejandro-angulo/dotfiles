{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.${namespace}.programs.waybar;
in
{
  options.aa.programs.waybar = {
    enable = mkEnableOption "waybar";

    thermal-zone = mkOption {
      type = types.int;
      default = 0;
      description = "The thermal zone, as in `/sys/class/thermal/`.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."waybar/catppuccin.css".source = "${pkgs.aa.catppuccin-waybar}/catppuccin.css";

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      style = builtins.readFile ./waybar_style.css;

      settings = [
        {
          layer = "top";
          position = "bottom";
          height = 20;
          modules-left = [ "sway/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "idle_inhibitor"
            "temperature"
            "cpu"
            "pulseaudio"
            "battery"
            "memory"
            "backlight"
            "network"
            "custom/notification"
            "tray"
          ];

          "sway/workspaces" = {
            disable-scroll = false;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "q";
              "2" = "w";
              "3" = "e";
              "4" = "r";
              "5" = "t";
              "6" = "y";
              "7" = "u";
              "8" = "i";
              "9" = "o";
            };
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
          };

          temperature = {
            critical-threshold = 80;
            format = "{icon}{temperatureC}°C";
            format-icons = [
              " "
              " "
              " "
            ];
            thermal-zone = cfg.thermal-zone;
          };

          cpu = {
            format = "  {usage}%";
            tooltip = false;
          };

          pulseaudio = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{icon} {volume}% {format_source}";
            format-bluetooth-muted = "   {volume}% {format_source}";
            format-muted = "  {format_source}";
            format-source = " ";
            format-source-muted = " ";
            format-icons = {
              headphone = " ";
              hands-free = " ";
              headset = " ";
              phone = " ";
              portable = " ";
              car = " ";
              default = [
                " "
                " "
                " "
              ];
            };
            tooltip-format = "{desc}, {volume}%";
            # TODO: Figure out how to get pactl binary?
            on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-right = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            on-click-middle = "pavucontrol";
          };

          battery = {
            states = {
              warning = 30;
              critical = 1;
            };
            format = "{icon} {capacity}%";
            tooltip-format = "{timeTo}, {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = " ";
            format-alt = "{time} {icon}";
            format-icons = [
              " "
              " "
              " "
              " "
              " "
            ];
          };

          memory = {
            format = " {}%";
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = [
              "󰃞`"
              "󰃚"
            ];
            on-scroll-up = "light -A 1";
            on-scroll-down = "light -U 1";
          };

          network = {
            format-wifi = " ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} 󰈀 ";
            format-linked = "{ifname} (No IP)  ";
            format-disconnected = "睊 ";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid} {signalStrength}%";
          };

          "custom/notification" = mkIf config.${namespace}.services.swaync.enable {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
            on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
            on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
            escape = true;
          };

          tray = {
            spacing = 10;
          };
        }
      ];
    };

    wayland.windowManager.sway.config.bars = [ ];
  };
}
