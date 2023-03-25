{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.tools.git;
  gpg = config.aa.tools.gpg;
  user = config.aa.user;
in {
  options.aa.tools.git = with types; {
    enable = mkEnableOption "git";
    userName = mkOption {
      type = str;
      default = user.fullName;
      description = "The name to use for git commits.";
    };
    userEmail = mkOption {
      type = str;
      default = user.email;
      description = "The email to use for git commits.";
    };
    signingKey = mkOption {
      type = str;
      default = "0xE1B13CCEFDEDDFB7";
      description = "The key ID used to sign commits.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [git];

    aa.home.extraOptions = {
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
          signByDefault = mkIf config.aa.tools.gpg.enable true;
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
  };
}
