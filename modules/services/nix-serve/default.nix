{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.nix-serve;
in {
  options.aa.services.nix-serve = with types; {
    enable = mkEnableOption "nix-serve";
    domain_name = mkOption {
      type = str;
      description = "The domain to use.";
    };
    subdomain_name = mkOption {
      type = str;
      description = "The subdomain to use.";
    };
  };

  config = mkIf cfg.enable {
    nix.settings.allowed-users = ["nix-serve"];

    services = {
      nix-serve = {
        enable = true;
        # TODO: Document this or automate the inital creation.
        secretKeyFile = "/var/gospelCache";
      };

      nginx = {
        enable = true;
        virtualHosts = {
          "${cfg.subdomain_name}.${cfg.domain_name}" = {
            serverAliases = ["${cfg.subdomain_name}"];
            locations."/".extraConfig = ''
              proxy_pass http://localhost:${toString config.services.nix-serve.port};
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [80];
    };
  };
}
