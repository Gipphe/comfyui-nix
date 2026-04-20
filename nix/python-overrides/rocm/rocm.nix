{ pkgs, versions }:
let
  # Pre-built PyTorch ROCm wheels from pytorch.org
  # These avoid compiling PyTorch from source (which requires 30-60GB RAM and hours of build time)
  rocmWheels = versions.pytorchWheels.rocm71;

  # Common build inputs for PyTorch wheels (manylinux compatibility)
  wheelBuildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.libGL
    pkgs.glib
  ];

  # ROCm libraries needed by PyTorch wheels (for auto-patchelf)
  # The wheels bundle ROCm libraries internally; only compression libs are needed externally
  rocmLibs = (
    with pkgs;
    [
      xz # liblzma.so.5
      zstd # libzstd.so.1
      bzip2 # libbz2.so.1
    ]
  );
in
{
  inherit wheelBuildInputs rocmLibs rocmWheels;
}
