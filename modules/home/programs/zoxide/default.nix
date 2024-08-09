{
  config,
  pkgs,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.zoxide;
in {
  options.${namespace}.programs.zoxide = {
    enable = lib.mkEnableOption "zoxide";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.zoxide];

    programs.zoxide = {
      enable = true;
      options = ["--cmd cd"];
    };
  };
}
