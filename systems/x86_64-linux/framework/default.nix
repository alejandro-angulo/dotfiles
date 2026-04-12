{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration-zfs.nix
    # ./zfs.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  aa = {
    nix = {
      enable = true;
      useSelfhostedCache = true;
      remoteBuilder.client.enable = false;
    };

    archetypes.workstation.enable = true;

    # services.printing.enable = true;
    services.tailscale = {
      enable = true;
      configureClientRouting = true;
    };

    hardware.audio.enable = true;
    hardware.bluetooth.enable = true;

    # system.zfs.enable = true;
    apps.yubikey.enable = true;

    user.extraGroups = [
      "dialout"
      "video"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.fwupd.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true; # Enables wireless support via wpa_supplicant.
  };

  # This service is problematic
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  # services.tlp.settings = {
  #   USB_DENYLIST = "0000:1111 2222:3333 4444:5555";
  # };
  # Still need to run `nix run nixpkgs#bolt -- enroll DEVICE_UUID`
  services.hardware.bolt.enable = true;

  services.power-profiles-daemon.enable = lib.mkForce false;

  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pavucontrol
    # android-tools
    # sanoid
    # # Below 3 installed for sanoid
    # pv
    # lzop
    # mbuffer

    # wireguard-tools

    chromium
    # prusa-slicer
    traceroute
    gnumake
    hugo
    nixos-generators
    vlc
    signal-desktop
    # zoom-us
  ];
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
