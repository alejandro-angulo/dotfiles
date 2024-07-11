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
    aa.system.fonts.enable = true;

    # alacritty won't start without opengl
    hardware.graphics.enable = true;

    aa.home = {
      extraOptions = {
        programs.alacritty = {
          enable = true;
          settings = {
            window.opacity = 0.95;
            font = {
              size = 12.0;
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
