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
    nix.enable =  true;
    nix.useSelfhostedCache = true;

    services.openssh.enable = true;
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
