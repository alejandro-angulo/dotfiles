{
  nixpkgs-nginx,
  ...
}:
# Temporary security pin: the nixpkgs-unstable channel snapshot this flake is
# locked to still ships nginx 1.30.6, which is affected by the nginx security
# releases of 2026-11-18, including the critical HTTP/2 RCE CVE-2026-123007
# (fixed in nginx 1.30.7 stable / 1.31.9 mainline).
#
# This overlay takes nginx from a nixpkgs revision containing the bump so the
# rest of the lock stays untouched. Drop this overlay (and the nixpkgs-nginx
# input in flake.nix) once the pinned nixpkgs includes nginx 1.30.7.
(final: prev: {
  nginx = nixpkgs-nginx.legacyPackages.${prev.stdenv.hostPlatform.system}.nginx;
  # The NixOS nginx module defaults to `services.nginx.package = pkgs.nginxStable`.
  nginxStable = nixpkgs-nginx.legacyPackages.${prev.stdenv.hostPlatform.system}.nginxStable;
  nginxMainline = nixpkgs-nginx.legacyPackages.${prev.stdenv.hostPlatform.system}.nginxMainline;
})
