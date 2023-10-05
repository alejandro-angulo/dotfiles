{
  options,
  config,
  lib,
  pkgs,
  format,
  ...
}:
with lib; let
  cfg = config.aa.services.openssh;

  user = config.users.users.${config.aa.user.name};
  user-id = builtins.toString user.uid;

  default-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmPdQcM0KCQ3YunF1gwN+B+i1Q8KrIfiUvNtgFQjTy2";
in {
  options.aa.services.openssh = with types; {
    enable = mkEnableOption "ssh";
    authorizedKeys = mkOption {
      type = listOf str;
      default = [default-key];
      description = "The public keys to authorize";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = mkDefault (
          if format == "install-iso"
          then "yes"
          else "no"
        );
      };
    };

    aa.user.extraOptions = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
