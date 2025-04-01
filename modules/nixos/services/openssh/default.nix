{
  config,
  lib,
  format,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkDefault
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
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = mkDefault (if format == "install-iso" then "yes" else "no");
      };
    };

    aa.user.extraOptions = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
