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
        options = {
          line-numbers = true;
          navigate = true;
        };
      };

      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      aliases = {
        lol = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
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
  };
}
