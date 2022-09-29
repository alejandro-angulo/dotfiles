{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.alacritty];

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.6;
      font = {
        size = 11.0;
        normal = {
          family = "Hack Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "Hack Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "Hack Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "Hack Nerd Font";
          style = "Bold Italic";
        };
      };
    };
  };
}
