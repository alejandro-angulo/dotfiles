{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.rofi];
  # TODO: Add Hack Nerd Font

  programs.rofi = {
    enable = true;
    font = "Hack Nerd Font 10";
    theme = "gruvbox-dark-hard";
    extraConfig = {
      show-icons = true;
    };
  };
}
