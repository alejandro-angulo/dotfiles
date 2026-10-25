{
  autoPatchelfHook,
  fetchFromGitHub,
  fetchurl,
  linkFarm,
  python312,
  runCommand,
  stdenv,
  zlib,
}:
# YOLOv9-t object detection model exported to ONNX at 320x320, with the COCO
# 80-class labelmap. For frigate's `yolo-generic` model type.
#
# Reproduces the export process from frigate's OpenVINO detector docs
# (https://docs.frigate.video/configuration/object_detectors/#configuration-openvino)
# as a hermetic Nix derivation instead of the docker build given there.
let
  # WongKinYiu/yolov9 main branch tip (dormant since 2024-08); the docs'
  # export process clones the repo without a pin.
  yolov9Rev = "5b1ea9a8b3f0ffe4fe0e203ec6232d788bb3fcff";
  # Available model sizes: t, s, m, c, e (see
  # https://github.com/WongKinYiu/yolov9#performance).
  modelSize = "t";
  imgSize = 320;

  python = python312;
  py = python.pkgs;

  # onnx-simplifier (`onnxsim`), the ONNX simplifier used by yolov9's
  # export.py with `--simplify`. The docs pin `onnx-simplifier==0.4.*`, but
  # that distribution was renamed to `onnxsim` and nixpkgs dropped the
  # package. Use the project's prebuilt cp312 manylinux wheel instead of
  # building its cmake/pybind11 extension from source.
  onnxsim = py.buildPythonPackage rec {
    pname = "onnxsim";
    version = "0.5.0";
    format = "wheel";

    src = fetchurl {
      # Canonical PyPI URL -- fetchPypi's legacy URL scheme 404s for
      # cp-specific wheels.
      url = "https://files.pythonhosted.org/packages/b6/51/6b96f3716f7d6e033eb8b26e96ab12287c111f6b66dbc576c2d2c6b050b8/onnxsim-${version}-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
      hash = "sha256-vzMwFyAUQNonBXuxCsoAdpaQVXCHDGNAA2/n/3Xt0mo=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [
      stdenv.cc.cc.lib
      zlib # libz.so.1
    ];
    dependencies = with py; [
      onnx
      rich
    ];
  };

  # Everything yolov9's export.py (and its import chain) needs at runtime:
  # torch, cv2, matplotlib, seaborn, IPython, pkg_resources via setuptools,
  # onnx, onnxruntime and onnxsim.
  pythonEnv = python.withPackages (
    ps: with ps; [
      torch
      torchvision
      numpy
      opencv4
      pillow
      pyyaml
      tqdm
      requests
      psutil
      pandas
      matplotlib
      seaborn
      ipython
      setuptools # pkg_resources
      onnx
      onnxruntime
      rich
      onnxsim
    ]
  );

  yolov9 = fetchFromGitHub {
    owner = "WongKinYiu";
    repo = "yolov9";
    rev = yolov9Rev;
    hash = "sha256-DJ2iM+xb00NKaomUcoe7BI/O7mHNu5ARmy/SJYsCEEg=";
  };

  weights = fetchurl {
    url = "https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-${modelSize}-converted.pt";
    hash = "sha256-YeCA6WTmXjK4hEd8XmNExgfH4CED1kZJ3oEO2uuGmAM=";
  };

  # Export the .pt checkpoint to ONNX with yolov9's export.py, applying the
  # same two adjustments as the docs' docker build:
  # - torch >= 2.6 defaults to weights_only=True for torch.load, which
  #   breaks loading the converted checkpoints
  # - the simplifier dependency is named `onnxsim` since the
  #   onnx-simplifier distribution was renamed
  onnxModel =
    runCommand "yolov9-${modelSize}-${toString imgSize}.onnx"
      {
        nativeBuildInputs = [ pythonEnv ];
      }
      ''
        cp ${weights} yolov9-${modelSize}.pt
        cp -r --no-preserve=mode ${yolov9} yolov9

        export MPLCONFIGDIR=$PWD/mplconfig
        export HOME=$PWD/home
        mkdir $MPLCONFIGDIR $HOME

        sed -i "s/ckpt = torch.load(attempt_download(w), map_location='cpu')/ckpt = torch.load(attempt_download(w), map_location='cpu', weights_only=False)/g" \
          yolov9/models/experimental.py
        sed -i "s/'onnx-simplifier>=0.4.1'/'onnxsim>=0.4.1'/g" \
          yolov9/export.py

        cd yolov9
        python export.py --weights ../yolov9-${modelSize}.pt --imgsz ${toString imgSize} --simplify --include onnx
        cp ../yolov9-${modelSize}.onnx $out
      '';

  labelmap = fetchurl {
    url = "https://raw.githubusercontent.com/blakeblackshear/frigate/v0.18.2/docker/main/rootfs/labelmap/coco-80.txt";
    hash = "sha256-Srob93QvNk8vLKcApH6ukjeAc4TBo0SNj4/MSIRmc8A=";
  };
in
linkFarm "frigate-yolov9" [
  {
    name = "yolov9-${modelSize}-${toString imgSize}.onnx";
    path = onnxModel;
  }
  {
    name = "coco-80.txt";
    path = labelmap;
  }
]
