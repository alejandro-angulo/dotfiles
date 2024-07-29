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
      git.enable = true;
    };
  };
}
