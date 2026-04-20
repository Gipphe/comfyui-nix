{
  pkgs,
  lib,
  versions,
}:
let
  inherit (import ./darwinArm64.nix { inherit versions; }) darwinWheels;
in
final: prev:
final.buildPythonPackage {
  pname = "torch";
  version = darwinWheels.torch.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = darwinWheels.torch.url;
    hash = darwinWheels.torch.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  propagatedBuildInputs = with final; [
    filelock
    typing-extensions
    sympy
    networkx
    jinja2
    fsspec
  ];
  pythonImportsCheck = [ "torch" ];
  doCheck = false;

  passthru = {
    cudaSupport = false;
    rocmSupport = false;
  };

  meta = {
    description = "PyTorch ${darwinWheels.torch.version} for macOS Apple Silicon (MPS)";
    homepage = "https://pytorch.org";
    license = lib.licenses.bsd3;
    platforms = [ "aarch64-darwin" ];
  };
}
