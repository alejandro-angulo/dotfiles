{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config."${namespace}".services.sunshine;
in
{
  options."${namespace}".services.sunshine = with lib; {
    enable = mkEnableOption "sunshine";

    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # NOTE: Navigate to localhost:47990 for first time configuration
    services.sunshine = {
      enable = true;
      openFirewall = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts."sunshine.kilonull.com" =
        {
          locations."/" = {
            recommendedProxySettings = true;
            # NOTE: Sunshine is a little weird since it requires multiple
            # ports. You configure it with a base port and the web UI +1 from
            # the base port.
            proxyPass = "https://127.0.0.1:${toString (config.services.sunshine.settings.port + 1)}";
            extraConfig = ''
              proxy_ssl_verify off;
            '';
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };
  };
}
