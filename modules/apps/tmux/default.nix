{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.tmux;
  user_cfg = config.home-manager.users.${config.aa.user.name};
in {
  options.aa.apps.tmux = with types; {
    enable = mkEnableOption "tmux";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.tmux = {
        enable = true;
        keyMode = "vi";
        newSession = true;
        sensibleOnTop = true;
        terminal = "screen-256color";

        # TOOD: Check if neovim is enabled before config vim integrations

        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-capture-pane-contents 'on'
              set -g @resurrect-strategy-vim 'session'
            '';
          }

          vim-tmux-navigator
        ];

        extraConfig =
          ''
            # Color fix
            # set-option -ga terminal-overrides ",alacritty:Tc,xterm-256color:Tc"

            # Scrolling with mouse wheel scrolls output instead of previous commands
            setw -g mouse on

            # Open panes in the same directory
            bind c new-window -c "#{pane_current_path}"
            bind '"' split-window -c "#{pane_current_path}"
            bind % split-window -h -c "#{pane_current_path}"

            # Eye Candy
            # set -g @plugin 'mattdavis90/base16-tmux'
            # set -g @colors-base16 'darktooth'

            # Smart pane switching with awareness of Vim splits.
            # See: https://github.com/christoomey/vim-tmux-navigator
            is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
                | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?\\.?g?(view|n?vim?x?)(-wrapped)?(diff)?$'"
            bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
            bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
            bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
            bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
            tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
            if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
                "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
            if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
                "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

            bind-key -T copy-mode-vi 'C-h' select-pane -L
            bind-key -T copy-mode-vi 'C-j' select-pane -D
            bind-key -T copy-mode-vi 'C-k' select-pane -U
            bind-key -T copy-mode-vi 'C-l' select-pane -R
            bind-key -T copy-mode-vi 'C-\' select-pane -l
          ''
          + (
            if config.aa.apps.neovim.enable
            then ''

              # Integration with tmuxline.vim
              source-file ${user_cfg.xdg.dataHome}/${config.aa.apps.neovim.tmuxThemePath}
            ''
            else ""
          );
      };
    };
  };
}
