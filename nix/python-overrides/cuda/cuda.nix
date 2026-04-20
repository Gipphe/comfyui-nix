{
  pkgs,
  versions,
}:
let

  # Pre-built PyTorch CUDA wheels from pytorch.org
  # These avoid compiling PyTorch from source (which requires 30-60GB RAM and hours of build time)
  # The wheels bundle CUDA 12.8 libraries, so no separate CUDA toolkit needed at runtime
  cudaWheels = versions.pytorchWheels.cu128;

  # Common build inputs for PyTorch wheels (manylinux compatibility)
  wheelBuildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.libGL
    pkgs.glib
  ];

  # CUDA libraries needed by PyTorch wheels (for auto-patchelf)
  cudaLibs = with pkgs.cudaPackages; [
    cuda_cudart # libcudart.so.12
    cuda_cupti # libcupti.so.12
    libcublas # libcublas.so.12, libcublasLt.so.12
    libcufft # libcufft.so.11
    libcurand # libcurand.so.10
    libcusolver # libcusolver.so.11
    libcusparse # libcusparse.so.12
    libcusparse_lt # libcusparseLt.so.0 (structured sparsity, new in cu128)
    libcufile # libcufile.so.0 (GPU Direct Storage, new in cu128)
    libnvshmem # libnvshmem_host.so.3 (multi-GPU shared memory, new in cu128)
    cudnn # libcudnn.so.9
    nccl # libnccl.so.2
    cuda_nvrtc # libnvrtc.so.12
  ];
in
{
  inherit cudaWheels cudaLibs wheelBuildInputs;
}
