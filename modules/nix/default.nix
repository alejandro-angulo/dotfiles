{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.nix;
in {
  options.aa.nix = with types; {
    enable = mkEnableOption "manage nix configuration.";
    package = mkOption {
      type = package;
      default = pkgs.nixVersions.unstable;
      description = "Which nix package to use.";
    };
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
      };

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
