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
      (_: color: inputs.catppuccin-nix-palette.lib.palette.mocha.colors.${color}.hex)
      {
        "bg+" = "surface0";
        bg = "base";
        spinner = "rosewater";
        hl = "mauve";
        fg = "text";
        header = "mauve";
        info = "mauve";
        pointer = "mauve";
        marker = "mauve";
        "fg+" = "text";
        prompt = "mauve";
        "hl+" = "mauve";
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
