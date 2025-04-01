{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.tools.zsh;
in
{
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
        {
          name = "powerlevel10k";
          src = inputs.powerlevel10k;
          file = "powerlevel10k.zsh-theme";
        }
        # To reconfigure p10k:
        # - Comment out the attrset below
        # - Run nixos-rebuild
        # - Run `p10k configure` (or start a new terminal session)
        # - Run `mv ~/.p10k.zsh ./p10k.zsh`
        # - Uncomment the attrset below
        # - Run nixos-rebuid
        {
          name = "powerlevel10k-config";
          src = ./plugins;
          file = "p10k.zsh";
        }
      ];
    };
  };
}
