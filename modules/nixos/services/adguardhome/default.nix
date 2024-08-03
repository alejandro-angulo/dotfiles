{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;

  cfg = config.${namespace}.services.adguardhome;
in {
  options.${namespace}.services.adguardhome = {
    enable = mkEnableOption "adguardhome";
    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      mutableSettings = true;
      host = "0.0.0.0";
      port = 3000;
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."adguardhome.kilonull.com" =
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    networking.firewall = {
      # TODO: Remove this here and leave it up to systems to decide to enable
      # the firewall
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
