{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.fonts;
in {
  options.aa.desktop.addons.fonts = with types; {
    enable = mkEnableOption "manage fonts";
  };

  config = mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      (nerdfonts.override {fonts = ["Hack"];})
    ];
  };
}
