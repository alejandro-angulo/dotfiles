{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.services.playerctld;
in
{
  options.${namespace}.services.playerctld = {
    enable = mkEnableOption "playerctl";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.playerctl ];
    services.playerctld.enable = true;
  };
}
