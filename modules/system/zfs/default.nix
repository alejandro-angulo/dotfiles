{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.system.zfs;
in {
  options.aa.system.zfs = with types; {
    enable = mkEnableOption "zfs";
    # TODO: Introduce a zfsOnRoot option
  };

  config = mkIf cfg.enable {
    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}
