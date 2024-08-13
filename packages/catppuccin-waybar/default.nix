{
  stdenv,
  flavor ? "mocha",
  font ? "Hack Nerd Font",
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  pname = "catpuccin-waybar";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/catppuccin/waybar/releases/download/v${version}/${flavor}.css";
    hash = "sha256-llnz9uTFmEiQtbfMGSyfLb4tVspKnt9Fe5lo9GbrVpE=";
  };

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out"
    cp "$src" "$out/catppuccin.css"
  '';
}
