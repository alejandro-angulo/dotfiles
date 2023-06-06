{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  aa = {
    nix.enable = true;

    archetypes = {
      workstation.enable = true;
    };

    suites.gaming.enable = true;

    apps.yubikey.enable = true;

    services.openssh.enable = true;
    services.nix-serve = {
      enable = true;
      domain_name = "kilonull.com";
      subdomain_name = "gospel";
    };
    services.printing.enable = true;
    services.tailscale = {
      enable = true;
      configureClientRouting = true;
      configureServerRouting = true;
    };

    hardware.audio.enable = true;

    system.zfs.enable = true;
    system.monitoring.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv6l-linux"];
  networking = {
    hostName = "gospel";
    useDHCP = false;
    defaultGateway = "192.168.113.1";
    nameservers = ["1.1.1.1"];
    interfaces.eno1.ipv4.addresses = [
      {
        address = "192.168.113.69"; # nice
        prefixLength = 24;
      }
    ];
  };

  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pavucontrol
    cachix
    nixos-generators
    # config.nur.repos.mic92.yubikey-touch-detector

    cryptsetup
    paperkey
    unzip
    p7zip
    nix-index

    vlc
    xfce.thunar
    prusa-slicer
    esptool
    minicom
    signal-desktop
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
