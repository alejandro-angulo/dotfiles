{...}: {
  aa = {
    apps = {
      bat.enable = true;
      btop.enable = true;
      tmux.enable = true;
    };

    programs = {
      firefox.enable = true;
      fzf.enable = true;
      gpg.enable = true;
      kitty.enable = true;
      zoxide.enable = true;
      yazi.enable = true;
    };

    tools = {
      direnv.enable = true;
      eza.enable = true;
      git.enable = true;
      zsh.enable = true;
    };

    windowManagers.sway.enable = true;
  };
}
