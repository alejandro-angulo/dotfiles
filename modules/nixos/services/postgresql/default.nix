{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.services.postgresql;
  postgresql_cfg = config.services.postgresql;
in
{
  options.${namespace}.services.postgresql = {
    upgradeScript = {
      enable = lib.mkEnableOption "postgres upgrade script (see here: https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading";
      newVersion = lib.mkOption {
        type = lib.types.package;
        description = "Version of postgres to upgrade to";
      };
      currentVersion = lib.mkOption {
        type = lib.types.package;
        description = "Current postgres version";
        default = postgresql_cfg.package;
      };
    };
  };

  config = lib.mkIf cfg.upgradeScript.enable {
    environment.systemPackages = [
      (pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -eux
        systemctl stop postgresql

        export NEWDATA="/var/lib/postgresql/${cfg.upgradeScript.newVersion.psqlSchema}"
        export NEWBIN="${cfg.upgradeScript.newVersion}/bin"

        export OLDDATA="${postgresql_cfg.dataDir}"
        export OLDBIN="${postgresql_cfg.finalPackage}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs postgresql_cfg.initdbArgs}

        sudo -u postgres "$NEWBIN/pg_upgrade" \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
          "$@"
      '')
    ];

  };
}
