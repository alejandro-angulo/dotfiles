{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.tools.exa;
in {
  options.aa.tools.exa = with types; {
    enable = mkEnableOption "exa";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.exa = {
        enable = true;
        icons = true;
        git = true;
        enableAliases = true;
      };
    };
  };
}
