{...}: {
  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "f8616592";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = true;
  users.users.root.initialHashedPassword = "$6$3Ps2Vmff.gUBkiCv$FCeCQjDvNTdWynQU81qtCXFHQht86w4unWNalUgkcyq7lkkI2klzRyTK3dZiQUjIrn8qPKtwJcY9SNdyE8v1L/";
}
