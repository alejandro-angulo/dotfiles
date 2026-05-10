{ ... }:
{
  den.aspects.workstation = {
    homeManager = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
