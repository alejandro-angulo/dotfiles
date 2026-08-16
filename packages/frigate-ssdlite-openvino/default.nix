{
  dockerTools,
  runCommand,
}:
let
  # The official frigate image ships the default OpenVINO model (SSDLite
  # MobileNet v2, FP16 IR) at /openvino-model. nixpkgs' frigate doesn't ship
  # it, and the TF1 -> IR conversion tooling (openvino.tools.mo) was removed
  # from OpenVINO 2025+, so extract the prebuilt artifacts from the image
  # instead.
  frigateImage = dockerTools.pullImage {
    imageName = "ghcr.io/blakeblackshear/frigate";
    imageDigest = "sha256:d4351369984d4a9e2a49ac59736f6490856a7ea11f7790040746d21496967010";
    hash = "sha256-VnjWSg6Ym0hBCQn9o9ujaDyXJrMN1Y6AaFj/xVUsvw4=";
    finalImageName = "ghcr.io/blakeblackshear/frigate";
    finalImageTag = "0.17.2";
  };
in
runCommand "frigate-ssdlite-openvino" { } ''
  mkdir work
  tar -C work -xf ${frigateImage} 44be355da084d04699bbc30ab397ce368591cf8469ead9f0e0cede3ac3b1e36e.tar
  tar -C work -xf work/44be355da084d04699bbc30ab397ce368591cf8469ead9f0e0cede3ac3b1e36e.tar

  mkdir -p $out
  cp work/openvino-model/ssdlite_mobilenet_v2.xml $out/
  cp work/openvino-model/ssdlite_mobilenet_v2.bin $out/
  cp work/openvino-model/coco_91cl_bkgr.txt $out/
''
