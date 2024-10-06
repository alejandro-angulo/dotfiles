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

  tmsConfig = {
    display_full_path = true;
    session_sort_order = "LastAttached";
    search_dirs = [
      {
        path = "${config.home.homeDirectory}/src";
        depth = 2;
      }
    ];
  };
in {
  options.${namespace}.apps.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.tmux-sessionizer];

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
        tmuxPlugins.pain-control
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

        # sessionizer
        bind C-o display-popup -E "${pkgs.tmux-sessionizer}/bin/tms"
        bind C-j display-popup -E "${pkgs.tmux-sessionizer}/bin/tms switch"
        bind C-w display-popup -E "${pkgs.tmux-sessionizer}/bin/tms windows"
        bind C-s command-prompt -p "Rename active session to:" "run-shell '${pkgs.tmux-sessionizer}/bin/tms rename %1'"
      '';
    };

    xdg.configFile."tms/config.toml".source = (pkgs.formats.toml {}).generate "tms-config" tmsConfig;
  };
}
