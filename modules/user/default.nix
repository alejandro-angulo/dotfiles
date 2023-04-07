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
    fullName = mkOption {
      type = str;
      default = "Alejandro Angulo";
      description = "The full name of the user.";
    };
    email = mkOption {
      type = str;
      default = "iam@alejandr0angul0.dev";
      description = "The email of the user.";
    };
    extraGroups = mkOption {
      type = listOf str;
      default = ["video" "networkmanager"];
      description = "Groups to for the user to be assigned.";
    };
    extraOptions = mkOption {
      type = attrs;
      default = {};
      description = "Extra options passed to <option>users.user.<name></option>.";
    };
  };

  config = {
    # Required when setting shell to zsh
    # There is a separate module that configures zsh for make
    # Refer to modules/tools/zsh/default.nix
    programs.zsh.enable = true;

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
