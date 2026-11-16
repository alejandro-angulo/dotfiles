{
  config,
  lib,
  ...
}:
let
  cfg = config.aa.services.restic;
in
{
  options.aa.services.restic.jobs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          user = lib.mkOption {
            type = lib.types.str;
            description = ''
              OS user the backup job runs as. This user must be able to read
              `paths`, so the referenced age secrets should be owned by this
              user as well.
            '';
          };

          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Paths to back up.";
          };

          repositoryAgeSecret = lib.mkOption {
            type = lib.types.str;
            description = ''
              Name of the `age.secrets` entry holding the restic repository
              string (e.g. `b2:<bucket>:<prefix>`).
            '';
          };

          passwordAgeSecret = lib.mkOption {
            type = lib.types.str;
            description = ''
              Name of the `age.secrets` entry holding the restic repository
              password.
            '';
          };

          environmentAgeSecret = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Optional name of the `age.secrets` entry holding backend
              credentials, deployed as the job's `EnvironmentFile` (e.g. B2
              application keys).
            '';
          };

          initialize = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Create the repository if it does not exist yet.";
          };

          timerCalendar = lib.mkOption {
            type = lib.types.str;
            default = "00:05";
            description = ''
              `OnCalendar` for the backup timer. Stagger jobs that share a
              backend.
            '';
          };

          randomizedDelay = lib.mkOption {
            type = lib.types.str;
            default = "5h";
            description = "`RandomizedDelaySec` for the backup timer.";
          };

          pruneOpts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "--keep-daily 7"
              "--keep-weekly 5"
              "--keep-monthly 12"
              "--keep-yearly 9001"
            ];
            description = "Retention options for `restic forget --prune`.";
          };

          backupPrepareCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Script run before the backup (e.g. a database dump).";
          };

          backupCleanupCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Script run after the backup.";
          };
        };
      }
    );
    default = { };
    description = ''
      Restic backup jobs backed by agenix secrets. Each entry maps onto a
      `services.restic.backups.<name>` unit whose repository, password, and
      optional backend credentials are read from age-encrypted files.
    '';
  };

  config.services.restic.backups = lib.mkMerge (
    lib.mapAttrsToList (name: job: {
      ${name} = {
        inherit (job)
          user
          paths
          initialize
          pruneOpts
          backupPrepareCommand
          backupCleanupCommand
          ;
        repositoryFile = config.age.secrets.${job.repositoryAgeSecret}.path;
        passwordFile = config.age.secrets.${job.passwordAgeSecret}.path;
        environmentFile =
          if job.environmentAgeSecret == null then
            null
          else
            config.age.secrets.${job.environmentAgeSecret}.path;
        timerConfig = {
          OnCalendar = job.timerCalendar;
          Persistent = true;
          RandomizedDelaySec = job.randomizedDelay;
        };
      };
    }) cfg.jobs
  );
}
