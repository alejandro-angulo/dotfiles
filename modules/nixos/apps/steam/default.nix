{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.aa.apps.steam;
in
{
  options.aa.apps.steam = {
    enable = lib.options.mkEnableOption "steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
