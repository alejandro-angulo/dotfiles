{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.rofi;
in {
  options.${namespace}.programs.rofi = {
    enable = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      # TODO: How to ensure this font is installed?
      font = "Hack Nerd Font 10";
      theme = "gruvbox-dark-hard";
      extraConfig = {
        show-icons = true;
      };
    };
  };
}
