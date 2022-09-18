{
  config,
  pkgs,
  ...
}: {
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
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -i ${config.home.homeDirectory}/wallpaper.png";
      }
      {
        timeout = 600;
        command = "${pkgs.swaymsg}/bin/swaymsg 'ouput * dpms off'";
        resumeCommand = "${pkgs.swaymsg}/bin/swaymsg 'output * dpms on'";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
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

      colors = {
        focused = {
          border = "#484848";
          background = "#2B3C44";
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

      output = {
        "*".bg = "${config.home.homeDirectory}/wallpaper.png fill";
        "eDP-1".scale = "1";

        "Dell Inc. DELL S2721QS 47W7M43" = {
          transform = "270";
          position = "1920 0";
        };
        "Dell Inc. DELL S2721QS 4FR7M43".position = "4080 830";
      };
    };
  };
}