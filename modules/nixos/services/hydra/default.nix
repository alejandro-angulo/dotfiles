{
  config,
  lib,
  ...
}: let
  cfg = config.aa.services.hydra;
in {
  options.aa.services.hydra = with lib; {
    enable = mkEnableOption "hydra";
    hostname = mkOption {
      type = types.str;
      default = "hydra.kilonull.com";
      description = ''
        The hostname for the hydra instance
      '';
    };
    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };

    secretKeyPath = mkOption {
      type = types.str;
      description = ''
        The secret key used to sign builds uploaded to s3.
      '';
    };

    s3Bucket = mkOption {
      type = types.str;
      description = ''
        The s3 bucket name where build artifacts will be uploaded.
      '';
    };

    s3Scheme = mkOption {
      type = types.str;
      default = "https";
      description = ''
        The scheme to use when connecting to s3.
      '';
    };

    s3Endpoint = mkOption {
      type = types.str;
      description = ''
        The s3 server endpoint.

        Should use `amazonaws.com` if using amazon AWS.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      hydra-aws-creds.file = ../../../../secrets/hydra-aws-creds.age;
    };

    # NOTE: Need to create user to allow web configuration
    # sudo -u hydra hydra-create-user alice \
    #   --full-name 'Alice Q. User' \
    #   --email-address 'alice@example.org' \
    #   --password-prompt \
    #   --role admin

    services.hydra = {
      enable = true;
      hydraURL = "https://${cfg.hostname}";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [];
      useSubstitutes = true;
      extraConfig = ''
        store_uri = s3://${cfg.s3Bucket}?compression=zstd&parallel-compression=true&write-nar-listing=1&ls-compression=br&log-compression=br&scheme=${cfg.s3Scheme}&endpoint=${cfg.s3Endpoint}&secret-key=${cfg.secretKeyPath}
      '';
    };

    systemd.services."hydra-queue-runner".serviceConfig = {
      EnvironmentFile = config.age.secrets.hydra-aws-creds.path;
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."hydra.kilonull.com" =
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    nix.settings = {
      allowed-users = [
        "hydra"
        "hydra-www"
      ];
      allowed-uris = ["github:" "https://github.com/"];
    };
  };
}
