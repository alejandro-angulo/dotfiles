{ lib, ... }:
{
  den.hosts.x86_64-linux = {
    carbon.users.alejandro = { };
    framework.users.alejandro = { };
    git.users.alejandro = { };
    gospel.users.alejandro = { };
    node.users.alejandro = { };
  };
  den.hosts.aarch64-linux.pi4.users.alejandro = { };

  # den.hosts.aarch64-darwin.apple.users.alice = { };
  # den.homes.x86_64-linux.alice = { };

  # enable hm for all users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
