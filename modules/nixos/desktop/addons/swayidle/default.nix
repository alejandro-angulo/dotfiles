{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.swayidle;
in {
  options.aa.desktop.addons.swayidle = with types; {
    enable = mkEnableOption "swayidle";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [swayidle];

    aa.home.extraOptions = {
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock";
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
            command = "${pkgs.swaylock}/bin/swaylock";
          }
        ];
      };
    };
  };
}
