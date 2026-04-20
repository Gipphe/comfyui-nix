{ lib, pkgs }:
final: prev:
let
  # Use platform-specific wheels from PyPI (av 14.2.0, Python 3.12)
  wheelSrc =
    if pkgs.stdenv.isLinux && pkgs.stdenv.hostPlatform.isx86_64 then
      pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ed/e8/cf60f3fcde3d0eedee3e9ff66b674a9b85bffc907dccebbc56fb5ac4a954/av-14.2.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
        hash = "sha256-FMXwCwtg0SesDN5Gpbzptn6QW6kwM/3UiuVQwMBdUbg=";
      }
    else if pkgs.stdenv.isLinux && pkgs.stdenv.hostPlatform.isAarch64 then
      pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/d3/c3/a174388d393f1564ad4c1b8300eb4f3e972851a4d392c1eba66a6848749e/av-14.2.0-cp312-cp312-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
        hash = "sha256-iXvppmXDZd/PDBCiV/4iNSHtTTtHjmslj1X3zRP97dM=";
      }
    else if pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isx86_64 then
      pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/89/36/787af232db9b3d5bbd5eb4d1d46c51b9669cba5b2273bb68a445cb281db8/av-14.2.0-cp312-cp312-macosx_12_0_x86_64.whl";
        hash = "sha256-amqunheq5PKpczWCXApwG3Y7cqr4lCjypwu9yDtkrSM=";
      }
    else if pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isAarch64 then
      pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/5b/88/b56f5e5fa2486ee51413b043e08c7f5ed119c1e10b72725593da30adc28f/av-14.2.0-cp312-cp312-macosx_12_0_arm64.whl";
        hash = "sha256-o9o+lRFIKR1w9ss/s3v4FYCwGZLpFe8QMBCOQHb2LTg=";
      }
    else
      # Fallback to source build for unsupported platforms
      null;
in
if wheelSrc != null then
  final.buildPythonPackage {
    pname = "av";
    version = "14.2.0";
    format = "wheel";
    src = wheelSrc;
    # Wheel contains bundled FFmpeg libraries
    dontBuild = true;
    dontConfigure = true;
    propagatedBuildInputs = [ final.numpy ];
    # Linux manylinux wheels need autoPatchelfHook to fix library paths
    nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals pkgs.stdenv.isLinux [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
    ];
    pythonImportsCheck = [ "av" ];
    doCheck = false;
  }
else
  # Fallback: try original package for unsupported platforms
  prev.av
