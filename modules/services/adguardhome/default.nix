{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.adguardhome;
in {
  options.aa.services.adguardhome = with types; {
    enable = mkEnableOption "adguardhome";
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      mutableSettings = true;
      settings = {
        bind_host = "0.0.0.0";
        bind_port = 3000;
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."adguardhome.kilonull.com" = {
        forceSSL = true;
        useACMEHost = "kilonull.com";
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
        };
      };
    };

    # So that nginx has access to the ACME certs
    users.users.nginx.extraGroups = ["acme"];

    age.secrets.cf_dns_kilonull.file = ../../../secrets/cf_dns_kilonull.age;

    security.acme = {
      # NOTE: Uncomment line below when testing changes
      # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      acceptTerms = true;
      defaults.email = "iam@alejandr0angul0.dev";

      # Wildcard cert
      certs."kilonull.com" = {
        dnsProvider = "cloudflare";
        # Private network resolves *.kilonull.com to private servers but `lego`
        # (acme client under the hood) needs to find the cloudflare nameservers
        # to determine the correct zone to apply changes in. Use cloudflare's
        # own DNS to make `lego` happy (will resolve names to a public IP).
        dnsResolver = "1.1.1.1:53";
        credentialsFile = config.age.secrets.cf_dns_kilonull.path;
        extraDomainNames = ["*.kilonull.com"];
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        # Plain DNS
        53
        # DHCP
        68
        # HTTP
        80
        # HTTPS
        443
        # DNS over TLS
        853
        # DNSCrypt
        5443
      ];
      allowedUDPPorts = [
        # Plain DNS
        53
        # DHCP
        67
        68
        # DNS over QUIC
        784
        853
        8853
        # DNSCrypt
        5443
      ];
    };
  };
}
