{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.aa.suites.gaming;
in
{
  options.aa.suites.gaming = with lib.types; {
    enable = mkEnableOption "gaming configuration";
  };

  config = mkIf cfg.enable {
    aa.apps = {
      steam.enable = true;
    };
  };
}
