{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
  ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.x86_64-linux.igloo.users.tux = { };
  den.hosts.x86_64-linux.iceberg.users.tux = { };

  den.aspects.igloo = {
    includes = [ den.provides.hostname ];
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.hello ];
      };
  };

  den.aspects.tux = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
    ];
    homeManager =
      { pkgs, ... }:
      {
        packages = [ pkgs.vim ];
      };
  };
}
