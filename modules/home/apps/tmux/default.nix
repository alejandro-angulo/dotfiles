{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption;
  inherit (pkgs) tmuxPlugins;

  sources = import ../../../../npins;
  cfg = config.${namespace}.apps.tmux;
in {
  options.${namespace}.apps.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    xdg.dataFile."tmux-theme".source = ./tmux_theme;

    programs.tmux = {
      enable = true;
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

        {
          plugin =
            tmuxPlugins.mkTmuxPlugin
            {
              pluginName = "tmux-nerd-font-window-name";
              version = "2.1.1";
              src = sources.tmux-nerd-font-window-name;
              nativeBuildInputs = [pkgs.makeWrapper];
              rtpFilePath = "tmux-nerd-font-window-name.tmux";
              postInstall = ''
                wrapProgram $target/bin/tmux-nerd-font-window-name \
                    --prefix PATH ${lib.makeBinPath [pkgs.yq-go]}

                # NOTE: I thought the wrapProgram above should make it so this wouldn't be needed
                find $target -type f -print0 | xargs -0 sed -i -e 's|yq |${pkgs.yq-go}/bin/yq |g'
              '';
            };
        }

        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.open
      ];

      extraConfig = ''
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
        source-file ${config.xdg.dataHome}/tmux-theme;

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
      '';
    };
  };
}
