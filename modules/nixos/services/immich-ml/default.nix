{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aa.services.immich-ml;
in
{
  options.aa.services.immich-ml = with lib; {
    enable = mkEnableOption "immich machine learning service";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Address the machine learning service listens on.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3003;
      description = ''
        Port the machine learning service listens on.
      '';
    };

    workers = mkOption {
      type = types.ints.positive;
      default = 1;
      description = ''
        Number of machine learning worker processes. More workers allow more
        concurrent inference jobs at the cost of memory.
      '';
    };

    allowedClients = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        IP addresses or CIDR ranges allowed to reach the machine learning
        port. This service has no authentication whatsoever, so it must never
        be exposed publicly.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.immich-ml = {
      isSystemUser = true;
      group = "immich-ml";
    };
    users.groups.immich-ml = { };

    systemd.services.immich-machine-learning = {
      description = "Immich machine learning service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        IMMICH_HOST = cfg.host;
        IMMICH_PORT = toString cfg.port;
        MACHINE_LEARNING_WORKERS = toString cfg.workers;
        MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich-ml";
        XDG_CACHE_HOME = "/var/cache/immich-ml";
      };
      serviceConfig = {
        ExecStart = lib.getExe pkgs.immich.machine-learning;
        User = "immich-ml";
        Group = "immich-ml";
        StateDirectory = "immich-ml";
        CacheDirectory = "immich-ml";
        WorkingDirectory = "/var/cache/immich-ml";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };

    # The port is not opened in `allowedTCPPorts`; only the explicitly
    # configured clients may reach it.
    networking.firewall.extraInputRules = lib.mkIf (cfg.allowedClients != [ ]) ''
      ip saddr { ${lib.concatStringsSep ", " cfg.allowedClients} } tcp dport ${toString cfg.port} accept
    '';
  };
}
