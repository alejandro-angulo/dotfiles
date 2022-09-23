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

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableZshIntegration = true;
    enableSshSupport = true;
  };
}
