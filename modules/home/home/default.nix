{
  config,
  lib,
  osConfig ? {},
  namespace,
  ...
}: {
  options.${namespace} = {
    isHeadless = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If true, graphical applications (e.g. firefox, sway, etc) won't be installed.";
    };

    installDefaults = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If true, a default set of packages will be installed.";
    };
  };

  config = lib.mkMerge [
    (
      lib.mkIf (!config.${namespace}.isHeadless) {
        ${namespace} = {
          programs.firefox.enable = true;
          windowManagers.sway.enable = true;
        };
      }
    )
    (lib.mkIf (config.${namespace}.installDefaults) {
      ${namespace} = {
        apps = {
          bat.enable = true;
          btop.enable = true;
          tmux.enable = true;
        };

        programs = {
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
      };
    })
    {
      home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "24.05");
    }
  ];
}
