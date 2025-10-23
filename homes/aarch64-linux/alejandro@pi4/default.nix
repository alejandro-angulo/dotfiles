{ lib, ... }:
{
  aa = {
    apps = {
      bat.enable = true;
      btop.enable = true;
      tmux.enable = true;
    };

    programs = {
      gpg.enable = true;
      zoxide.enable = true;
    };

    tools = {
      direnv.enable = true;
      eza.enable = true;
      git.enable = true;
      zsh.enable = true;
    };
  };

  # misc utils without custom config
  programs = {
    fzf.enable = lib.mkForce false;
  };
}
