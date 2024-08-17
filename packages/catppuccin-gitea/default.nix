{
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  pname = "catppuccin-gitea";
  version = "0.4.1";

  src = fetchurl {
    url = "https://github.com/catppuccin/gitea/releases/download/v0.4.1/catppuccin-gitea.tar.gz";
    hash = "sha256-/P4fLvswitlfeaKaUykrEKvjbNpw5Q/nzGQ/GZaLyUI=";
  };

  dontBuild = true;

  unpackPhase = ''
    mkdir themes
    tar xf "$src" --mode=+w --warning=no-timestamp -C themes
  '';

  installPhase = ''
    mkdir -p "$out/share/gitea-themes"
    cp -r themes/*.css "$out/share/gitea-themes/"
  '';
}
