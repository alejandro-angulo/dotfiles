{
  stdenv,
  lib,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "teslamate-grafana-dashboards";
  version = "1.28.2";

  src = fetchFromGitHub {
    owner = "teslamate-org";
    repo = "teslamate";
    rev = "v${version}";
    hash = "sha256-CH3u6ijzvVdjfTVu06UcyW4NhVQKeUKtC/j+UeDELNc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    cp "$src"/grafana/dashboards.yml "$out"
    cp -r "$src"/grafana/dashboards "$out"
  '';
}
