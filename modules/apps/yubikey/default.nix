{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.aa.apps.yubikey;
in {
  options.aa.apps.yubikey = with types; {
    enable = mkEnableOption "yubikey";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-agent
      yubico-pam
      age-plugin-yubikey
      rage
    ];

    services.pcscd.enable = true;

    security.pam.yubico = {
      enable = true;
      #debug = true;
      mode = "challenge-response";
      # Uncomment below for 2FA
      #control = "required";
    };
    # To set up, need to run (might need to run first command as root)
    # ykman otp chalresp --touch --generate 2
    # ykpamcfg -2 -v
  };
}
