# Den outputs module - exposes packages, overlays, and devShells as flake outputs
{
  imports = [
    ./packages.nix
    ./overlays.nix
    ./devshells.nix
  ];
}
