{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-impact-pack";
  version = versions.customNodes.impact-pack.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.impact-pack.owner;
    repo = versions.customNodes.impact-pack.repo;
    rev = versions.customNodes.impact-pack.rev;
    hash = versions.customNodes.impact-pack.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  # Python dependencies required by Impact Pack
  passthru.pythonDeps =
    ps: with ps; [
      scikit-image
      piexif
      scipy
      numpy
      opencv4
      matplotlib
      dill
      segment-anything
      sam2
    ];

  meta = {
    description = "ComfyUI Impact Pack - Detection, segmentation, and more";
    homepage = "https://github.com/ltdrdata/ComfyUI-Impact-Pack";
    license = lib.licenses.gpl3;
  };
}
