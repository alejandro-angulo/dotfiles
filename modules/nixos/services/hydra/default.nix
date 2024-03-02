{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.services.hydra;
in {
  options.aa.services.hydra = with types; {
    enable = mkEnableOption "hydra";
  };

  config = mkIf cfg.enable {
    # NOTE: Need to create user to allow web configuration
    # sudo -u hydra hydra-create-user alice \
    #   --full-name 'Alice Q. User' \
    #   --email-address 'alice@example.org' \
    #   --password-prompt \
    #   --role admin

    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [];
      useSubstitutes = true;
    };

    nix.settings = {
      allowed-users = ["hydra"];
      allowed-uris = ["github:"];
    };
  };
}
