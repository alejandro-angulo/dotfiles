let
  # Remember to pass '--identity identities/me.txt` when using this key
  users.me = "age1yubikey1qdwgvfqrcqmyw56ux7azuvqr6f8nanszu27nztvxmn4utmplgxctzt90g25";

  machines = {
    gospel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDzjXVoQEfO9JIcFbp56EvQ0oBdr9Cmhxp4z0ih+ZEZ";
    node = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETLBnc8kJokmFiA28BaSYpeE7flY1W0SM5C1pWv/tOv";
    pi4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9fnNXzEmDdmtR+KWj/M9vQioFR0s/4jMnIkUFcj8As";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAf6Z7SZEOH3H51T/GPIc/B0OpbaydM5l2PP3nMnwpFl";
    git = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8JLy/ipBfOet3/KT7rXOXHDjjmt+VqqQb3V+ILIuDN";
  };
in {
  "cf_dns_kilonull.age".publicKeys = [users.me machines.node machines.gospel machines.pi4 machines.proxy];
  "gitea-runner-gospel.age".publicKeys = [users.me machines.gospel];
  "hass_mqtt.age".publicKeys = [users.me machines.pi4 machines.node machines.gospel];
  "hydra-aws-creds.age".publicKeys = [users.me machines.gospel];
  "nextcloud_admin.age".publicKeys = [users.me machines.node machines.gospel];
  "tailscale_git_server.age".publicKeys = [users.me machines.git]; # This key expires, might have to update
  "teslamate_db.age".publicKeys = [users.me machines.node machines.gospel];
  "teslamate_encryption.age".publicKeys = [users.me machines.node machines.gospel];
  "teslamate_mqtt.age".publicKeys = [users.me machines.pi4 machines.node machines.gospel];
  "theengs_ble_mqtt.age".publicKeys = [users.me machines.pi4 machines.gospel];
}
