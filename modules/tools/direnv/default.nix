{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.tools.direnv;
in {
  options.aa.tools.direnv = with lib.types; {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
