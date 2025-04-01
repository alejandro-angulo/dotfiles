{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.services.minio;
in
{
  options.${namespace}.services.minio = with lib; {
    enable = mkEnableOption "minio";
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
    services.minio = {
      enable = true;
    };

    systemd.services.minio.environment = {
      MINIO_SERVER_URL = "https://minio.kilonull.com";
      MINIO_BROWSER_REDIRECT_URL = "https://minio.kilonull.com/ui";
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "minio.kilonull.com" =
          {
            extraConfig = ''
              # Allow special characters in headers
              ignore_invalid_headers off;
              # Allow any size file to be uploaded.
              # Set to a value such as 1000m; to restrict file size to a specific value
              client_max_body_size 0;
              # Disable buffering
              proxy_buffering off;
              proxy_request_buffering off;
            '';

            locations."/".extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;

              proxy_connect_timeout 300;
              # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              chunked_transfer_encoding off;

              proxy_pass http://localhost:9000;
            '';
            locations."/ui".extraConfig = ''
              rewrite ^/ui/(.*) /$1 break;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-NginX-Proxy true;

              # This is necessary to pass the correct IP to be hashed
              real_ip_header X-Real-IP;

              proxy_connect_timeout 300;

               # To support websockets in MinIO versions released after January 2023
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              # Some environments may encounter CORS errors (Kubernetes + Nginx Ingress)
              # Uncomment the following line to set the Origin request to an empty string
              proxy_set_header Origin "";

              chunked_transfer_encoding off;

              proxy_pass http://localhost:9001;
            '';
          }
          // lib.optionalAttrs (cfg.acmeCertName != "") {
            forceSSL = true;
            useACMEHost = cfg.acmeCertName;
          };
      };
    };
  };
}
