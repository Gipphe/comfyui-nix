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
  pname = "torchaudio";
  version = darwinWheels.torchaudio.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = darwinWheels.torchaudio.url;
    hash = darwinWheels.torchaudio.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  propagatedBuildInputs = with final; [
    torch
  ];
  pythonImportsCheck = [ "torchaudio" ];
  doCheck = false;
  meta = {
    description = "TorchAudio ${darwinWheels.torchaudio.version} for macOS Apple Silicon";
    homepage = "https://pytorch.org/audio";
    license = lib.licenses.bsd2;
    platforms = [ "aarch64-darwin" ];
  };
}
