{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.apps.steam;
in {
  options.aa.apps.steam = with types; {
    enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # TODO: This can be removed when/if PR 189398 is merged
    # https://github.com/NixOS/nixpkgs/pull/189398
    aa.home.extraOptions = {
      home.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.aa.proton-ge-custom}";
      };
    };
  };
}
