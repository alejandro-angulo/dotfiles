{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "b2d25606";
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENX1K539085-part4";
      randomEncryption.enable = true;
    }
    {
      device = "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPTUW-512G_182747800010-part4";
      randomEncryption.enable = true;
    }
  ];
  systemd.services.zfs-mount.enable = false;
  environment.etc."machine-id".source = "/state/etc/machine-id";
  environment.etc."zfs/zpool.cache".source = "/state/etc/zfs/zpool.cache";
  boot.loader.efi.efiSysMountPoint = "/boot/efis/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENX1K539085-part1";
  boot.loader.efi.canTouchEfiVariables = false;
  ##if UEFI firmware can detect entries
  #boot.loader.efi.canTouchEfiVariables = true;

  boot.loader = {
    generationsDir.copyKernels = true;
    ##for problematic UEFI firmware
    grub.efiInstallAsRemovable = true;
    grub.enable = true;
    grub.copyKernels = true;
    grub.efiSupport = true;
    grub.zfsSupport = true;
    grub.extraInstallCommands = ''
      export ESP_MIRROR=$(mktemp -d -p /tmp)
      cp -r /boot/efis/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENX1K539085-part1/EFI $ESP_MIRROR
      for i in /boot/efis/*; do
       cp -r $ESP_MIRROR/EFI $i
      done
      rm -rf $ESP_MIRROR
    '';
    grub.devices = [
      "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENX1K539085"
      "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPTUW-512G_182747800010"
    ];
  };
  users.users.root.initialHashedPassword = "$6$VOzIHqv12iJGQIFl$NQf1GeiGhtdLfZFmtZl4vab.xvtVvI7.5ty9zbMFI2dpmHoFdc6XnGwTlClVe./CbcrsQjtPpt7NKf0dNttcw.";
}
