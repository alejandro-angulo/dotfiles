{ den, ... }:
{
  den.aspects."alejandro@framework" = {
    includes = [ den.aspects.workstation ];
    homeManager.imports = [ (../../homes/x86_64-linux + "/alejandro@framework") ];
  };
}
