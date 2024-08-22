{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aa.suites.development;
in {
  options.aa.suites.development = {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      awscli2
      direnv
      git
      minio-client
      pre-commit
      vim
    ];
  };
}
