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
    environment.systemPackages = [pkgs.zfs-prune-snapshots];

    services.zfs = {
      autoScrub.enable = true;
      # Still need to set `com.sun:auto-snapshot` to `true` on datasets
      # zfs set com.sun:auto-snapshot=true pool/dataset
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
      };
    };
  };
}
