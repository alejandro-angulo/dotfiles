{
  config,
  pkgs,
  lib,
  namespace,
  system,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.programs.gpg;
in
{
  options.${namespace}.programs.gpg = {
    enable = mkEnableOption "gpg";
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      scdaemonSettings = {
        # Fix conflicts with config in common/yubikey.nix
        disable-ccid = true;
      };
    };

    programs.ssh.matchBlocks = {
      # Fix for pinentry showing up in wrong terminal
      "*".match = "host * exec \"gpg-connect-agent UPDATESTARTUPTTY /bye\"";
    };

    # gpg-agent configuration does not work on darwin
    # see here: https://github.com/nix-community/home-manager/issues/3864
    services.gpg-agent = mkIf (system == "x86_64-linux") {
      enable = true;
      pinentry.package =
        if
          (
            config.${namespace}.windowManagers.sway.enable || config.${namespace}.windowManagers.hyprland.enable
          )
        then
          pkgs.pinentry-qt
        else
          pkgs.pinentry-curses;
      enableZshIntegration = true;
      enableSshSupport = true;
      sshKeys = [
        # run `gpg-connect-agent 'keyinfo --list' /bye` to get these values for existing keys
        "E274D5078327CB6C8C83CFF102CC12A2D493C77F"
      ];
    };
  };
}
