{
  config,
  lib,
  ...
}: let
  cfg = config.aa.services.teslamate;
in {
  options.aa.services.teslamate = with lib; {
    enable = mkEnableOption "teslamate";

    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "teslamate";
      description = ''
        The user that should run teslamate
      '';
    };

    group = mkOption {
      type = types.str;
      default = "teslamate";
      description = ''
        The group that should be assigned to the user running teslamate
      '';
    };

    database = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Database host address
        '';
      };

      name = mkOption {
        type = types.str;
        default = "teslamate";
        description = ''
          The database name
        '';
      };

      user = mkOption {
        type = types.str;
        default = "teslamate";
        description = ''
          The user that should have access to the database
        '';
      };

      passwordFile = mkOption {
        type = types.path;
        description = mdDoc ''
          A file containing the password corresponding to
          {option}`database.user`
        '';
      };

      createDatabase = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to create a local database automatically.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      teslamate_encryption.file = ../../../../secrets/teslamate_encryption.age;
      teslamate_mqtt.file = ../../../../secrets/teslamate_mqtt.age;
    };

    # docker-teslamate is the name of the service generated by the
    # `virtualisation.oci-contianers` block below
    systemd.services."docker-teslamate" = {
      preStart = ''
        mkdir -p /var/lib/teslamate

        # Create file if it doesn't exist, truncate it if does
        touch /var/lib/teslamate/env
        echo "" > /var/lib/teslamate/env

        chmod 600 /var/lib/teslamate/env

        echo ENCRYPTION_KEY="$(cat ${config.age.secrets.teslamate_encryption.path})" >> /var/lib/teslamate/env
        echo DATABASE_PASS="$(cat ${cfg.database.passwordFile})" >> /var/lib/teslamate/env
        echo MQTT_PASSWORD="$(cat ${config.age.secrets.teslamate_mqtt.path})" >> /var/lib/teslamate/env
      '';
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers."teslamate" = {
        image = "ghcr.io/teslamate-org/teslamate:latest";
        environmentFiles = ["/var/lib/teslamate/env"];
        environment = {
          # TODO: Make this configurable
          PORT = "4000";
          DATABASE_USER = cfg.database.user;
          DATABASE_NAME = cfg.database.name;
          DATABASE_HOST = cfg.database.host;
          # TODO: Make this configurable.
          MQTT_HOST = "192.168.113.42";
          MQTT_USERNAME = "teslamate";
          TZ = "America/Los_Angeles";
        };
        extraOptions = ["--cap-drop=all" "--network=host"];
        # TODO: Make this configurable
        ports = ["4000:4000"];
      };
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = {};

    services.postgresql = lib.optionalAttrs cfg.database.createDatabase {
      enable = lib.mkDefault true;

      ensureDatabases = [cfg.database.name];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx = {
      enable = true;
      virtualHosts."teslamate.kilonull.com" =
        {
          locations."/" = {
            recommendedProxySettings = true;
            proxyWebsockets = true;
            # TODO: Make port configurable.
            proxyPass = "http://127.0.0.1:4000";
          };
        }
        // lib.optionalAttrs (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
    };

    networking.firewall.allowedTCPPorts = [4000];
  };
}
