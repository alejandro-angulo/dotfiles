{
  config,
  inputs,
  lib,
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
        alias view="nvim -R $1"
        alias l='ls -la'
      '';

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
      enableTransience = true;
      catppuccin.enable = true;
    };
  };
}
