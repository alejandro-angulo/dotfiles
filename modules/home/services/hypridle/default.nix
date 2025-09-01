{
  config,
  pkgs,
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

  cfg = config.${namespace}.services.hypridle;
in
{
  options.${namespace}.services.hypridle = {
    enable = mkEnableOption "hypridle";

    lockTimeout = mkOption {
      type = types.int;
      default = 300;
      description = ''
        Timeout in seconds before locking the screen
      '';
    };

    displayTimeout = mkOption {
      type = types.int;
      default = 330;
      description = ''
        Timeout in seconds before turning off the display
      '';
    };

    suspendTimeout = mkOption {
      type = types.int;
      default = 1800;
      description = ''
        Timeout in seconds before suspending the system
      '';
    };
    suspendEnable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to automatically suspend
      '';
    };

    brightnessTimeout = mkOption {
      type = types.int;
      default = 150;
      description = ''
        Timeout in seconds before dimming screen brightness
      '';
    };

    lockCommand = mkOption {
      type = types.str;
      default = "${pkgs.hyprlock}/bin/hyprlock";
      description = ''
        Command to run when locking the screen
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.hypridle ];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${cfg.lockCommand}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
        };

        listener = [
          # Dim screen brightness
          {
            timeout = cfg.brightnessTimeout;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          # Turn off keyboard backlight (if available)
          {
            timeout = cfg.brightnessTimeout;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
          }
          # Lock screen
          {
            timeout = cfg.lockTimeout;
            on-timeout = "loginctl lock-session";
          }
          # Turn off display
          {
            timeout = cfg.displayTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          # Suspend system
          (lib.mkIf cfg.suspendEnable {
            timeout = cfg.suspendTimeout;
            on-timeout = "systemctl suspend";
          })
        ];
      };
    };
  };
}
