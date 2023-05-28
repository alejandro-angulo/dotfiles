{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.system.fonts;
in {
  options.aa.system.fonts = with types; {
    enable = mkEnableOption "manage fonts";
  };

  config = mkIf cfg.enable {
    fonts.fonts = with pkgs; [
      (nerdfonts.override {fonts = ["Hack"];})
    ];
  };
}
