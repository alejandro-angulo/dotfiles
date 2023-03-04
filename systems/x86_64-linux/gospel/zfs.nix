{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "f8616592";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efis
    for i in  /boot/efis/*; do mount $i ; done

    mkdir -p /boot/efi
    mount /boot/efi
  '';
  boot.loader.grub.extraInstallCommands = ''
    ESP_MIRROR=$(mktemp -d)
    cp -r /boot/efi/EFI $ESP_MIRROR
    for i in /boot/efis/*; do
     cp -r $ESP_MIRROR/EFI $i
    done
    rm -rf $ESP_MIRROR
  '';
  boot.loader.grub.devices = [
    "/dev/disk/by-id/nvme-WDC_WDS100T2B0C-00PXH0_21111Y801086"
  ];
  users.users.root.initialHashedPassword = "$6$3Ps2Vmff.gUBkiCv$FCeCQjDvNTdWynQU81qtCXFHQht86w4unWNalUgkcyq7lkkI2klzRyTK3dZiQUjIrn8qPKtwJcY9SNdyE8v1L/";
}
