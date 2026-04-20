{
  lib,
  pkgs,
  versions,
}:
let
  inherit (import ./cuda.nix { inherit pkgs versions; })
    cudaWheels
    cudaLibs
    wheelBuildInputs
    ;
in
final: prev:
final.buildPythonPackage {
  pname = "torchvision";
  version = cudaWheels.torchvision.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = cudaWheels.torchvision.url;
    hash = cudaWheels.torchvision.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = wheelBuildInputs ++ cudaLibs ++ [ final.torch ];
  # Ignore torch libs (loaded via Python import)
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libtorch.so"
    "libtorch_cpu.so"
    "libtorch_cuda.so"
    "libtorch_python.so"
    "libc10.so"
    "libc10_cuda.so"
  ];
  propagatedBuildInputs = with final; [
    torch
    numpy
    pillow
  ];
  pythonImportsCheck = [ ];
  doCheck = false;
  meta = {
    description = "TorchVision with CUDA (pre-built wheel)";
    homepage = "https://pytorch.org/vision";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
