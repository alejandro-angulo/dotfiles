{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.tools.gpg;
  user = config.aa.user;
in {
  options.aa.tools.gpg = with types; {
    enable = mkEnableOption "gpg";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [gnupg pinentry-curses];

    aa.home.extraOptions = {
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

      services.gpg-agent = {
        enable = true;
        pinentryFlavor = "curses";
        enableZshIntegration = true; # TODO: Only set if using zsh
        enableSshSupport = true;
        sshKeys = [
          # run `gpg-connect-agent 'keyinfo --list' /bye` to get these values for existing keys
          "E274D5078327CB6C8C83CFF102CC12A2D493C77F"
        ];
      };
    };
  };
}
