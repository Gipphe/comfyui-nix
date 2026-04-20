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
  pname = "torch";
  version = cudaWheels.torch.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = cudaWheels.torch.url;
    hash = cudaWheels.torch.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.gnused
  ];
  buildInputs = wheelBuildInputs ++ cudaLibs;
  # libcuda.so.1 comes from the NVIDIA driver at runtime, not from cudaPackages
  autoPatchelfIgnoreMissingDeps = [ "libcuda.so.1" ];

  # Remove nvidia-* and triton dependencies from wheel metadata
  # These are provided by nixpkgs cudaPackages, not PyPI packages
  postInstall = ''
    for metadata in "$out/${final.python.sitePackages}"/torch-*.dist-info/METADATA; do
      if [[ -f "$metadata" ]]; then
        sed -i '/^Requires-Dist: nvidia-/d' "$metadata"
        sed -i '/^Requires-Dist: triton/d' "$metadata"
      fi
    done
  '';

  propagatedBuildInputs = with final; [
    filelock
    typing-extensions
    sympy
    networkx
    jinja2
    fsspec
  ];
  # Don't check for CUDA at import time (requires GPU)
  pythonImportsCheck = [ ];
  doCheck = false;

  # Passthru attributes expected by downstream packages (xformers, bitsandbytes, etc.)
  # The wheel bundles CUDA 12.8 and supports all GPU architectures
  passthru = {
    cudaSupport = true;
    rocmSupport = false;
    # All architectures supported by pre-built wheel (Pascal through Blackwell)
    cudaCapabilities = [
      "6.1"
      "7.0"
      "7.5"
      "8.0"
      "8.6"
      "8.9"
      "9.0"
      "10.0" # Blackwell (B100/B200 data center)
      "12.0" # Blackwell (RTX 50xx consumer)
    ];
    # Provide cudaPackages for packages that need it (use default version)
    cudaPackages = pkgs.cudaPackages;
    rocmPackages = { };
  };

  meta = {
    description = "PyTorch with CUDA ${cudaWheels.torch.version} (pre-built wheel)";
    homepage = "https://pytorch.org";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
