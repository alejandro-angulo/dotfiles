{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aa.services.openssh;
  default-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmPdQcM0KCQ3YunF1gwN+B+i1Q8KrIfiUvNtgFQjTy2";
in
{
  options.aa.services.openssh = {
    enable = mkEnableOption "ssh";
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ default-key ];
      description = "The public keys to authorize";
    };
    passwordlessSudo = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Enable passwordless sudo (use ssh key)";
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
          };
        };

        aa.user.extraOptions = {
          openssh.authorizedKeys.keys = cfg.authorizedKeys;
        };
      }
      (lib.mkIf cfg.passwordlessSudo {
        security.pam.rssh.enable = true;
        security.pam.services.sudo.rssh = true;

      })
    ]
  );
}
