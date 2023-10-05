{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.hardware.logitech;
in {
  options.aa.hardware.logitech = with types; {
    enable = mkEnableOption "logitech devices";
  };

  config = mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    systemd.user.services.solaar = {
      description = "Linux device manager for Logitech devices";
      documentation = ["https://pwr-solaar.github.io/Solaar/"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
      };
    };
    systemd.user.services.solaar.wantedBy = mkIf config.aa.desktop.sway.enable ["sway-session.target"];
  };
}
