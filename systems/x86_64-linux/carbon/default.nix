{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-zfs.nix
    ./zfs.nix
  ];

  aa = {
    nix.enable = true;
    nix.useSelfhostedCache = true;

    archetypes.workstation.enable = true;

    services.printing.enable = true;
    services.tailscale = {
      enable = true;
      configureClientRouting = true;
    };

    hardware.audio.enable = true;
    hardware.bluetooth.enable = true;
    hardware.tlp.enable = true;

    system.zfs.enable = true;
    apps.btop.enable = true;
    apps.yubikey.enable = true;
  };

  networking = {
    hostName = "carbon";
    networkmanager.enable = true; # Enables wireless support via wpa_supplicant.
  };

  # This service is problematic
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sanoid
    # Below 3 installed for sanoid
    pv
    lzop
    mbuffer

    wireguard-tools

    prusa-slicer
    traceroute
    gnumake
    hugo
    nixos-generators
    vlc
    signal-desktop
  ];

  programs.light.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
