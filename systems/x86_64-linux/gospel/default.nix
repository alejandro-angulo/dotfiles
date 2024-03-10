{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  age.secrets.cf_dns_kilonull.file = ../../../secrets/cf_dns_kilonull.age;

  aa = {
    nix.enable = true;

    archetypes = {
      workstation.enable = true;
    };

    desktop.addons.waybar.thermal-zone = 1;

    suites.gaming.enable = true;

    apps.yubikey.enable = true;

    security.acme = {
      enable = true;
      # useStaging = true;
      domainName = "kilonull.com";
      dnsCredentialsFile = config.age.secrets.cf_dns_kilonull.path;
    };

    services.openssh.enable = true;
    services.nix-serve = {
      enable = true;
      domain_name = "kilonull.com";
      subdomain_name = "cache";
      acmeCertName = "kilonull.com";
    };
    services.printing.enable = true;
    services.tailscale = {
      enable = true;
      configureClientRouting = true;
      configureServerRouting = true;
    };
    services.syncoid = {
      enable = true;
      commands = {
        "rpool" = {
          target = "backups@192.168.113.13:tank/backups/gospel/rpool";
          recursive = true;
          sshKey = "/var/lib/syncoid/.ssh/id_ed25519";
        };
      };
    };
    services.prometheus.enable = true;
    services.promtail.enable = true;
    services.hydra = {
      enable = true;
      acmeCertName = "kilonull.com";
      secretKeyPath = "/var/gospelCache";
      s3Bucket = "nix-store";
      s3Endpoint = "minio.kilonull.com";
    };

    hardware.audio.enable = true;
    hardware.bluetooth.enable = true;
    hardware.logitech.enable = true;

    system.zfs.enable = true;
    system.monitoring.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # boot.binfmt.emulatedSystems = ["aarch64-linux" "armv6l-linux"];
  networking = {
    hostName = "gospel";
    useDHCP = false;
    defaultGateway = "192.168.113.1";
    nameservers = ["192.168.113.13" "1.1.1.1"];
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
