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
      theengs_ble_mqtt.file = ../../../../secrets/theengs_ble_mqtt.age;
      teslamate_mqtt.file = ../../../../secrets/teslamate_mqtt.age;
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
                "read teslamate/#"
              ];
              passwordFile = config.age.secrets.hass_mqtt.path;
            };
            theengs_ble_gateway = {
              acl = [
                "readwrite home/#"
                "readwrite homeassistant/#"
              ];
              passwordFile = config.age.secrets.theengs_ble_mqtt.path;
            };
            teslamate = {
              acl = [ "readwrite teslamate/#" ];
              passwordFile = config.age.secrets.teslamate_mqtt.path;
            };
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [ 1883 ];
  };
}
