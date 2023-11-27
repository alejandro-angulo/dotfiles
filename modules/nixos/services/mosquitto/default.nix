{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.mosquitto;
  mosquitto_cfg = config.services.mosquitto;
in {
  options.aa.services.mosquitto = with types; {
    enable = mkEnableOption "home assistant";
  };
  config = mkIf cfg.enable {
    age.secrets = {
      hass_mqtt.file = ../../../../secrets/hass_mqtt.age;
      theengs_ble_mqtt.file = ../../../../secrets/theengs_ble_mqtt.age;
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users = {
            hass = {
              acl = [
                "read home/#"
                "readwrite homeassistant/status"
              ];
              passwordFile = config.age.secrets.hass_mqtt.path;
            };
            theengs_ble_gateway = {
              acl = ["readwrite home/#"];
              passwordFile = config.age.secrets.theengs_ble_mqtt.path;
            };
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [1883];
  };
}
