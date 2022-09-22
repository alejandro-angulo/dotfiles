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
    ./hardware-configuration-zfs.nix
    ./zfs.nix
    ./vpn.nix
  ];

  # Make ready for nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  networking = {
    hostName = "carbon"; # Define your hostname.
    networkmanager.enable = true; # Enables wireless support via wpa_supplicant.

    #wg-quick.interfaces = {
    #wg0 = {
    #address = [ "10.10.13.25/32" ];
    #dns = [ "192.168.113.69" ];
    #listenPort = 51820;
    #privateKeyFile = "/home/alejandro/wireguard_keys/carbon.pub";

    #peers = [
    #{
    #publicKey = "HGm7lx+DbACPxEN7gaiuz4XklV/RdzmBj//FBSO7QUU=";
    #allowedIPs = [ "10.13.13.0/24" "192.168.113.0/24" ];
    #endpoint = "wg.kilonull.com:51820";
    #}
    #];
    #};
    #};
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alejandro = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager"];
    shell = pkgs.zsh;
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["Hack"];})
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim_configurable # Using this instead of vim for python3 support
    wget
    firefox
    wl-clipboard
    stow
    tmux
    zsh
    home-manager
    sanoid
    killall
    usbutils
    # Below 3 installed for sanoid
    pv
    lzop
    mbuffer

    # Installed for gammastep
    geoclue2

    wireguard-tools

    prusa-slicer

    yubikey-manager
    yubikey-agent
    yubico-pam
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh.enable = true;

  programs.light.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako
      alacritty
      rofi
      waybar
      pavucontrol
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi.enable = true;
  services.geoclue2 = {
    enable = true;
    #appConfig."gammastep" = {
    #isAllowed = true;
    #isSystem = true;
    #users = ["1000"];
    #};
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pcscd.enable = true;

  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
    # Uncomment below for 2FA
    #control = "required";
  };
  # To set up, need to run (might need to run as root)
  # ykman otp chalresp --touch --generate 2
  # ykpamcfg -2 -v

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
