{...}: {
  aa = {
    nix.enable = true;

    services = {
      openssh.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    # SSH
    22
  ];

  virtualisation.digitalOcean = {
    setRootPassword = true;
    setSshKeys = true;
  };
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.05";
}
