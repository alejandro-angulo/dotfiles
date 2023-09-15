{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.tools.eza;
in {
  options.aa.tools.eza = with types; {
    enable = mkEnableOption "eza";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.eza = {
        enable = true;
        icons = true;
        git = true;
        enableAliases = true;
      };
    };
  };
}
