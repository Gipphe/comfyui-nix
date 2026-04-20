{ versions }:
let
  # Pre-built PyTorch wheels for macOS Apple Silicon
  # PyTorch 2.5.1 is used instead of 2.9.x due to MPS bugs on macOS 26 (Tahoe)
  # See: https://github.com/pytorch/pytorch/issues/167679
  darwinWheels = versions.pytorchWheels.darwinArm64;
in
{
  inherit darwinWheels;
}
