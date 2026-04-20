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
  pname = "torchvision";
  version = darwinWheels.torchvision.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = darwinWheels.torchvision.url;
    hash = darwinWheels.torchvision.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  propagatedBuildInputs = with final; [
    torch
    numpy
    pillow
  ];
  pythonImportsCheck = [ "torchvision" ];
  doCheck = false;
  meta = {
    description = "TorchVision ${darwinWheels.torchvision.version} for macOS Apple Silicon";
    homepage = "https://pytorch.org/vision";
    license = lib.licenses.bsd3;
    platforms = [ "aarch64-darwin" ];
  };
}
