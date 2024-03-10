{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.suites.development;
in {
  options.aa.suites.development = with lib.types; {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    aa = {
      tools = {
        direnv.enable = true;
        eza.enable = true;
        git.enable = true;
        gpg.enable = true;
        zsh.enable = true;
      };

      apps = {
        neovim.enable = true;
        tmux.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      pre-commit
      minio-client
      awscli2
    ];
  };
}
