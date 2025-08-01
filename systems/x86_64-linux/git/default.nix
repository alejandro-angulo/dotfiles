{
  inputs,
  config,
  ...
}:
let
  domain = "git.alejandr0angul0.dev";
in
{
  imports = [ "${inputs.nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix" ];

  aa = {
    nix.enable = true;

    services.forgejo = {
      enable = true;
      domain = domain;
    };

    services.openssh.enable = true;
  };

  nix.settings.auto-optimise-store = true;
  nix.gc.dates = "03:15";
  nix.gc.options = "-d";

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.aa.user.email;
      group = "nginx";
    };
  };

  networking.hostName = "git";
  networking.firewall.allowedTCPPorts = [
    # SSH
    22

    # HTTP(S)
    80
    443
  ];

  virtualisation.digitalOcean = {
    setRootPassword = true;
    setSshKeys = true;
  };
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.05";
}
