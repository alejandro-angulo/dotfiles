{
  config,
  pkgs,
  ...
}: {
  aa = {
    nix.enable = true;
    nix.useSelfhostedCache = true;

    security.acme = {
      enable = true;
      domainName = "proxy.kilonull.com";
      isWildcard = false;
      # TODO: Use a different cert with more targetted permissions (this one
      # can make wildcard certs)
      # TODO: Add machine public key in secrets/secrets.nix
      dnsCredentialsFile = "/var/acme/creds";
    };

    services = {
      openssh.enable = true;
      # NOTE: Need to run `tailscale login` on first boot
      tailscale = {
        enable = true;
        configureClientRouting = true;
      };
    };

    tools.zsh.enable = true;
  };

  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      log_format upstreamlog '[$time_local] $remote_addr - $remote_user - $server_name to: $upstream_addr: $request upstream_response_time $upstream_response_time msec $msec request_time $request_time';
      access_log  /var/log/nginx/access.log upstreamlog;
    '';
    virtualHosts."proxy.kilonull.com" = let
      commonConfig = pkgs.writeText "common_config.conf" ''
        proxy_redirect off;
        proxy_set_header Host "hydra.kilonull.com";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;

        allow 127.0.0.1;
        allow 100.0.0.0/8;
        allow 192.168.113.0/24;
      '';
    in {
      forceSSL = true;
      useACMEHost = "proxy.kilonull.com";
      locations = {
        "/" = {
          extraConfig = ''
            deny all;
          '';
        };
        "/hydra" = {
          proxyPass = "https://hydra.kilonull.com";
          extraConfig = ''
            rewrite /hydra(.*) /$1 break;
            include ${commonConfig};
            deny all;
          '';
        };
        "/hydra/api/push-github" = {
          proxyPass = "https://hydra.kilonull.com/api/push-github";
          extraConfig = ''
            include ${commonConfig};
            # GitHub webhook IPs
            allow 192.30.252.0/22;
            allow 185.199.108.0/22;
            allow 140.82.112.0/20;
            allow 143.55.64.0/20;
            allow 2a0a:a440::/29;
            allow 2606:50c0::/3;
            deny all;
          '';
        };
      };
    };
  };

  users.users.${config.aa.user.name} = {
    initialHashedPassword = "$y$j9T$/AuWXo5argOeEi1hwlu161$bvB.V5tfB.acWAvr6mV9lVucdGzQc16UVffMdPbqWD0";
  };
  networking.firewall.allowedTCPPorts = [
    # SSH
    22

    # HTTP(S)
    80
    443
  ];

  virtualisation.digitalOcean = {
    setRootPassword = true;
    setSshKeys = true;
  };

  system.stateVersion = "24.05";
}
