{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) fetchFromGitHub;

  cfg = config.${namespace}.tools.zsh;
in {
  options.${namespace}.tools.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      envExtra = ''
        export PATH=~/.local/bin:$PATH
        export EDITOR=nvim
      '';
      initExtra = ''
        base16_darktooth
        bindkey -v
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^R' history-incremental-search-backward
        alias view="nvim -R $1"
        alias l='ls -la'
      '';

      plugins = [
        {
          name = "zsh-syntax-highlighting";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.7.1";
            sha256 = "sha256-gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
          };
          file = "zsh-syntax-highlighting.zsh";
        }
        {
          name = "powerlevel10k";
          src = fetchFromGitHub {
            owner = "romkatv";
            repo = "powerlevel10k";
            rev = "v1.17.0";
            sha256 = "sha256-fgrwbWj6CcPoZ6GbCZ47HRUg8ZSJWOsa7aipEqYuE0Q=";
          };
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./.;
          file = "p10k.zsh";
        }
        {
          name = "base16-shell";
          src = fetchFromGitHub {
            owner = "chriskempson";
            repo = "base16-shell";
            rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
            sha256 = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
          };
          file = "base16-shell.plugin.zsh";
        }
      ];
    };
  };
}
