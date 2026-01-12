{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.services.frigate;
in
{
  options.${namespace}.services.frigate = {
    enable = lib.mkEnableOption "Frigate NVR";

    acmeCertName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "frigate.kilonull.com";
      description = ''
        The hostname for the Frigate web interface.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8971;
      description = ''
        The port on which Frigate's web interface will listen.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open the firewall for HTTP/HTTPS traffic.
      '';
    };
  };

  config =
    let
      setEnvVars = ''
        export FRIGATE_MQTT_PASSWORD=$(cat ${config.age.secrets.frigate_mqtt.path})
      '';
    in
    lib.mkIf cfg.enable {
      age.secrets.frigate_mqtt.file = ../../../../secrets/frigate_mqtt.age;

      systemd.services.frigate.preStart = setEnvVars;
      services.frigate.preCheckConfig = setEnvVars;

      services.frigate = {
        enable = true;
        hostname = cfg.hostname;
        settings = {
          # Basic Frigate configuration
          mqtt = {
            enabled = true;
            host = "192.168.113.42";
            port = 1883;
            user = "frigate";
            password = "{FRIGATE_MQTT_PASSWORD}";
          };

          # TLS terminated at reverse proxy (nginx)
          tls.enabled = false;

          go2rtc.streams = {
            video_doorbell = [
              "ffmpeg:http://reolink_ip/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=username&password=password#video=copy#audio=copy#audio=opus"
              "rtsp://username:password@reolink_ip/Preview_01_sub"
            ];
            video_doorbell_sub = [
              "ffmpeg:http://reolink_ip/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=username&password=password"
              "rtsp://username:password@reolink_ip/Preview_01_sub"
            ];
          };
          go2rtc.webrtc.candidates = [
            "192.168.113.69:8555"
            # "gospel:8555"
          ];

          cameras = {
            video_doorbell.ffmpeg.inputs = [
              {

                path = "rtsp://127.0.0.1:8554/video_doorbell";
                input_args = "preset-rtsp-restream";
                roles = [ "record" ];
              }

              {
                path = "rtsp://127.0.0.1:8554/video_doorbell_sub";
                input_args = "preset-rtsp-restream";
                roles = [ "detect" ];
              }
            ];
          };
        };
      };

      services.nginx = {
        enable = true;
        virtualHosts.${cfg.hostname} = lib.mkIf (cfg.acmeCertName != "") {
          forceSSL = true;
          useACMEHost = cfg.acmeCertName;
        };
      };

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [
          80
          443
          855
        ];
      };
    };
}
