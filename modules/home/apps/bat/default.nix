{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.apps.bat;
in
{
  options.${namespace}.apps.bat = {
    enable = mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    catppuccin.bat.enable = true;
    programs.bat.enable = true;
  };
}
