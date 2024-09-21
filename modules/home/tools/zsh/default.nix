{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

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
        bindkey -v
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^R' history-incremental-search-backward
      '';

      shellAliases = {
        view = "${pkgs.neovim}/bin/nvim -R $1";
        l = "ls -la";
      };

      plugins = [
        {
          name = "zsh-syntax-highlighting";
          src = inputs.zsh-syntax-highlighting;
          file = "zsh-syntax-highlighting.zsh";
        }
      ];
    };

    programs.starship = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        format = lib.concatStrings [
          "$os"
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$fill"
          "$all"
          "$time"
          "$line_break"
          "$character"
        ];

        os.disabled = false;
        status.disabled = false;
        time.disabled = false;
      };
    };
  };
}
