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

  cfg = config.${namespace}.programs.hyprlock;
in
{
  options.${namespace}.programs.hyprlock = {
    enable = mkEnableOption "hyprlock";

    wallpaperPath = mkOption {
      type = types.str;
      default = "hyprland/wallpaper.jpg";
      description = ''
        Path to wallpaper, relative to xdg.dataHome
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Additional hyprlock configuration settings
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.hyprlock ];

    catppuccin.hyprlock.enable = true;

    programs.hyprlock = {
      enable = true;
      settings = lib.mkMerge [
        {
          general = {
            hide_cursor = false;
            ignore_empty_input = false;
            text_trim = true;
            fractional_scaling = 2;
            fail_timeout = 2000;
          };

          auth = {
            pam = {
              enabled = true;
              module = "hyprlock";
            };
            fingerprint = {
              enabled = false;
              ready_message = "(Scan fingerprint to unlock)";
              present_message = "Scanning fingerprint";
            };
          };

          background = [
            {
              monitor = "";
              path = "${config.xdg.dataHome}/${cfg.wallpaperPath}";
              color = "rgba(17, 17, 17, 1.0)";
              blur_passes = 2;
              blur_size = 7;
              noise = 0.0117;
              contrast = 0.8916;
              brightness = 0.8172;
              vibrancy = 0.1696;
              vibrancy_darkness = 0.05;
            }
          ];

          # Time label
          label = [
            {
              monitor = "";
              text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
              color = "$text";
              font_size = 120;
              font_family = "Hack Nerd Font";
              position = "0, 300";
              halign = "center";
              valign = "center";
            }
            # Date label
            {
              monitor = "";
              text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
              color = "$text";
              font_size = 24;
              font_family = "Hack Nerd Font";
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
          ];
        }
        cfg.settings
      ];
    };
  };
}
