{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  age.secrets.cf_dns_kilonull.file = ../../../secrets/cf_dns_kilonull.age;
  age.secrets.gitea-runner-gospel.file = ../../../secrets/gitea-runner-gospel.age;

  aa = {
    nix.enable = true;
    nix.remoteBuilder.enable = true;

    archetypes = {
      workstation.enable = true;
    };

    # TODO: How to inform a home manager module about this?
    # desktop.addons.waybar.thermal-zone = 1;

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
    services.prometheus.enable = true;
    services.promtail.enable = true;
    services.hydra = {
      enable = true;
      acmeCertName = "kilonull.com";
      secretKeyPath = "/var/gospelCache";
      s3Bucket = "nix-store";
      s3Endpoint = "minio.kilonull.com";
    };
    services.sunshine = {
      enable = true;
      acmeCertName = "kilonull.com";
    };

    hardware.audio.enable = true;
    hardware.bluetooth.enable = true;
    hardware.logitech.enable = true;

    system.zfs.enable = true;
    system.monitoring.enable = true;

    user.extraGroups = [
      "dialout"
      "libvirtd"
    ];
  };

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "microbit-udev-rules";
      text = ''
        # CMSIS-DAP for microbit
        ACTION!="add|change", GOTO="microbit_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", TAG+="uaccess"
        LABEL="microbit_rules_end"
      '';
      destination = "/etc/udev/rules.d/69-microbit.rules";
    })
  ];

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances = {
      gospel = {
        enable = true;
        name = config.networking.hostName;
        url = "https://git.alejandr0angul0.dev";
        tokenFile = config.age.secrets.gitea-runner-gospel.path;
        labels = [
          "ubuntu-latest:docker://node:16-bullseye"
          "ubuntu-22.04:docker://node:16-bullseye"
          "ubuntu-20.04:docker://node:16-bullseye"
          "ubuntu-18.04:docker://node:16-buster"
        ];
      };
    };
  };
  virtualisation = {
    libvirtd.enable = true;

    docker = {
      enable = true;
      storageDriver = "overlay2";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  programs.virt-manager.enable = true;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
  ];
  networking = {
    hostName = "gospel";
    defaultGateway = "192.168.113.1";
    networkmanager.enable = true;
    nameservers = [
      "192.168.113.1"
      "1.1.1.1"
    ];
    interfaces.eno1.ipv4.addresses = [
      {
        address = "192.168.113.69"; # nice
        prefixLength = 24;
      }
    ];
  };
  programs.winbox = {
    enable = true;
    openFirewall = true;
  };
  programs.nm-applet.enable = true;

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

    chromium

    unzip
    p7zip
    nix-index

    vlc
    xfce.thunar
    prusa-slicer
    esptool
    minicom
    signal-desktop-bin
    ncdu

    cntr

    bundler
    bundix
    nix-output-monitor

    iw
    wpa_supplicant

    mqttui
    openscad

    zoom-us

    tridactyl-native
  ];

  # TODO: configure xdg portal with home-manager (it's broken rn)
  # see here: https://github.com/nix-community/home-manager/issues/6770
  #
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = "wlr";
      };
    };
    wlr.enable = true;
    wlr.settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # Makes gtk apps happy
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
