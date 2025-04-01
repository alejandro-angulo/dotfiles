{
  lib,
  beamPackages,
  overrides ? (x: y: { }),
}:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages =
    with beamPackages;
    with self;
    {
      bunt = buildMix rec {
        name = "bunt";
        version = "0.2.1";

        src = fetchHex {
          pkg = "bunt";
          version = "${version}";
          sha256 = "a330bfb4245239787b15005e66ae6845c9cd524a288f0d141c148b02603777a5";
        };

        beamDeps = [ ];
      };

      castore = buildMix rec {
        name = "castore";
        version = "1.0.4";

        src = fetchHex {
          pkg = "castore";
          version = "${version}";
          sha256 = "9418c1b8144e11656f0be99943db4caf04612e3eaecefb5dae9a2a87565584f8";
        };

        beamDeps = [ ];
      };

      certifi = buildRebar3 rec {
        name = "certifi";
        version = "2.12.0";

        src = fetchHex {
          pkg = "certifi";
          version = "${version}";
          sha256 = "ee68d85df22e554040cdb4be100f33873ac6051387baf6a8f6ce82272340ff1c";
        };

        beamDeps = [ ];
      };

      cldr_utils = buildMix rec {
        name = "cldr_utils";
        version = "2.24.2";

        src = fetchHex {
          pkg = "cldr_utils";
          version = "${version}";
          sha256 = "3362b838836a9f0fa309de09a7127e36e67310e797d556db92f71b548832c7cf";
        };

        beamDeps = [
          castore
          certifi
          decimal
        ];
      };

      cloak = buildMix rec {
        name = "cloak";
        version = "1.1.2";

        src = fetchHex {
          pkg = "cloak";
          version = "${version}";
          sha256 = "940d5ac4fcd51b252930fd112e319ea5ae6ab540b722f3ca60a85666759b9585";
        };

        beamDeps = [ jason ];
      };

      cloak_ecto = buildMix rec {
        name = "cloak_ecto";
        version = "1.2.0";

        src = fetchHex {
          pkg = "cloak_ecto";
          version = "${version}";
          sha256 = "8bcc677185c813fe64b786618bd6689b1707b35cd95acaae0834557b15a0c62f";
        };

        beamDeps = [
          cloak
          ecto
        ];
      };

      combine = buildMix rec {
        name = "combine";
        version = "0.10.0";

        src = fetchHex {
          pkg = "combine";
          version = "${version}";
          sha256 = "1b1dbc1790073076580d0d1d64e42eae2366583e7aecd455d1215b0d16f2451b";
        };

        beamDeps = [ ];
      };

      cowboy = buildErlangMk rec {
        name = "cowboy";
        version = "2.10.0";

        src = fetchHex {
          pkg = "cowboy";
          version = "${version}";
          sha256 = "3afdccb7183cc6f143cb14d3cf51fa00e53db9ec80cdcd525482f5e99bc41d6b";
        };

        beamDeps = [
          cowlib
          ranch
        ];
      };

      cowboy_telemetry = buildRebar3 rec {
        name = "cowboy_telemetry";
        version = "0.4.0";

        src = fetchHex {
          pkg = "cowboy_telemetry";
          version = "${version}";
          sha256 = "7d98bac1ee4565d31b62d59f8823dfd8356a169e7fcbb83831b8a5397404c9de";
        };

        beamDeps = [
          cowboy
          telemetry
        ];
      };

      cowlib = buildRebar3 rec {
        name = "cowlib";
        version = "2.12.1";

        src = fetchHex {
          pkg = "cowlib";
          version = "${version}";
          sha256 = "163b73f6367a7341b33c794c4e88e7dbfe6498ac42dcd69ef44c5bc5507c8db0";
        };

        beamDeps = [ ];
      };

      credo = buildMix rec {
        name = "credo";
        version = "1.7.1";

        src = fetchHex {
          pkg = "credo";
          version = "${version}";
          sha256 = "e9871c6095a4c0381c89b6aa98bc6260a8ba6addccf7f6a53da8849c748a58a2";
        };

        beamDeps = [
          bunt
          file_system
          jason
        ];
      };

      db_connection = buildMix rec {
        name = "db_connection";
        version = "2.6.0";

        src = fetchHex {
          pkg = "db_connection";
          version = "${version}";
          sha256 = "c2f992d15725e721ec7fbc1189d4ecdb8afef76648c746a8e1cad35e3b8a35f3";
        };

        beamDeps = [ telemetry ];
      };

      decimal = buildMix rec {
        name = "decimal";
        version = "2.1.1";

        src = fetchHex {
          pkg = "decimal";
          version = "${version}";
          sha256 = "53cfe5f497ed0e7771ae1a475575603d77425099ba5faef9394932b35020ffcc";
        };

        beamDeps = [ ];
      };

      dialyxir = buildMix rec {
        name = "dialyxir";
        version = "1.4.2";

        src = fetchHex {
          pkg = "dialyxir";
          version = "${version}";
          sha256 = "516603d8067b2fd585319e4b13d3674ad4f314a5902ba8130cd97dc902ce6bbd";
        };

        beamDeps = [ erlex ];
      };

      ecto = buildMix rec {
        name = "ecto";
        version = "3.10.3";

        src = fetchHex {
          pkg = "ecto";
          version = "${version}";
          sha256 = "44bec74e2364d491d70f7e42cd0d690922659d329f6465e89feb8a34e8cd3433";
        };

        beamDeps = [
          decimal
          jason
          telemetry
        ];
      };

      ecto_sql = buildMix rec {
        name = "ecto_sql";
        version = "3.10.2";

        src = fetchHex {
          pkg = "ecto_sql";
          version = "${version}";
          sha256 = "68c018debca57cb9235e3889affdaec7a10616a4e3a80c99fa1d01fdafaa9007";
        };

        beamDeps = [
          db_connection
          ecto
          postgrex
          telemetry
        ];
      };

      erlex = buildMix rec {
        name = "erlex";
        version = "0.2.6";

        src = fetchHex {
          pkg = "erlex";
          version = "${version}";
          sha256 = "2ed2e25711feb44d52b17d2780eabf998452f6efda104877a3881c2f8c0c0c75";
        };

        beamDeps = [ ];
      };

      ex_cldr = buildMix rec {
        name = "ex_cldr";
        version = "2.37.5";

        src = fetchHex {
          pkg = "ex_cldr";
          version = "${version}";
          sha256 = "74ad5ddff791112ce4156382e171a5f5d3766af9d5c4675e0571f081fe136479";
        };

        beamDeps = [
          cldr_utils
          decimal
          gettext
          jason
        ];
      };

      ex_cldr_plugs = buildMix rec {
        name = "ex_cldr_plugs";
        version = "1.3.1";

        src = fetchHex {
          pkg = "ex_cldr_plugs";
          version = "${version}";
          sha256 = "4f7b4a5fe061734cef7b62ff29118ed6ac72698cdd7bcfc97495db73611fe0fe";
        };

        beamDeps = [
          ex_cldr
          gettext
          jason
          plug
        ];
      };

      excoveralls = buildMix rec {
        name = "excoveralls";
        version = "0.18.0";

        src = fetchHex {
          pkg = "excoveralls";
          version = "${version}";
          sha256 = "1109bb911f3cb583401760be49c02cbbd16aed66ea9509fc5479335d284da60b";
        };

        beamDeps = [
          castore
          jason
        ];
      };

      expo = buildMix rec {
        name = "expo";
        version = "0.4.1";

        src = fetchHex {
          pkg = "expo";
          version = "${version}";
          sha256 = "2ff7ba7a798c8c543c12550fa0e2cbc81b95d4974c65855d8d15ba7b37a1ce47";
        };

        beamDeps = [ ];
      };

      file_system = buildMix rec {
        name = "file_system";
        version = "0.2.10";

        src = fetchHex {
          pkg = "file_system";
          version = "${version}";
          sha256 = "41195edbfb562a593726eda3b3e8b103a309b733ad25f3d642ba49696bf715dc";
        };

        beamDeps = [ ];
      };

      finch = buildMix rec {
        name = "finch";
        version = "0.16.0";

        src = fetchHex {
          pkg = "finch";
          version = "${version}";
          sha256 = "f660174c4d519e5fec629016054d60edd822cdfe2b7270836739ac2f97735ec5";
        };

        beamDeps = [
          castore
          mime
          mint
          nimble_options
          nimble_pool
          telemetry
        ];
      };

      floki = buildMix rec {
        name = "floki";
        version = "0.35.2";

        src = fetchHex {
          pkg = "floki";
          version = "${version}";
          sha256 = "6b05289a8e9eac475f644f09c2e4ba7e19201fd002b89c28c1293e7bd16773d9";
        };

        beamDeps = [ ];
      };

      fuse = buildRebar3 rec {
        name = "fuse";
        version = "2.5.0";

        src = fetchHex {
          pkg = "fuse";
          version = "${version}";
          sha256 = "7f52a1c84571731ad3c91d569e03131cc220ebaa7e2a11034405f0bac46a4fef";
        };

        beamDeps = [ ];
      };

      gen_state_machine = buildMix rec {
        name = "gen_state_machine";
        version = "3.0.0";

        src = fetchHex {
          pkg = "gen_state_machine";
          version = "${version}";
          sha256 = "0a59652574bebceb7309f6b749d2a41b45fdeda8dbb4da0791e355dd19f0ed15";
        };

        beamDeps = [ ];
      };

      gettext = buildMix rec {
        name = "gettext";
        version = "0.23.1";

        src = fetchHex {
          pkg = "gettext";
          version = "${version}";
          sha256 = "19d744a36b809d810d610b57c27b934425859d158ebd56561bc41f7eeb8795db";
        };

        beamDeps = [ expo ];
      };

      hackney = buildRebar3 rec {
        name = "hackney";
        version = "1.20.1";

        src = fetchHex {
          pkg = "hackney";
          version = "${version}";
          sha256 = "fe9094e5f1a2a2c0a7d10918fee36bfec0ec2a979994cff8cfe8058cd9af38e3";
        };

        beamDeps = [
          certifi
          idna
          metrics
          mimerl
          parse_trans
          ssl_verify_fun
          unicode_util_compat
        ];
      };

      hpax = buildMix rec {
        name = "hpax";
        version = "0.1.2";

        src = fetchHex {
          pkg = "hpax";
          version = "${version}";
          sha256 = "2c87843d5a23f5f16748ebe77969880e29809580efdaccd615cd3bed628a8c13";
        };

        beamDeps = [ ];
      };

      idna = buildRebar3 rec {
        name = "idna";
        version = "6.1.1";

        src = fetchHex {
          pkg = "idna";
          version = "${version}";
          sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
        };

        beamDeps = [ unicode_util_compat ];
      };

      jason = buildMix rec {
        name = "jason";
        version = "1.4.1";

        src = fetchHex {
          pkg = "jason";
          version = "${version}";
          sha256 = "fbb01ecdfd565b56261302f7e1fcc27c4fb8f32d56eab74db621fc154604a7a1";
        };

        beamDeps = [ decimal ];
      };

      meck = buildRebar3 rec {
        name = "meck";
        version = "0.9.2";

        src = fetchHex {
          pkg = "meck";
          version = "${version}";
          sha256 = "81344f561357dc40a8344afa53767c32669153355b626ea9fcbc8da6b3045826";
        };

        beamDeps = [ ];
      };

      metrics = buildRebar3 rec {
        name = "metrics";
        version = "1.0.1";

        src = fetchHex {
          pkg = "metrics";
          version = "${version}";
          sha256 = "69b09adddc4f74a40716ae54d140f93beb0fb8978d8636eaded0c31b6f099f16";
        };

        beamDeps = [ ];
      };

      mime = buildMix rec {
        name = "mime";
        version = "2.0.5";

        src = fetchHex {
          pkg = "mime";
          version = "${version}";
          sha256 = "da0d64a365c45bc9935cc5c8a7fc5e49a0e0f9932a761c55d6c52b142780a05c";
        };

        beamDeps = [ ];
      };

      mimerl = buildRebar3 rec {
        name = "mimerl";
        version = "1.2.0";

        src = fetchHex {
          pkg = "mimerl";
          version = "${version}";
          sha256 = "f278585650aa581986264638ebf698f8bb19df297f66ad91b18910dfc6e19323";
        };

        beamDeps = [ ];
      };

      mint = buildMix rec {
        name = "mint";
        version = "1.5.1";

        src = fetchHex {
          pkg = "mint";
          version = "${version}";
          sha256 = "4a63e1e76a7c3956abd2c72f370a0d0aecddc3976dea5c27eccbecfa5e7d5b1e";
        };

        beamDeps = [
          castore
          hpax
        ];
      };

      mock = buildMix rec {
        name = "mock";
        version = "0.3.8";

        src = fetchHex {
          pkg = "mock";
          version = "${version}";
          sha256 = "7fa82364c97617d79bb7d15571193fc0c4fe5afd0c932cef09426b3ee6fe2022";
        };

        beamDeps = [ meck ];
      };

      nimble_csv = buildMix rec {
        name = "nimble_csv";
        version = "1.2.0";

        src = fetchHex {
          pkg = "nimble_csv";
          version = "${version}";
          sha256 = "d0628117fcc2148178b034044c55359b26966c6eaa8e2ce15777be3bbc91b12a";
        };

        beamDeps = [ ];
      };

      nimble_options = buildMix rec {
        name = "nimble_options";
        version = "1.0.2";

        src = fetchHex {
          pkg = "nimble_options";
          version = "${version}";
          sha256 = "fd12a8db2021036ce12a309f26f564ec367373265b53e25403f0ee697380f1b8";
        };

        beamDeps = [ ];
      };

      nimble_pool = buildMix rec {
        name = "nimble_pool";
        version = "1.0.0";

        src = fetchHex {
          pkg = "nimble_pool";
          version = "${version}";
          sha256 = "80be3b882d2d351882256087078e1b1952a28bf98d0a287be87e4a24a710b67a";
        };

        beamDeps = [ ];
      };

      parse_trans = buildRebar3 rec {
        name = "parse_trans";
        version = "3.4.1";

        src = fetchHex {
          pkg = "parse_trans";
          version = "${version}";
          sha256 = "620a406ce75dada827b82e453c19cf06776be266f5a67cff34e1ef2cbb60e49a";
        };

        beamDeps = [ ];
      };

      phoenix = buildMix rec {
        name = "phoenix";
        version = "1.6.16";

        src = fetchHex {
          pkg = "phoenix";
          version = "${version}";
          sha256 = "e15989ff34f670a96b95ef6d1d25bad0d9c50df5df40b671d8f4a669e050ac39";
        };

        beamDeps = [
          castore
          jason
          phoenix_pubsub
          phoenix_view
          plug
          plug_cowboy
          plug_crypto
          telemetry
        ];
      };

      phoenix_ecto = buildMix rec {
        name = "phoenix_ecto";
        version = "4.4.3";

        src = fetchHex {
          pkg = "phoenix_ecto";
          version = "${version}";
          sha256 = "d36c401206f3011fefd63d04e8ef626ec8791975d9d107f9a0817d426f61ac07";
        };

        beamDeps = [
          ecto
          phoenix_html
          plug
        ];
      };

      phoenix_html = buildMix rec {
        name = "phoenix_html";
        version = "3.3.3";

        src = fetchHex {
          pkg = "phoenix_html";
          version = "${version}";
          sha256 = "923ebe6fec6e2e3b3e569dfbdc6560de932cd54b000ada0208b5f45024bdd76c";
        };

        beamDeps = [ plug ];
      };

      phoenix_live_reload = buildMix rec {
        name = "phoenix_live_reload";
        version = "1.4.1";

        src = fetchHex {
          pkg = "phoenix_live_reload";
          version = "${version}";
          sha256 = "9bffb834e7ddf08467fe54ae58b5785507aaba6255568ae22b4d46e2bb3615ab";
        };

        beamDeps = [
          file_system
          phoenix
        ];
      };

      phoenix_live_view = buildMix rec {
        name = "phoenix_live_view";
        version = "0.17.14";

        src = fetchHex {
          pkg = "phoenix_live_view";
          version = "${version}";
          sha256 = "afeb6ba43ce329a6f7fc1c9acdfc6d3039995345f025febb7f409a92f6faebd3";
        };

        beamDeps = [
          jason
          phoenix
          phoenix_html
          telemetry
        ];
      };

      phoenix_pubsub = buildMix rec {
        name = "phoenix_pubsub";
        version = "2.1.3";

        src = fetchHex {
          pkg = "phoenix_pubsub";
          version = "${version}";
          sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
        };

        beamDeps = [ ];
      };

      phoenix_template = buildMix rec {
        name = "phoenix_template";
        version = "1.0.3";

        src = fetchHex {
          pkg = "phoenix_template";
          version = "${version}";
          sha256 = "16f4b6588a4152f3cc057b9d0c0ba7e82ee23afa65543da535313ad8d25d8e2c";
        };

        beamDeps = [ phoenix_html ];
      };

      phoenix_view = buildMix rec {
        name = "phoenix_view";
        version = "2.0.3";

        src = fetchHex {
          pkg = "phoenix_view";
          version = "${version}";
          sha256 = "cd34049af41be2c627df99cd4eaa71fc52a328c0c3d8e7d4aa28f880c30e7f64";
        };

        beamDeps = [
          phoenix_html
          phoenix_template
        ];
      };

      plug = buildMix rec {
        name = "plug";
        version = "1.15.1";

        src = fetchHex {
          pkg = "plug";
          version = "${version}";
          sha256 = "459497bd94d041d98d948054ec6c0b76feacd28eec38b219ca04c0de13c79d30";
        };

        beamDeps = [
          mime
          plug_crypto
          telemetry
        ];
      };

      plug_cowboy = buildMix rec {
        name = "plug_cowboy";
        version = "2.6.1";

        src = fetchHex {
          pkg = "plug_cowboy";
          version = "${version}";
          sha256 = "de36e1a21f451a18b790f37765db198075c25875c64834bcc82d90b309eb6613";
        };

        beamDeps = [
          cowboy
          cowboy_telemetry
          plug
        ];
      };

      plug_crypto = buildMix rec {
        name = "plug_crypto";
        version = "1.2.5";

        src = fetchHex {
          pkg = "plug_crypto";
          version = "${version}";
          sha256 = "26549a1d6345e2172eb1c233866756ae44a9609bd33ee6f99147ab3fd87fd842";
        };

        beamDeps = [ ];
      };

      postgrex = buildMix rec {
        name = "postgrex";
        version = "0.17.3";

        src = fetchHex {
          pkg = "postgrex";
          version = "${version}";
          sha256 = "946cf46935a4fdca7a81448be76ba3503cff082df42c6ec1ff16a4bdfbfb098d";
        };

        beamDeps = [
          db_connection
          decimal
          jason
        ];
      };

      ranch = buildRebar3 rec {
        name = "ranch";
        version = "1.8.0";

        src = fetchHex {
          pkg = "ranch";
          version = "${version}";
          sha256 = "49fbcfd3682fab1f5d109351b61257676da1a2fdbe295904176d5e521a2ddfe5";
        };

        beamDeps = [ ];
      };

      srtm = buildMix rec {
        name = "srtm";
        version = "0.8.0";

        src = fetchHex {
          pkg = "srtm";
          version = "${version}";
          sha256 = "7ec2a2ced7c3c0c1bdcfca67ce4d466d77e66cf52589f546c91b96b4c79b6923";
        };

        beamDeps = [ castore ];
      };

      ssl_verify_fun = buildRebar3 rec {
        name = "ssl_verify_fun";
        version = "1.1.7";

        src = fetchHex {
          pkg = "ssl_verify_fun";
          version = "${version}";
          sha256 = "fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8";
        };

        beamDeps = [ ];
      };

      telemetry = buildRebar3 rec {
        name = "telemetry";
        version = "1.2.1";

        src = fetchHex {
          pkg = "telemetry";
          version = "${version}";
          sha256 = "dad9ce9d8effc621708f99eac538ef1cbe05d6a874dd741de2e689c47feafed5";
        };

        beamDeps = [ ];
      };

      tesla = buildMix rec {
        name = "tesla";
        version = "1.8.0";

        src = fetchHex {
          pkg = "tesla";
          version = "${version}";
          sha256 = "10501f360cd926a309501287470372af1a6e1cbed0f43949203a4c13300bc79f";
        };

        beamDeps = [
          castore
          finch
          fuse
          hackney
          jason
          mime
          mint
          telemetry
        ];
      };

      timex = buildMix rec {
        name = "timex";
        version = "3.7.11";

        src = fetchHex {
          pkg = "timex";
          version = "${version}";
          sha256 = "8b9024f7efbabaf9bd7aa04f65cf8dcd7c9818ca5737677c7b76acbc6a94d1aa";
        };

        beamDeps = [
          combine
          gettext
          tzdata
        ];
      };

      tortoise = buildMix rec {
        name = "tortoise";
        version = "0.10.0";

        src = fetchHex {
          pkg = "tortoise";
          version = "${version}";
          sha256 = "926d97b03cd0d2f6e0e1ebf06c1efa50101de96d0317dea5604c1c9e43e66735";
        };

        beamDeps = [ gen_state_machine ];
      };

      tzdata = buildMix rec {
        name = "tzdata";
        version = "1.1.1";

        src = fetchHex {
          pkg = "tzdata";
          version = "${version}";
          sha256 = "a69cec8352eafcd2e198dea28a34113b60fdc6cb57eb5ad65c10292a6ba89787";
        };

        beamDeps = [ hackney ];
      };

      unicode_util_compat = buildRebar3 rec {
        name = "unicode_util_compat";
        version = "0.7.0";

        src = fetchHex {
          pkg = "unicode_util_compat";
          version = "${version}";
          sha256 = "25eee6d67df61960cf6a794239566599b09e17e668d3700247bc498638152521";
        };

        beamDeps = [ ];
      };

      websockex = buildMix rec {
        name = "websockex";
        version = "0.4.3";

        src = fetchHex {
          pkg = "websockex";
          version = "${version}";
          sha256 = "95f2e7072b85a3a4cc385602d42115b73ce0b74a9121d0d6dbbf557645ac53e4";
        };

        beamDeps = [ ];
      };
    };
in
self
