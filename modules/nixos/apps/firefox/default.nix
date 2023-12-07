{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.firefox;
in {
  options.aa.apps.firefox = with types; {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [firefox];
    aa.home.extraOptions = {
      xdg.mimeApps.defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };
}
