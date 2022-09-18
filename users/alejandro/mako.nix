{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mako
    libnotify
  ];
  # TODO: Add hack nerd font

  programs.mako = {
    enable = true;

    font = "'Hack Nerd Font' Regular 9";

    backgroundColor = "#1D2021F0";
    textColor = "#FFFFDF";
    borderColor = "#1C1C1C";
    borderRadius = 10;

    padding = "10";
  };
}
