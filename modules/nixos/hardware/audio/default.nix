{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aa.hardware.audio;
in
{
  options.aa.hardware.audio = {
    enable = mkEnableOption "audio";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ pamixer ];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
