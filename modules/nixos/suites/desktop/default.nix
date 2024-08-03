{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aa.suites.desktop;
in {
  options.aa.suites.desktop = {
    enable = mkEnableOption "common desktop configuration";
  };

  config = mkIf cfg.enable {
    aa = {
      desktop = {
        sway.enable = true;
      };
    };

    # The following fixes an issue with using swaylcock as a home module
    # Workaround for https://github.com/NixOS/nixpkgs/issues/158025
    # This comment specifically: https://github.com/NixOS/nixpkgs/issues/158025#issuecomment-1344766809
    security.pam.services.swaylock = {};
  };
}
