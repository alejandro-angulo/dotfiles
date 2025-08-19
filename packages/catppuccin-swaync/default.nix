{
  stdenv,
  flavor ? "mocha",
  font ? "Hack Nerd Font",
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-swaync";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/catppuccin/swaync/releases/download/v${version}/${flavor}.css";
    hash = "sha256-Hie/vDt15nGCy4XWERGy1tUIecROw17GOoasT97kIfc=";
  };

  donBuild = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out"
    sed 's/Ubuntu Nerd Font/${font}/g' "$src" > "$out/catppuccin.css"
  '';
}
