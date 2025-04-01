{
  lib,
  callPackage,
  beamPackages,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  breakpointHook,
  ...
}:
let
  pname = "teslamate";
  version = "1.28.2";

  src = fetchFromGitHub {
    owner = "teslamate-org";
    repo = "teslamate";
    rev = "v${version}";
    hash = "sha256-CH3u6ijzvVdjfTVu06UcyW4NhVQKeUKtC/j+UeDELNc=";
  };

  mixNixDeps = import ./mix.nix {
    inherit beamPackages lib;

    overrides = (
      final: prev:
      (lib.mapAttrs (
        _: value:
        value.override {
          appConfigPath = src + "/config";
        }
      ) prev)
      // {
        ex_cldr = prev.ex_cldr.overrideAttrs (old: rec {
          # Copied from https://github.com/NixOS/nixpkgs/blob/d8fd23629b3910e8bdbd313e29532d3e33dd73d5/pkgs/servers/mobilizon/default.nix#L34-L47
          version = "2.37.5";
          # We have to use the GitHub sources, as it otherwise tries to download
          # the locales at build time.
          src = fetchFromGitHub {
            owner = "elixir-cldr";
            repo = "cldr";
            rev = "v${version}";
            sha256 = "sha256-T5Qvuo+xPwpgBsqHNZYnTCA4loToeBn1LKTMsDcCdYs=";
          };
          postInstall = ''
            cp $src/priv/cldr/locales/* $out/lib/erlang/lib/ex_cldr-${old.version}/priv/cldr/locales/
          '';
        });
      }
    );
  };

  assets = buildNpmPackage {
    pname = "${pname}-assets";
    inherit version;
    src = "${src}/assets";
    npmDepsHash = "sha256-h92i/cRf4I0c4vUc6oBt5T4yvM0JNQMkoDy2YHcVWS4=";
    patches = [ ./deploy_output.patch ];
    dontNpmBuild = true;
    installPhase = ''
      runHook preinstall

      rm ./node_modules/phoenix
      cp -r ${mixNixDeps.phoenix}/src ./node_modules/phoenix

      rm ./node_modules/phoenix_live_view
      cp -r ${mixNixDeps.phoenix_live_view}/src ./node_modules/phoenix_live_view

      rm ./node_modules/phoenix_html
      cp -r ${mixNixDeps.phoenix_html}/src ./node_modules/phoenix_html

      npm run deploy
      cp -r . "$out"
      runHook postInstall
    '';
  };
in
beamPackages.mixRelease {
  inherit
    pname
    version
    src
    mixNixDeps
    ;

  nativeBuildInputs = [ nodejs ];

  preBuild = ''
    mkdir -p priv/static/assets
    # assets patched to write to scripts/deploy_output
    cp -r ${assets}/scripts/deploy_output ./priv/static/assets
  '';

  postBuild = ''
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check phx.digest, release --overwrite
  '';
}
