{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  age.secrets = {
    cf_dns_kilonull.file = ../../../secrets/cf_dns_kilonull.age;
    teslamate_db.file = ../../../secrets/teslamate_db.age;
  };

  aa = {
    nix.enable = true;
    nix.useSelfhostedCache = true;

    services.tailscale = {
      enable = true;
      configureClientRouting = true;
      configureServerRouting = true;
    };
    services.openssh.enable = true;
    services.adguardhome = {
      enable = true;
      acmeCertName = "kilonull.com";
    };
    services.nextcloud = {
      enable = true;
      acmeCertName = "kilonull.com";
    };
    services.grafana = {
      enable = true;
      acmeCertName = "kilonull.com";
    };
    services.prometheus = {
      enable = true;
      enableServer = true;
    };
    services.loki.enable = true;
    services.promtail.enable = true;
    services.teslamate = {
      enable = true;
      database = {
        createDatabase = true;
        passwordFile = config.age.secrets.teslamate_db.path;
      };
      acmeCertName = "kilonull.com";
    };

    services.homeassistant = {
      enable = true;
      acmeCertName = "kilonull.com";
    };

    services.minio = {
      enable = true;
      acmeCertName = "kilonull.com";
    };

    security.acme = {
      enable = true;
      domainName = "kilonull.com";
      dnsCredentialsFile = config.age.secrets.cf_dns_kilonull.path;
    };

    system.zfs.enable = true;
    system.monitoring.enable = true;

    suites.utils.enable = true;

    apps.yubikey.enable = true;
  };

  # Rewrite specific to this machine (didn't want to put this in my adguardhome
  # module incase I want to reuse it for something else later)
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "octoprint.kilonull.com";
      answer = "192.168.113.42";
    }
    {
      domain = "hydra.kilonull.com";
      answer = "192.168.113.69";
    }
    {
      domain = "cache.kilonull.com";
      answer = "192.168.113.69";
    }
    {
      domain = "*.kilonull.com";
      answer = "192.168.113.13";
    }
  ];

  security.pam.sshAgentAuth = {
    enable = true;
    # Addresses issue 31611
    # See: https://github.com/NixOS/nixpkgs/issues/31611
    authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
  };
  security.pam.services.${config.aa.user.name}.sshAgentAuth = true;

  boot.loader.systemd-boot.enable = true;

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  networking = {
    hostName = "node";
    useDHCP = false;
    defaultGateway = "192.168.113.1";
    nameservers = ["127.0.0.1" "1.1.1.1"];
    interfaces.enp7s0.ipv4.addresses = [
      {
        address = "192.168.113.13";
        prefixLength = 24;
      }
    ];
  };

  # Running own DNS resolver on same system. This prevents DNS issues with ACME
  systemd.services = let
    dependency = ["adguardhome.service"];
  in
    lib.mapAttrs'
    (name: _:
      lib.nameValuePair "acme-${name}" {
        after = dependency;
        preStart = ''
          sleep 10
        '';
      })
    config.security.acme.certs;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
