{
  pkgs,
  lib,
  versions,
}:
final: prev:
final.buildPythonPackage {
  pname = "spandrel";
  version = versions.vendored.spandrel.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = versions.vendored.spandrel.url;
    hash = versions.vendored.spandrel.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [
    final.setuptools
    final.wheel
    final.ninja
  ];
  propagatedBuildInputs = [
    final.torch
  ] # Use final.torch - will be CUDA/ROCm when gpuSupport="cuda|rocm"
  ++ lib.optionals (prev ? torchvision) [ final.torchvision ]
  ++ lib.optionals (prev ? safetensors) [ final.safetensors ]
  ++ lib.optionals (prev ? numpy) [ final.numpy ]
  ++ lib.optionals (prev ? einops) [ final.einops ]
  ++ lib.optionals (prev ? typing-extensions) [ final.typing-extensions ];
  pythonImportsCheck = [ ];
  doCheck = false;
}
