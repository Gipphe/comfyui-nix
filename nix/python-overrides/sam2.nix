{
  pkgs,
  versions,
  lib,
}:
final: prev:
final.buildPythonPackage {
  pname = "sam2";
  version = versions.vendored.sam2.version;
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "facebookresearch";
    repo = "sam2";
    rev = versions.vendored.sam2.rev;
    hash = versions.vendored.sam2.hash;
  };

  # Patch pyproject.toml to remove torch from build dependencies
  # (we provide torch via Nix, pip can't resolve our wheel's metadata)
  postPatch = ''
    sed -i '/"torch>=2.5.1"/d' pyproject.toml
  '';

  nativeBuildInputs = [
    final.setuptools
    final.wheel
    final.pythonRelaxDepsHook
  ];

  propagatedBuildInputs = [
    final.torch # Uses final.torch - automatically CUDA/ROCm when gpuSupport="cuda|rocm"
    final.torchvision
    final.numpy
    final.pillow
    final.tqdm
    final.hydra-core
    final.iopath
    final.sympy
  ];

  # Relax version checks
  pythonRelaxDeps = [
    "torchvision"
    "torch"
    "sympy"
  ];

  doCheck = false;
  pythonImportsCheck = [ "sam2" ];

  meta = {
    description = "Segment Anything Model 2 (SAM 2) from Meta AI";
    homepage = "https://github.com/facebookresearch/sam2";
    license = lib.licenses.asl20;
  };
}
