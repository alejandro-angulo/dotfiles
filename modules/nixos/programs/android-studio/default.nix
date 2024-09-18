{
  config,
  pkgs,
  lib,
  namespace,
  ...
}: let
  cfg = config.${namespace}.programs.android-studio;
in {
  options.${namespace}.programs.android-studio = {
    enable = lib.mkEnableOption "Android Studio";
  };

  config = lib.mkIf cfg.enable {
    ${namespace}.user.extraGroups = ["kvm"];

    programs.adb.enable = true;

    environment.systemPackages = [pkgs.android-studio];
  };
}
