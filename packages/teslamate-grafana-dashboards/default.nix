{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  pname = "teslamate-grafana-dashboards";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "teslamate-org";
    repo = "teslamate";
    rev = "v${version}";
    hash = "sha256-aX6FjOKyjsA/0IgLw/AnB01ddNk0yS6vd01BH/reBP4=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    cp "$src"/grafana/dashboards.yml "$out"
    cp -r "$src"/grafana/dashboards "$out"
  '';
}
