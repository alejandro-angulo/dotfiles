{
  config,
  namespace,
  lib,
  ...
}:
let
  attic_cfg = config.services.atticd;
  cfg = config.${namespace}.services.atticd;
in
{
  options.${namespace}.services.atticd = {
    enable = lib.mkEnableOption "atticd";
    acmeCertName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.atticd.file = ../../../../secrets/atticd.age;

    services.atticd = {
      enable = true;
      # ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64: The base64-encoded RSA PEM PKCS1 of the RS256 JWT secret. Generate it with openssl genrsa -traditional 4096 | base64 -w0.
      # This file should have the following content:
      #
      # ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=secret
      #
      # The secret is a base64-encoded RSA PEM PKCS1 of the RS256 JWT secret. It
      # can be generated with this command:
      #
      # openssl genrsa -traditional 4096 | base64 -w0
      environmentFile = config.age.secrets.atticd.path;
      settings = {
        allowed-hosts = [ "attic.kilonull.com" ];
        api-endpoint = "https://attic.kilonull.com/";
        listen = "[::]:8080";
        garbage-collection.retention-period = "30d";
        database.url = "postgresql://atticd/?host=/run/postgresql";
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "atticd" ];
      ensureUsers = [
        {
          name = attic_cfg.user;
          ensureDBOwnership = true;
        }
      ];
      identMap = ''
        attic attic attic
      '';
      authentication = ''
        local all attic peer map=attic
      '';
    };

    services.nginx = {
      enable = true;
      virtualHosts."attic.kilonull.com" = {
        extraConfig = ''
          client_max_body_size 0;
        '';
        locations."/" = {
          proxyPass = "http://localhost:8080";
        };
      }
      // lib.optionalAttrs (cfg.acmeCertName != "") {
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };
  };
}
