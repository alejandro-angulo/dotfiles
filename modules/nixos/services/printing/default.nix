{
  config,
  lib,
  ...
}: let
  cfg = config.aa.apps.steam;
in {
  options.aa.services.printing = with lib; {
    enable = mkEnableOption "printing";
  };

  config = lib.mkIf cfg.enable {
    # Setup printing over the network
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
