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
  pname = "torch";
  version = rocmWheels.torch.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = rocmWheels.torch.url;
    hash = rocmWheels.torch.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.gnused
  ];
  buildInputs = wheelBuildInputs ++ rocmLibs;

  # These are provided by nixpkgs rocmPackages, not PyPI packages
  postInstall = ''
    for metadata in "$out/${final.python.sitePackages}"/torch-*.dist-info/METADATA; do
      if [[ -f "$metadata" ]]; then
        sed -i '/^Requires-Dist: triton-rocm/d' "$metadata"
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
  # Don't check for ROCm at import time (requires GPU)
  pythonImportsCheck = [ ];
  doCheck = false;

  # Passthru attributes expected by downstream packages (xformers, bitsandbytes, etc.)
  # The wheel bundles ROCm 7.1 and supports all GPU architectures
  passthru = {
    cudaSupport = false;
    rocmSupport = true;
    # Provide rocmPackages for packages that need it (use default version)
    cudaPackages = { };
    rocmPackages = pkgs.rocmPackages;
  };

  meta = {
    description = "PyTorch with ROCm ${rocmWheels.torch.version} (pre-built wheel)";
    homepage = "https://pytorch.org";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
