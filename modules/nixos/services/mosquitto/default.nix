{
  config,
  lib,
  ...
}:
let
  cfg = config.aa.services.mosquitto;
in
{
  options.aa.services.mosquitto = with lib; {
    enable = mkEnableOption "home assistant";
  };
  config = lib.mkIf cfg.enable {
    age.secrets = {
      hass_mqtt.file = ../../../../secrets/hass_mqtt.age;
      teslamate_mqtt.file = ../../../../secrets/teslamate_mqtt.age;
      zigbee2mqtt_mqtt.file = ../../../../secrets/zigbee2mqtt_mqtt.age;
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users = {
            hass = {
              acl = [
                "readwrite home/#"
                "readwrite homeassistant/#"
                "readwrite zigbee2mqtt/#"
                "read teslamate/#"
              ];
              passwordFile = config.age.secrets.hass_mqtt.path;
            };
            teslamate = {
              acl = [ "readwrite teslamate/#" ];
              passwordFile = config.age.secrets.teslamate_mqtt.path;
            };
            zigbee2mqtt = {
              acl = [
                # "readwrite" "home/#"
                "readwrite zigbee2mqtt/#"
                "readwrite homeassistant/#"
              ];
              passwordFile = config.age.secrets.zigbee2mqtt_mqtt.path;
            };
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
