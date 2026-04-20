{ pkgs, versions }:
final: prev:
final.buildPythonPackage {
  pname = "color-matcher";
  version = versions.vendored."color-matcher".version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = versions.vendored."color-matcher".url;
    hash = versions.vendored."color-matcher".hash;
  };
  propagatedBuildInputs = with final; [
    numpy
    pillow
    scipy
  ];
  doCheck = false;
  pythonImportsCheck = [ "color_matcher" ];
}
