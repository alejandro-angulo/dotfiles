{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aa.services.syncoid;
in {
  options.aa.services.syncoid = with lib; {
    enable = mkEnableOption "syncoid (ZFS snap replication)";
    commands = mkOption {
      type = types.attrs;
      default = {};
      description = "Commands to pass directly to syncoid, see `services.syncoid.commands`";
    };
    remoteTargetUser = mkOption {
      type = types.str;
      default = "";
      description = "The user to use on the target machine.";
    };
    remoteTargetDatasets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Datasets to be used as a remote target (e.g. a NAS's backups dataset)";
    };
    remoteTargetPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "SSH public keys that the syncoid service's user should trust";
    };
  };

  config = mkIf cfg.enable {
    services.syncoid = {
      enable = true;
      localSourceAllow =
        options.services.syncoid.localSourceAllow.default
        ++ [
          "mount"
        ];
      localTargetAllow =
        options.services.syncoid.localTargetAllow.default
        ++ [
          "destroy"
        ];
      commands = lib.mkAliasDefinitions options.aa.services.syncoid.commands;
    };

    environment.systemPackages = mkIf (cfg.remoteTargetUser != "") (with pkgs; [
      lzop
      mbuffer
    ]);

    users = mkIf (cfg.remoteTargetUser != "") {
      users."${cfg.remoteTargetUser}" = {
        shell = pkgs.bashInteractive;
        group = cfg.remoteTargetUser;
        isSystemUser = true;
        home = "/var/lib/${cfg.remoteTargetUser}";
        createHome = true;
        openssh.authorizedKeys.keys = cfg.remoteTargetPublicKeys;
      };
      groups."${cfg.remoteTargetUser}" = {};
    };

    systemd.services.setup-syncoid-remote = {
      description = "Permission setup for syncoid remote targets";
      documentation = ["https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.zfs];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };

      script = ''
        DATASETS=(${toString cfg.remoteTargetDatasets})
              for dataset in "''${DATASETS[@]}"; do
                zfs allow \
              	-u ${cfg.remoteTargetUser} \
              	compression,mountpoint,create,mount,receive,rollback,destroy \
              	"$dataset"
              done
      '';
    };
  };
}
