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
    aa = {
      tools = {
        eza.enable = true;
        gpg.enable = true;
        zsh.enable = true;
      };

      apps = {
        neovim.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      awscli2
      direnv
      minio-client
      pre-commit
      git
    ];
  };
}
