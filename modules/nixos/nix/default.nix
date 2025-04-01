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
      default = pkgs.nixVersions.git;
      description = "Which nix package to use.";
    };

    useSelfhostedCache = mkEnableOption "use self-hosted nix cache (currently hosted on gospel)";
  };

  config = mkIf cfg.enable {
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
  };
}
