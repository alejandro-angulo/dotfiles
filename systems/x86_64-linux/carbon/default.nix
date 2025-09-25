{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-zfs.nix
    ./zfs.nix
  ];

  aa = {
    nix = {
      enable = true;
      useSelfhostedCache = true;
      remoteBuilder.client.enable = true;
    };

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
    apps.yubikey.enable = true;
  };

  networking = {
    hostName = "carbon";
    networkmanager.enable = true; # Enables wireless support via wpa_supplicant.
  };

  # This service is problematic
  # See: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  services.tlp.settings = {
    USB_DENYLIST = "0000:1111 2222:3333 4444:5555";
  };
  # Still need to run `nix run nixpkgs#bolt -- enroll DEVICE_UUID`
  services.hardware.bolt.enable = true;

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
    (signal-desktop-bin.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.makeWrapper ];
      postInstall = oldAttrs.postInstall or "" + ''
        wrapProgram $out/bin/signal-desktop \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    }))
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
