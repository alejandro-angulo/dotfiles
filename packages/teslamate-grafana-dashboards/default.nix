{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "teslamate-grafana-dashboards";
  version = "1.30.1";

  src = fetchFromGitHub {
    owner = "teslamate-org";
    repo = "teslamate";
    rev = "v${version}";
    hash = "sha256-Iky9zWb3m/ex/amZw2dP5ZOpFw3uyg0JG6e9PkV+t4A=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    cp "$src"/grafana/dashboards.yml "$out"
    cp -r "$src"/grafana/dashboards "$out"
  '';
}
