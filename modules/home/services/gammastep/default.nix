{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.services.gammastep;
in
{
  options.${namespace}.services.gammastep = {
    enable = mkEnableOption "gammastep";
  };

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };
  };
}
