{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aa.suites.utils;
in {
  options.aa.suites.utils = {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        alejandra
        bat
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
      ])
      ++ [inputs.agenix.packages.x86_64-linux.default];
  };
}
