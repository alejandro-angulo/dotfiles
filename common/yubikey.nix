{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-agent
    yubico-pam
  ];

  services.pcscd.enable = true;

  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
    # Uncomment below for 2FA
    #control = "required";
  };
  # To set up, need to run (might need to run as root)
  # ykman otp chalresp --touch --generate 2
  # ykpamcfg -2 -v
}
