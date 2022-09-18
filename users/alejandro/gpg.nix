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
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
  };
}
