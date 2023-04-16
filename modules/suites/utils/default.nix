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
    environment.systemPackages = with pkgs; [
      alejandra
      bat
      curl
      deploy-rs
      fd
      file
      htop
      jq
      killall
      pre-commit
      ripgrep
      usbutils
      wget
    ];
  };
}
