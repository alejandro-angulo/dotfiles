{
  config,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];
  networking.hostId = "db616c9e";
}
