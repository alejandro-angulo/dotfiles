{ config, pkgs, ... }:

{
    boot.supportedFilesystems = [ "zfs" ];
    networking.hostId = "db616c9e";
}
