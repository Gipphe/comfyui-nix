{
  pkgs,
  versions,
  lib,
}:
final: prev:
let
  inherit (import ./cuda.nix { inherit pkgs versions; })
    cudaWheels
    cudaLibs
    wheelBuildInputs
    ;
in
final.buildPythonPackage {
  pname = "torchaudio";
  version = cudaWheels.torchaudio.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = cudaWheels.torchaudio.url;
    hash = cudaWheels.torchaudio.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = wheelBuildInputs ++ cudaLibs ++ [ final.torch ];
  # Ignore torch libs (loaded via Python) and FFmpeg/sox libs (optional, multiple versions bundled)
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    # Torch libs (loaded via Python import)
    "libtorch.so"
    "libtorch_cpu.so"
    "libtorch_cuda.so"
    "libtorch_python.so"
    "libc10.so"
    "libc10_cuda.so"
    # Sox (optional audio backend)
    "libsox.so"
    # FFmpeg 4.x
    "libavutil.so.56"
    "libavcodec.so.58"
    "libavformat.so.58"
    "libavfilter.so.7"
    "libavdevice.so.58"
    # FFmpeg 5.x
    "libavutil.so.57"
    "libavcodec.so.59"
    "libavformat.so.59"
    "libavfilter.so.8"
    "libavdevice.so.59"
    # FFmpeg 6.x
    "libavutil.so.58"
    "libavcodec.so.60"
    "libavformat.so.60"
    "libavfilter.so.9"
    "libavdevice.so.60"
  ];
  propagatedBuildInputs = with final; [
    torch
  ];
  pythonImportsCheck = [ ];
  doCheck = false;
  meta = {
    description = "TorchAudio with CUDA (pre-built wheel)";
    homepage = "https://pytorch.org/audio";
    license = lib.licenses.bsd2;
    platforms = [ "x86_64-linux" ];
  };
}
