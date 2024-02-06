{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.steam;
in {
  options.aa.services.printing = with types; {
    enable = mkEnableOption "printing";
  };

  config = mkIf cfg.enable {
    # Setup printing over the network
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
