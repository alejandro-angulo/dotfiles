{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "teslamate-grafana-dashboards";
  version = "1.32.0";

  src = fetchFromGitHub {
    owner = "teslamate-org";
    repo = "teslamate";
    rev = "v${version}";
    hash = "sha256-diQRtJYfzGIVLxrdBad3XKWCtR97rj9Q1ZJ9MmvJGRk=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    cp "$src"/grafana/dashboards.yml "$out"
    cp -r "$src"/grafana/dashboards "$out"
  '';
}
