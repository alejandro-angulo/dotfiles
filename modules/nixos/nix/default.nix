{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aa.nix;
  selfHostedCacheHost = "https://cache.kilonull.com/";
in
{
  options.aa.nix = {
    enable = mkEnableOption "manage nix configuration.";
    package = mkOption {
      type = types.package;
      default = pkgs.nixVersions.nix_2_31;
      description = "Which nix package to use.";
    };

    useSelfhostedCache = mkEnableOption "use self-hosted nix cache (currently hosted on gospel)";

    remoteBuilder = {
      enable = mkEnableOption "set up as a remote builder";
      client = {
        enable = mkEnableOption "set up to use configured remote builders";
        sshKeyPath = mkOption {
          type = types.str;
          # NOTE: By default, only root user has read access.
          # This means only builds initiated by root will be able to make use
          # of distributed builds.
          # TODO: Allow my normal user to make use of distributed builds.
          default = "/etc/ssh/ssh_host_ed25519_key";
          description = "Path to ssh key to use to connect to remote builders";
        };
      };

    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = with pkgs; [
          nix-prefetch
          nixfmt-rfc-style
        ];

        nix =
          let
            users = [
              "root"
              config.aa.user.name
            ];
          in
          {
            package = cfg.package;

            settings = {
              experimental-features = "nix-command flakes";
              trusted-users = users;
              allowed-users = users;

              builders-use-substitutes = cfg.useSelfhostedCache;
              substituters =
                if cfg.useSelfhostedCache then
                  [
                    # TESTING
                    "https://minio.kilonull.com/nix-store"
                    selfHostedCacheHost
                  ]
                else
                  [ ];
              trusted-public-keys = mkIf cfg.useSelfhostedCache [
                "gospelCache:9cbn8Wm54BbwpPS0TXw+15wrYZBpfOJt4Fzfbfcq/pc="
              ];
            };

            # TODO: Configure distributedBuilds and buildMachines?

            gc = {
              automatic = lib.mkDefault true;
              dates = lib.mkDefault "weekly";
              options = lib.mkDefault "--delete-older-than 30d";
            };
          };
      }
      (lib.mkIf cfg.remoteBuilder.enable {
        users.users.remotebuild = {
          isNormalUser = true;
          createHome = false;
          home = "/var/empty";
          group = "remotebuild";

          # All the keys from ./remote_client_keys should be trusted
          openssh.authorizedKeys.keyFiles = (
            let
              publicKeys = builtins.readDir ./remote_client_keys;
              fileNames = builtins.attrNames publicKeys;
              filePaths = builtins.map (fileName: ./remote_client_keys + "/${fileName}") fileNames;
            in
            filePaths
          );
        };

        users.groups.remotebuild = { };

        nix.settings.trusted-users = [ "remotebuild" ];
      })
      (lib.mkIf cfg.remoteBuilder.client.enable {
        nix.distributedBuilds = true;
        nix.settings.builders-use-substitutes = true;

        nix.buildMachines = [
          {
            hostName = "gospel";
            sshUser = "remotebuild";
            sshKey = cfg.remoteBuilder.client.sshKeyPath;
            system = "x86_64-linux";
            supportedFeatures = [
              "nixos-test"
              "big-parallel"
              "kvm"
            ];
          }
        ];
      })
    ]
  );
}
