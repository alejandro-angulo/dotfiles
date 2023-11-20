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
    nix.useSelfhostedCache = true;

    apps.tmux.enable = true;

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
    services.syncoid = {
      #  sudo -u backups zfs create -o mountpoint=/tank/backups/gospel tank/backups/gospel
      enable = true;
      remoteTargetUser = "backups";
      remoteTargetDatasets = ["tank/backups"];
      remoteTargetPublicKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhA+9O2OBMDH1Xnj6isu36df5TOdZG8aEA4JpN2K60e syncoid@gospel"];
    };
    services.gitea = {
      enable = true;
      acmeCertName = "kilonull.com";
    };

    services.homeassistant = {
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

    tools.zsh.enable = true;
    tools.gpg.enable = true;
    apps.yubikey.enable = true;
  };

  security.pam.enableSSHAgentAuth = true;
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
