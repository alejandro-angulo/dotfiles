{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.suites.utils;
in {
  options.aa.suites.utils = with lib.types; {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    aa.apps.bat.enable = true;
    environment.systemPackages = with pkgs; [
      alejandra
      curl
      deploy-rs
      fd
      file
      htop
      jq
      killall
      pre-commit
      python3
      ripgrep
      usbutils
      wget
    ];
  };
}
