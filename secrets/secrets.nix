let
  # Remember to pass '--identity identities/me.txt` when using this key
  users.me = "age1yubikey1qdwgvfqrcqmyw56ux7azuvqr6f8nanszu27nztvxmn4utmplgxctzt90g25";

  tmp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJ7IsNxP/wa3X8isEp8Js7yVgk3gX2ud7EClvZClDpS";

  machines = {
    gospel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPA7bvtNIQqEvHYLrlcJdMQbYXdgpTPaDnHP1SZf6tz";
    node = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETLBnc8kJokmFiA28BaSYpeE7flY1W0SM5C1pWv/tOv";
    pi4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9fnNXzEmDdmtR+KWj/M9vQioFR0s/4jMnIkUFcj8As";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAf6Z7SZEOH3H51T/GPIc/B0OpbaydM5l2PP3nMnwpFl";
    git = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8JLy/ipBfOet3/KT7rXOXHDjjmt+VqqQb3V+ILIuDN";
  };
in
{
  "cf_dns_kilonull.age".publicKeys = [
    users.me
    machines.node
    machines.gospel
    machines.pi4
    machines.proxy
  ];
  "gitea-runner-gospel.age".publicKeys = [
    users.me
    machines.gospel
  ];
  "hass_mqtt.age".publicKeys = [
    users.me
    machines.pi4
    machines.node
    machines.gospel
  ];
  "hydra-aws-creds.age".publicKeys = [
    users.me
    machines.gospel
  ];
  "nextcloud_admin.age".publicKeys = [
    users.me
    machines.node
    machines.gospel
  ];
  "nextcloud_restic_env.age".publicKeys = [
    users.me
    machines.node
  ];
  "nextcloud_restic_password.age".publicKeys = [
    users.me
    machines.node
  ];
  "nextcloud_restic_repo.age".publicKeys = [
    users.me
    machines.node
  ];
  "teslamate_db.age".publicKeys = [
    users.me
    machines.node
    machines.gospel
  ];
  "teslamate_encryption.age".publicKeys = [
    users.me
    machines.node
    machines.gospel
  ];
  "teslamate_mqtt.age".publicKeys = [
    users.me
    machines.pi4
    machines.node
    machines.gospel
  ];
  "theengs_ble_mqtt.age".publicKeys = [
    users.me
    machines.pi4
    machines.gospel
  ];
  "zigbee2mqtt_mqtt.age".publicKeys = [
    users.me
    tmp
    machines.pi4
  ];
  "zigbee2mqtt_creds.age".publicKeys = [
    users.me
    tmp
    machines.node
  ];
}
