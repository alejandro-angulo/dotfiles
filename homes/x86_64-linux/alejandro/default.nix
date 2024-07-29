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
      tmux.enable = true;
    };

    tools = {
      direnv.enable = true;
      git.enable = true;
      zsh.enable = true;
    };
  };
}
