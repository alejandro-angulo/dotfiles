{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = {
    enable = mkEnableOption "common desktop configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        sway.enable = true;
      };
    };

    # Required to use gammastep home module without providing lat/long
    services.geoclue2.enable = true;

    # The following fixes an issue with using swaylcock as a home module
    # Workaround for https://github.com/NixOS/nixpkgs/issues/158025
    # This comment specifically: https://github.com/NixOS/nixpkgs/issues/158025#issuecomment-1344766809
    security.pam.services.swaylock = {};
  };
}
