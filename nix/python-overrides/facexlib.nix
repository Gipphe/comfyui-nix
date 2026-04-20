{ pkgs, versions }:
final: prev:
final.buildPythonPackage {
  pname = "facexlib";
  version = versions.vendored.facexlib.version;
  format = "wheel";
  src = pkgs.fetchurl {
    url = versions.vendored.facexlib.url;
    hash = versions.vendored.facexlib.hash;
  };
  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ pkgs.gnused ];
  propagatedBuildInputs = with final; [
    numpy
    opencv4
    pillow
    torch
    torchvision
    filterpy
    numba
  ];

  # Patch misc.py to respect FACEXLIB_MODELPATH environment variable
  # This allows redirecting model downloads away from the read-only Nix store
  postInstall = ''
    miscPy="$out/${final.python.sitePackages}/facexlib/utils/misc.py"
    if [[ -f "$miscPy" ]]; then
      sed -i 's|^ROOT_DIR = os.path.dirname.*|_DEFAULT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))\nROOT_DIR = os.environ.get("FACEXLIB_MODELPATH", _DEFAULT_ROOT)|' "$miscPy"
    fi
  '';

  doCheck = false;
  pythonImportsCheck = [ "facexlib" ];
}
