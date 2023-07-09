{
  options,
  config,
  lib,
  pkgs,
  inputs,
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
      inputs.agenix.packages.x86_64-linux.default
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
      lsof
      bind # for dig
      tcpdump
    ];
  };
}
