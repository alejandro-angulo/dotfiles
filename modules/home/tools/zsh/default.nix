{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  sources = import ../../../../npins;
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
          src = sources.zsh-syntax-highlighting;
          file = "zsh-syntax-highlighting.zsh";
        }
        {
          name = "powerlevel10k";
          src = sources.powerlevel10k;
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./.;
          file = "p10k.zsh";
        }
        {
          name = "base16-shell";
          src = sources.base16-shell;
          file = "base16-shell.plugin.zsh";
        }
      ];
    };
  };
}
