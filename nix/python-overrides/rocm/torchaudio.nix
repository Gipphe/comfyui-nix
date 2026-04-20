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
  pname = "torchaudio";
  version = rocmWheels.torchaudio.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = rocmWheels.torchaudio.url;
    hash = rocmWheels.torchaudio.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = wheelBuildInputs ++ rocmLibs ++ [ final.torch ];
  # Ignore torch libs (loaded via Python) and FFmpeg/sox libs (optional, multiple versions bundled)
  autoPatchelfIgnoreMissingDeps = [
    # Torch libs (loaded via Python import)
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
    description = "TorchAudio with ROCm (pre-built wheel)";
    homepage = "https://pytorch.org/audio";
    license = lib.licenses.bsd2;
    platforms = [ "x86_64-linux" ];
  };
}
