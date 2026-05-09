# Den outputs module - exposes packages, overlays, devShells, deploy nodes, and domains as flake outputs
{
  imports = [
    ./packages.nix
    ./overlays.nix
    ./devshells.nix
    ./deploy.nix
    ./domains.nix
  ];
}
