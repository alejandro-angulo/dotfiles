{
  config,
  pkgs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault;

  cfg = config.${namespace}.tools.git;
in {
  options.${namespace}.tools.git = {
    enable = mkEnableOption "git";
    userName = lib.options.mkOption {
      type = lib.types.str;
      default = "alejandro-angulo";
      description = "The name to use for git commits.";
    };
    userEmail = lib.options.mkOption {
      type = lib.types.str;
      default = "iam@alejandr0angul0.dev";
      description = "The email to use for git commits.";
    };
    signingKey = lib.options.mkOption {
      type = lib.types.str;
      default = "0xE1B13CCEFDEDDFB7";
      description = "The key ID used to sign commits.";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.shellAliases = {
      "gco" = "${pkgs.git}/bin/git checkout $(${pkgs.git}/bin/git branch | ${pkgs.fzf}/bin/fzf)";
    };

    programs.git = {
      delta = {
        enable = true;
        catppuccin.enable = true;
        options = {
          line-numbers = true;
          navigate = true;
        };
      };

      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      aliases = {
        # Prettier log
        lol = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        # Find log and grab its hash
        lof = ''
          !${pkgs.git}/bin/git log --pretty=oneline \
          | ${pkgs.fzf}/bin/fzf --scheme history \
          | ${pkgs.gawk}/bin/awk '{print $1}'
        '';
        # Push up a new branch with the same as local
        pushup = "push -u origin HEAD";
      };

      signing = {
        key = cfg.signingKey;
        signByDefault = mkDefault true;
      };

      ignores = [
        # PyCharm
        ".idea/"

        # Vim artifacts
        "*.swp"
        "*.swo"
        "tags"
        ".vimspector.json"
        ".vimlocal"
        "Session.vim*"

        # direnv
        ".envrc"
        ".direnv"
      ];

      extraConfig = {
        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = true;
        };
      };
    };

    programs.lazygit = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        quitOnTopLevelReturn = true;
        gui.nerdFontsVersion = "3";
        git.paging = {
          colorArg = "always";
          pager = "${pkgs.delta}/bin/delta --dark --paging=never";
        };
      };
    };
  };
}
