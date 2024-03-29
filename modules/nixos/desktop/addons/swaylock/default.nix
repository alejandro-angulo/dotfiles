{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.desktop.addons.swaylock;
  user_cfg = config.home-manager.users.${config.aa.user.name};
in {
  options.aa.desktop.addons.swaylock = with types; {
    enable = mkEnableOption "swaylock";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [swaylock];

    aa.home.extraOptions = {
      programs.swaylock.settings = {
        image = "${user_cfg.xdg.dataHome}/${config.aa.desktop.sway.wallpaperPath}";
      };
    };

    # Workaround for https://github.com/NixOS/nixpkgs/issues/158025
    # This comment specifically: https://github.com/NixOS/nixpkgs/issues/158025#issuecomment-1344766809
    security.pam.services.swaylock = {};
  };
}
