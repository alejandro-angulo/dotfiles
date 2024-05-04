{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.security.acme;
in {
  options.aa.security.acme = with types; {
    enable = mkEnableOption "Automatic Certificate Management Environment (ACME)";
    useStaging = mkOption {
      type = bool;
      description = ''
        Use the staging environment (use when configuring for the first time to
        avoid being locked out).
      '';
      default = false;
    };
    domainName = mkOption {
      type = str;
      description = "The domain to request a wildcard cert for.";
    };
    isWildcard = mkOption {
      type = bool;
      default = true;
      description = "Whether or not to request a wildcard cert.";
    };
    dnsCredentialsFile = mkOption {
      type = path;
      description = "The path to the credentials file for the DNS provider.";
    };
  };

  # Only supports exactly one wildcard cert using Cloudflare (only use case I have)
  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = config.aa.user.email;
        group = "nginx";
        server = mkIf cfg.useStaging "https://acme-staging-v02.api.letsencrypt.org/directory";
      };

      # Wildcard cert
      certs."${cfg.domainName}" = {
        group = "nginx";
        dnsProvider = "cloudflare";
        # Private network resolves *.kilonull.com to private servers but `lego`
        # (acme client under the hood) needs to find the cloudflare nameservers
        # to determine the correct zone to apply changes in. Use cloudflare's
        # own DNS to make `lego` happy (will resolve names to a public IP).
        dnsResolver = "1.1.1.1:53";
        credentialsFile = cfg.dnsCredentialsFile;
        extraDomainNames = mkIf cfg.isWildcard [("*." + cfg.domainName)];
      };
    };
  };
}
