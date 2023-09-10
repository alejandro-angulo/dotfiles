{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.waybar;
in {
  options.aa.desktop.addons.waybar = with types; {
    enable = mkEnableOption "waybar";

    thermal-zone = mkOption {
      type = int;
      default = 0;
      description = "The thermal zone, as in `/sys/class/thermal/`.";
    };
  };

  config = mkIf cfg.enable {
    aa.system.fonts.enable = true;

    aa.home = {
      extraOptions = {
        programs.waybar = {
          enable = true;
          systemd.enable = true;

          style = builtins.readFile ./waybar_style.css;

          settings = [
            {
              layer = "top";
              position = "bottom";
              height = 20;
              modules-left = ["sway/workspaces"];
              modules-center = ["clock"];
              modules-right = [
                "idle_inhibitor"
                "temperature"
                "cpu"
                "pulseaudio"
                "battery"
                "memory"
                "backlight"
                "network"
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
                  urgent = " ";
                  focused = " ";
                  default = " ";
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
                format-icons = [" " " " " "];
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
                  default = [" " " " " "];
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
                format-icons = [" " " " " " " " " "];
              };

              memory = {
                format = " {}%";
              };

              backlight = {
                format = "{icon} {percent}%";
                format-icons = ["󰃞`" "󰃚"];
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

              tray = {
                spacing = 10;
              };
            }
          ];
        };

        wayland.windowManager.sway.config.bars = [];
      };
    };
  };
}
