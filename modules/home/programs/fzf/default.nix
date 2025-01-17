{
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.fzf;
in {
  options.${namespace}.programs.fzf = {
    enable = lib.mkEnableOption "fzf";
  };

  config = lib.mkIf cfg.enable {
    catppuccin.fzf.enable = true;
    programs.fzf.enable = true;
  };
}
