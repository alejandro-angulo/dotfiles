{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    git
    git-crypt
  ];

  programs.git = {
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        navigate = true;
      };
    };

    enable = true;
    userName = "Alejandro Angulo";
    userEmail = "iam@alejandr0angul0.dev";

    aliases = {
      lol = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      pushup = "push -u origin HEAD";
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
}
