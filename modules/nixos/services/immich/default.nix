{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aa.services.immich;
in
{
  options.aa.services.immich = with lib; {
    enable = mkEnableOption "immich";

    acmeCertName = mkOption {
      type = types.str;
      default = "";
      description = ''
        If set to a non-empty string, forces SSL with the supplied acme
        certificate.
      '';
    };

    hostname = mkOption {
      type = types.str;
      default = "immich.kilonull.com";
      description = ''
        The hostname for the Immich web interface.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 2283;
      description = ''
        The port Immich listens on.
      '';
    };

    mediaLocation = mkOption {
      type = types.path;
      default = "/tank/immich";
      description = ''
        Directory used to store media files (originals, thumbnails, and
        encoded video). The directory must live on a local filesystem.
      '';
    };

    machineLearningUrl = mkOption {
      type = types.str;
      default = "";
      description = ''
        URL of a remote Immich machine learning service (for example
        `http://192.168.113.69:3003`). When empty, machine learning runs
        locally on this host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = cfg.mediaLocation;
      host = "127.0.0.1";
      port = cfg.port;
      openFirewall = false;

      # Machine learning runs on a dedicated remote host (see the
      # `immich-ml` module). Disable the local service when a remote URL is
      # configured so this host doesn't need to run it.
      machine-learning.enable = cfg.machineLearningUrl == "";

      # Hardware accelerated video transcoding via the AMD Vega APU.
      accelerationDevices = [ "/dev/dri/renderD128" ];

      environment.IMMICH_MACHINE_LEARNING_URL = lib.mkIf (cfg.machineLearningUrl != "") (
        lib.mkForce cfg.machineLearningUrl
      );

      settings = {
        server.externalDomain = "https://${cfg.hostname}";
        ffmpeg = {
          accel = "vaapi";
          accelDecode = true;
        };
      };
    };

    # VAAPI requires the graphics stack (Mesa radeonsi) and access to the
    # render device.
    hardware.graphics.enable = true;
    users.users.immich.extraGroups = [
      "render"
      "video"
    ];
    systemd.services.immich-server.serviceConfig.SupplementaryGroups = [
      "render"
      "video"
    ];

    # The media dataset already exists; adjust its ownership without
    # recreating it.
    systemd.tmpfiles.rules = [
      "z ${cfg.mediaLocation} 0755 immich immich -"
    ];

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostname} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      }
      // lib.optionalAttrs (cfg.acmeCertName != "") {
        forceSSL = true;
        useACMEHost = cfg.acmeCertName;
      };
    };
  };
}
