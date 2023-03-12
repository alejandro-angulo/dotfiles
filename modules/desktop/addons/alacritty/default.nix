{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.alacritty;
in {
  options.aa.desktop.addons.alacritty = with types; {
    enable = mkEnableOption "alacritty";
  };

  config = mkIf cfg.enable {
    aa.desktop.addons.fonts.enable = true;

    aa.home = {
      extraOptions = {
        programs.alacritty = {
          enable = true;
          settings = {
            window.opacity = 0.9;
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
      };
    };
  };
}
