{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption;
  inherit (pkgs) tmuxPlugins;

  cfg = config.${namespace}.apps.tmux;
in {
  options.${namespace}.apps.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      catppuccin.enable = true;
      keyMode = "vi";
      newSession = true;
      sensibleOnTop = true;
      terminal = "screen-256color";

      plugins = [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-strategy-nvim 'session'
          '';
        }

        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }

        tmuxPlugins.open
        tmuxPlugins.tmux-fzf
        tmuxPlugins.vim-tmux-navigator
      ];

      extraConfig = ''
        # Scrolling with mouse wheel scrolls output instead of previous commands
        setw -g mouse on

        # Open panes in the same directory
        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      '';
    };
  };
}
