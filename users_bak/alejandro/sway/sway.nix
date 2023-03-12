{
  config,
  pkgs,
  ...
}: let
  wallpaper = "${config.home.homeDirectory}/dotfiles/users/alejandro/sway/wallpaper.png";
in {
  imports = [
    ./keybindings.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    #light  # TODO: Not enough to have this package, need it enabled in system config.
    pamixer
    playerctl
    rofi
    swaylock
    wl-clipboard
  ];

  services.playerctld.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -i ${wallpaper}";
      }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -i ${wallpaper}";
      }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    swaynag.enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly

    config = {
      modifier = "Mod4";
      terminal = "alacritty"; # TODO: include in packages above?
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

      output = {
        "*".bg = "${wallpaper} fill";
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
    };
  };
}
