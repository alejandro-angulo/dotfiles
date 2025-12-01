{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.services.zigbee2mqtt;
in
{
  options.${namespace}.services.zigbee2mqtt = {
    enable = lib.mkEnableOption "zigbee2mqtt";
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
    age.secrets.zigbee2mqtt_creds = {
      file = ../../../../secrets/zigbee2mqtt_creds.age;
      path = "/var/lib/zigbee2mqtt/secret.yaml";
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0400";
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        version = 4;
        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://192.168.113.42:1883";
          # TODO: Write secret.yaml file
          user = "!secret.yaml user";
          password = "!secret.yaml password";
        };
        serial = {
          port = "tcp://192.168.113.90:6638";
          baudrate = 115200;
          adapter = "ember";
          disable_led = false;
          advanced.transmit_power = 20;
        };
        advanced = {
          channel = 11;
          network_key = "GENERATE";
          pan_id = "GENERATE";
          ext_pan_id = "GENERATE";
        };
        frontend = {
          enabled = true;
          port = 8080;
        };
        homeassistant = {
          enabled = true;
        };
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."zigbee2mqtt.kilonull.com" = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:8080";
        };
      }
      // lib.optionalAttrs (cfg.acmeCertName != "") {
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };
  };
}
