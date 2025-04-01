{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aa.services.nix-serve;
in
{
  options.aa.services.nix-serve = with lib; {
    enable = mkEnableOption "nix-serve";
    domain_name = mkOption {
      type = types.str;
      description = "The domain to use.";
    };
    subdomain_name = mkOption {
      type = types.str;
      description = "The subdomain to use.";
    };
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
    nix.settings = {
      allowed-users = [ "nix-serve" ];
      trusted-users = [ "nix-serve" ];
    };

    environment.systemPackages = [ pkgs.nix-serve ];

    services = {
      nix-serve = {
        enable = true;
        # TODO: Document this or automate the inital creation.
        secretKeyFile = "/var/gospelCache";
      };

      nginx = {
        enable = true;
        virtualHosts."${cfg.subdomain_name}.${cfg.domain_name}" =
          {
            serverAliases = [ "${cfg.subdomain_name}" ];
            locations."/".extraConfig = ''
              proxy_pass http://localhost:${toString config.services.nix-serve.port};
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          }
          // lib.optionalAttrs (cfg.acmeCertName != "") {
            forceSSL = true;
            useACMEHost = cfg.acmeCertName;
          };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
