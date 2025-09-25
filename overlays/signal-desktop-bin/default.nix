{ ... }:
(final: prev: {
  signal-desktop-bin = prev.signal-desktop-bin.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.makeWrapper ];
    postInstall = oldAttrs.postInstall or "" + ''
      wrapProgram $out/bin/signal-desktop \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  });
})
