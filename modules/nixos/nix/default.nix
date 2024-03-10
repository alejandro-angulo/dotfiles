{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.nix;
  selfHostedCacheHost = "https://cache.kilonull.com/";
in {
  options.aa.nix = with types; {
    enable = mkEnableOption "manage nix configuration.";
    package = mkOption {
      type = package;
      default = pkgs.nixVersions.unstable;
      description = "Which nix package to use.";
    };

    useSelfhostedCache = mkEnableOption "use self-hosted nix cache (currently hosted on gospel)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alejandra
      nix-prefetch
    ];

    nix = let
      users = ["root" config.aa.user.name];
    in {
      package = cfg.package;

      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = users;
        allowed-users = users;

        builders-use-substitutes = cfg.useSelfhostedCache;
        substituters =
          if cfg.useSelfhostedCache
          then [
            # TESTING
            "https://minio.kilonull.com/nix-store"
            selfHostedCacheHost
          ]
          else [];
        trusted-public-keys =
          if cfg.useSelfhostedCache
          then ["gospelCache:9cbn8Wm54BbwpPS0TXw+15wrYZBpfOJt4Fzfbfcq/pc="]
          else [];
      };

      # TODO: Configure distributedBuilds and buildMachines?

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # TODO: Not sure if I want this
      # flake-utils-plus
      # generateRegistryFromInputs = true;
      # generateNixPathFromInputs = true;
      # linkInputs = true;
    };
  };
}
