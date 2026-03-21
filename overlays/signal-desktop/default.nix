{ ... }:
(final: prev: {
  signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.makeWrapper ];
    postInstall = oldAttrs.postInstall or "" + ''
      wrapProgram $out/bin/signal-desktop \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  });
})
