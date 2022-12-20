{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gnupg
    pinentry-curses
  ];

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      # Fix conflicts with config in common/yubikey.nix
      disable-ccid = true;
    };
  };

  programs.ssh.matchBlocks = [
    {
      "github.com" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbpuKWQFiYhNfKXcYpjWFXsYMh7pyhXdGyV8JPBFzgl";
      };
    }
  ];

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableZshIntegration = true;
    enableSshSupport = true;
    sshKeys = [
      # run `gpg-connect-agent 'keyinfo --list' /bye` to get these values for existing keys
      "E274D5078327CB6C8C83CFF102CC12A2D493C77F"
    ];
  };
}
