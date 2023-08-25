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
      bind # for dig
      curl
      deploy-rs
      du-dust
      fd
      file
      htop
      jq
      killall
      lsof
      pre-commit
      progress
      python3
      ripgrep
      sqlite
      tcpdump
      usbutils
      wget
    ];
  };
}
