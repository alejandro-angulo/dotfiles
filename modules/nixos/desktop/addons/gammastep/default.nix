{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.gammastep;
in {
  options.aa.desktop.addons.gammastep = with types; {
    enable = mkEnableOption "gammastep";
  };

  config = mkIf cfg.enable {
    services.geoclue2.enable = true;

    aa.home.extraOptions = {
      services.gammastep = {
        enable = true;
        provider = "geoclue2";
      };
    };
  };
}
