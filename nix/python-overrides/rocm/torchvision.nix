{
  pkgs,
  lib,
  versions,
}:
let
  inherit (import ./rocm.nix { inherit pkgs versions; })
    rocmLibs
    wheelBuildInputs
    rocmWheels
    ;
in
final: prev:
final.buildPythonPackage {
  pname = "torchvision";
  version = rocmWheels.torchvision.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = rocmWheels.torchvision.url;
    hash = rocmWheels.torchvision.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = wheelBuildInputs ++ rocmLibs ++ [ final.torch ];

  # Ignore torch libs (loaded via Python import)
  autoPatchelfIgnoreMissingDeps = [
    "libc10.so"
    "libc10_hip.so"
    "libamdhip64.so.7"
    "libtorch.so"
    "libtorch_cpu.so"
    "libtorch_hip.so"
    "libtorch_python.so"
    "libhipblas.so.3"
    "libhipfft.so.0"
    "libhipsolver.so.1"
    "libhipsparse.so.4"
    "libMIOpen.so.1"
    "librocrand.so.1"
  ];
  propagatedBuildInputs = with final; [
    torch
    numpy
    pillow
  ];
  pythonImportsCheck = [ ];
  doCheck = false;
  meta = {
    description = "TorchVision with ROCm (pre-built wheel)";
    homepage = "https://pytorch.org/vision";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
