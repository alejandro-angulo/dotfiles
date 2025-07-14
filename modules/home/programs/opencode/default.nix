{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.programs.opencode;
in
{
  options.${namespace}.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings.theme = "catppuccin";
    };
  };
}
