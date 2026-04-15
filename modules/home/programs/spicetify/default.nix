{
  config,
  lib,
  namespace,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.programs.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.${namespace}.programs.spicetify = {
    enable = lib.mkEnableOption "spicetify";
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      colorScheme = "mocha";
      theme = spicePkgs.themes.catppuccin;
      enabledExtensions = with spicePkgs.extensions; [
        keyboardShortcut
        shuffle
      ];
    };
  };
}
