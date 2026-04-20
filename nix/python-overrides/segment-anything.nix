{
  pkgs,
  lib,
  versions,
}:
final: prev:
final.buildPythonPackage {
  pname = "segment-anything";
  version = versions.vendored.segment-anything.version;
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "facebookresearch";
    repo = "segment-anything";
    rev = versions.vendored.segment-anything.rev;
    hash = versions.vendored.segment-anything.hash;
  };

  nativeBuildInputs = [
    final.setuptools
    final.wheel
  ];

  propagatedBuildInputs = [
    final.torch # Uses final.torch - automatically CUDA/ROCm when gpuSupport="cuda|rocm"
    final.torchvision
    final.numpy
    final.opencv4
    final.matplotlib
    final.pillow
  ];

  doCheck = false;
  pythonImportsCheck = [ "segment_anything" ];

  meta = {
    description = "Segment Anything Model (SAM) from Meta AI";
    homepage = "https://github.com/facebookresearch/segment-anything";
    license = lib.licenses.asl20;
  };
}
