{
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "db616c9e";
}
