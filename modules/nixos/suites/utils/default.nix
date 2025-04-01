{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aa.suites.utils;
in
{
  options.aa.suites.utils = {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        bat
        bind # for dig
        curl
        deploy-rs
        du-dust
        fd
        file
        gnupg
        htop
        jq
        killall
        lsof
        nixfmt-rfc-style
        pre-commit
        progress
        python3
        ripgrep
        sqlite
        tcpdump
        usbutils
        wget
      ])
      ++ [ inputs.agenix.packages.x86_64-linux.default ];
  };
}
