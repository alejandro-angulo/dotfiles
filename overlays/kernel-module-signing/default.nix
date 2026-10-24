{ ... }:
# The kmod aggregator (since nixpkgs PR #571181) expects a per-module
# kmodigest certificate (<module>.ko.cer) next to every external module.
#
# - virtualbox: backport of NixOS/nixpkgs@7bd4fa646a08 ("linuxPackages.virtualbox:
#   enable module signing during install"). The bundled Makefile-footer.gmk
#   clears CONFIG_MODULE_SIG* during modules_install, so the modules were
#   installed unsigned. Drop this once the pinned nixpkgs includes the
#   upstream commit.
#
# - framework-laptop-kmod: its custom installPhase bypasses modules_install,
#   so the module is never signed and no certificate is emitted (build fails
#   with "cat: extra/framework_laptop.ko.cer: No such file or directory").
#   Route it through the standard modules_install flow instead. The module's
#   Makefile routes all targets through kbuild, so `make modules_install`
#   works as-is.
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

          framework-laptop-kmod = super.framework-laptop-kmod.overrideAttrs (oldAttrs: {
            makeFlags = (oldAttrs.makeFlags or [ ]) ++ [ "INSTALL_MOD_PATH=$(out)" ];
            installTargets = [ "modules_install" ];
            # Drop the custom installPhase (it only copied the unsigned .ko)
            # so the default install phase runs `make modules_install`, which
            # signs the module and emits framework_laptop.ko.cer alongside it.
            installPhase = null;
          });
        }
      );
  in
  {
    linuxPackages = enableModuleSigning prev.linuxPackages;
    linuxPackages_latest = enableModuleSigning prev.linuxPackages_latest;
  }
)
