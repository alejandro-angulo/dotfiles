{
  lib,
  pkgs,
  config,
  osConfig ? {},
  format ? "unknown",
  namespace,
  ...
}: {
  aa = {
    apps = {
      bat.enable = true;
      btop.enable = true;
      tmux.enable = true;
    };

    programs = {
      firefox.enable = true;
      gpg.enable = true;
      kitty.enable = true;
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
