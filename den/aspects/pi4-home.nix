{ den, ... }:
{
  den.aspects."alejandro@pi4" = {
    includes = [ den.aspects.direnv ];
    homeManager.imports = [ (../../homes/aarch64-linux + "/alejandro@pi4") ];
  };
}
