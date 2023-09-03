{
  config,
  pkgs,
  lib,
  inputs,
  nixpkgs,
  modulesPath,
  ...
}: {
  imports = with inputs; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  # Workaround for issue 109280
  # See here: https://github.com/NixOS/nixpkgs/issues/109280#issuecomment-973636212
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];

  age.secrets.cf_dns_kilonull.file = ../../../secrets/cf_dns_kilonull.age;

  aa = {
    nix.enable = true;
    nix.useSelfhostedCache = true;

    apps.btop.enable = true;
    apps.tmux.enable = true;

    services.tailscale = {
      enable = true;
      configureClientRouting = true;
      configureServerRouting = true;
    };
    services.openssh.enable = true;
    services.octoprint = {
      enable = true;
      acmeCertName = "kilonull.com";
    };

    security.acme = {
      enable = true;
      domainName = "kilonull.com";
      dnsCredentialsFile = config.age.secrets.cf_dns_kilonull.path;
    };

    suites.utils.enable = true;
    tools.zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking = {
    hostName = "pi4";
    useDHCP = false;
    defaultGateway = "192.168.113.1";
    nameservers = ["192.168.113.13" "1.1.1.1"];
    interfaces.end0.ipv4.addresses = [
      {
        address = "192.168.113.42";
        prefixLength = 24;
      }
    ];
  };

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
