{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.neovim;
in {
  options.${namespace}.programs.neovim = {
    enable = lib.mkEnableOption "neovim";
    lazygit.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enables lazygit integration.

        This makes it so that editing a file from lazygit opens a buffer in
        the current instance.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {home.packages = [pkgs.neovim];}
    (lib.mkIf cfg.lazygit.enable {
      programs.zsh.shellAliases = {
        nvim = "${pkgs.neovim}/bin/nvim --listen /tmp/nvim-server.pipe";
      };

      programs.lazygit.settings.os = {
        editCommand = "nvim";
        editCommandTemplate = ''
          {{editor}} --server /tmp/nvim-server.pipe --remote-tab {{filename}}
        '';
      };
    })
  ]);
}
