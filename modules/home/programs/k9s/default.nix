{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.programs.k9s;
in
{
  options.${namespace}.programs.k9s = {
    enable = lib.mkEnableOption "k9s";
  };

  config = lib.mkIf cfg.enable {
    programs.k9s.enable = true;
    catppuccin.k9s = {
      enable = true;
      transparent = true;
    };
  };
}
