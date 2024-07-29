{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aa.apps.neovim;
in {
  options.aa.apps.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [neovim];
  };
}
