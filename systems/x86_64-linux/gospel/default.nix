# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./zfs.nix
    ./vpn.nix
  ];

  aa = {
    nix.enable = true;

    suites.desktop.enable = true;
    suites.gaming.enable = true;

    tools.git.enable = true;
    tools.zsh.enable = true;
    tools.exa.enable = true;

    apps.neovim.enable = true;
    apps.tmux.enable = true;

    services.openssh.enable = true;
    services.nix-serve = {
      enable = true;
      domain_name = "kilonull.com";
      subdomain_name = "gospel";
    };
    services.printing.enable = true;

    hardware.audio.enable = true;
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv6l-linux"];

  networking.hostName = "gospel"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  virtualisation.docker = {
    # TODO: How to make sure docker systemd service is enabled for user?
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # fonts.fonts = with pkgs; [
  #   (nerdfonts.override {fonts = ["Hack"];})
  # ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    killall
    usbutils
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
    file
  ];


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
