{
  linkFarm,
  fetchurl,
  ...
}:
# YOLOX-tiny object detection model (416x416) with the COCO 80-class
# labelmap, for frigate's `yolox` model type.
linkFarm "frigate-yolox-tiny" [
  {
    name = "yolox_tiny.onnx";
    path = fetchurl {
      url = "https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_tiny.onnx";
      hash = "sha256-QnzDZtNOJ/96A+KJm142cUJcJi6iKR+Iu5QrwcxwsPc=";
    };
  }
  {
    name = "coco-80.txt";
    path = fetchurl {
      url = "https://raw.githubusercontent.com/blakeblackshear/frigate/v0.17.2/docker/main/rootfs/labelmap/coco-80.txt";
      hash = "sha256-Srob93QvNk8vLKcApH6ukjeAc4TBo0SNj4/MSIRmc8A=";
    };
  }
]
