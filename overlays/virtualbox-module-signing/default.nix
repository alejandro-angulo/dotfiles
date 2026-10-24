{ ... }:
# Backport of NixOS/nixpkgs@7bd4fa646a08 ("linuxPackages.virtualbox: enable
# module signing during install"). The bundled Makefile-footer.gmk clears
# CONFIG_MODULE_SIG* during modules_install, so the modules were installed
# unsigned and without the per-module certificate that the kmod aggregator
# expects since PR #571181. Drop this once the pinned nixpkgs includes the
# upstream commit.
(
  final: prev:
  let
    enableModuleSigning =
      linuxPackages:
      linuxPackages.extend (
        self: super: {
          virtualbox = super.virtualbox.overrideAttrs (oldAttrs: {
            makeFlags =
              self.kernelModuleMakeFlags ++ (oldAttrs.makeFlags or [ ]) ++ [ "VBOX_ALLOW_MODULE_SIGNING=1" ];
          });
        }
      );
  in
  {
    linuxPackages = enableModuleSigning prev.linuxPackages;
    linuxPackages_latest = enableModuleSigning prev.linuxPackages_latest;
  }
)
