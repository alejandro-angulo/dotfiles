let
  # Remember to pass '--identity identities/me.txt` when using this key
  users.me = "age1yubikey1qdwgvfqrcqmyw56ux7azuvqr6f8nanszu27nztvxmn4utmplgxctzt90g25";

  machines.node = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETLBnc8kJokmFiA28BaSYpeE7flY1W0SM5C1pWv/tOv";
in {
  "cf_dns_kilonull.age".publicKeys = [users.me machines.node];
}
