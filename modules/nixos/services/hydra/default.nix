{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.hydra;
in {
  options.aa.services.hydra = with types; {
    enable = mkEnableOption "hydra";
    hostname = mkOption {
      type = str;
      default = "hydra.kilonull.com";
      description = ''
        The hostname for the hydra instance
      '';
    };
    acmeCertName = mkOption {
      type = str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };
  };

  config = mkIf cfg.enable {
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
      allowed-uris = ["github:"];
    };
  };
}
