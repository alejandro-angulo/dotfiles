{
  stdenv,
  flavor ? "mocha",
  font ? "Hack Nerd Font",
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-swaync";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/catppuccin/swaync/releases/download/v${version}/catppuccin-${flavor}.css";
    hash = "sha256-EKTAKCU9HlxrrVjNhyMRq7WGfz8DM9IFPUIEGl3nHbo=";
  };

  donBuild = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out"
    sed 's/Ubuntu Nerd Font/${font}/g' "$src" > "$out/catppuccin.css"
  '';
}
