{
  config,
  lib,
  namespace,
  inputs,
  ...
}:
let
  cfg = config.${namespace}.programs.fzf;
  colors =
    lib.attrsets.mapAttrs
      (
        _: color: inputs.catppuccin-nix-palette.lib.palette.${config.catppuccin.flavor}.colors.${color}.hex
      )
      {
        "bg+" = "surface0";
        bg = "base";
        spinner = "rosewater";
        hl = config.catppuccin.accent;
        fg = "text";
        header = config.catppuccin.accent;
        info = config.catppuccin.accent;
        pointer = config.catppuccin.accent;
        marker = config.catppuccin.accent;
        "fg+" = "text";
        prompt = config.catppuccin.accent;
        "hl+" = config.catppuccin.accent;
      };
in
{
  options.${namespace}.programs.fzf = {
    enable = lib.mkEnableOption "fzf";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      inherit colors;
      enable = true;
    };
  };
}
