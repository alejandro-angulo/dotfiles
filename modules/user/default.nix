{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.user;
in {
  options.aa.user = with types; {
    name = mkOption {
      type = str;
      default = "alejandro";
      description = "The name to use for the user account.";
    };
    extraGroups = mkOption {
      type = listOf str;
      default = ["video" "networkmanager" "docker"];
      description = "Groups to for the user to be assigned.";
    };
    extraOptions = mkOption {
      type = attrs;
      default = {};
      description = "Extra options passed to <option>users.user.<name></option>.";
    };
  };

  config = {
    users.users.${cfg.name} =
      {
        isNormalUser = true;

        inherit (cfg) name;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.zsh;

        extraGroups = ["wheel"] ++ cfg.extraGroups;
      }
      // cfg.extraOptions;
  };
}
