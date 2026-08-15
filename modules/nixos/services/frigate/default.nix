{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.services.frigate;

  # The standalone go2rtc service and frigate's embedded go2rtc instance are
  # configured with the same streams, but use different environment variable
  # placeholder syntaxes: ${VAR} for go2rtc, {VAR} for frigate. Generate
  # both stream configurations from a single definition.
  mkStreams =
    placeholder:
    let
      username = placeholder "FRIGATE_VIDEO_DOORBELL_USERNAME";
      password = placeholder "FRIGATE_VIDEO_DOORBELL_PASSWORD";
    in
    {
      video_doorbell = [
        "ffmpeg:http://192.168.113.91/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=${username}&password=${password}#video=copy#audio=opus"
        "rtsp://${username}:${password}@192.168.113.91/Preview_01_sub"
      ];
      video_doorbell_sub = [
        "ffmpeg:http://192.168.113.91/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=${username}&password=${password}"
        "rtsp://${username}:${password}@192.168.113.91/Preview_01_sub"
      ];
    };

  # Enabling the frigate service doesn't enable the go2rtc service so I need to
  # explicitly enable `services.go2rtc`. But frigate needs to know about the
  # go2rtc settings so that I can get 2-way talk.
  go2rtcStreams = mkStreams (name: "\${${name}}");
  frigateStreams = mkStreams (name: "{${name}}");

  webrtcCandidates = [
    "192.168.113.69:8555"
    "stun:8555"
  ];
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

  config = lib.mkIf cfg.enable {
    age.secrets.frigate_env = {
      file = ../../../../secrets/frigate_env.age;
      owner = "frigate";
    };

    systemd.services.frigate.serviceConfig = {
      EnvironmentFile = config.age.secrets.frigate_env.path;
    };
    systemd.services.go2rtc.serviceConfig = {
      EnvironmentFile = config.age.secrets.frigate_env.path;
    };

    services.go2rtc = {
      enable = true;
      settings = {
        webrtc.candidates = webrtcCandidates;
        streams = go2rtcStreams;
      };
    };

    services.frigate = {
      enable = true;
      hostname = cfg.hostname;

      # The generated configuration is checked at build time and the
      # configuration relies on some environment variables. Export some
      # dummy values so the check can succeed.
      preCheckConfig = ''
        export FRIGATE_MQTT_PASSWORD="dummy value"
        export FRIGATE_VIDEO_DOORBELL_USERNAME="dummy value"
        export FRIGATE_VIDEO_DOORBELL_PASSWORD="dummy value"
      '';

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

        go2rtc = {
          webrtc.candidates = webrtcCandidates;
          streams = frigateStreams;
        };

        cameras = {
          video_doorbell.ffmpeg = {
            output_args.record = "preset-record-generic-audio-copy";
            inputs = [
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
    };

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostname} = {
        locations."/ws" = {
          proxyWebsockets = true;
        };
      }
      // lib.optionalAttrs (cfg.acmeCertName != "") {
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [ 8555 ];
      allowedTCPPorts = [
        80
        443
        1984
        8555
        8554
      ];
    };
  };
}
