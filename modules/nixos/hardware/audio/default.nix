{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.hardware.audio;
in {
  options.aa.hardware.audio = with types; {
    enable = mkEnableOption "audio";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [pamixer];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
