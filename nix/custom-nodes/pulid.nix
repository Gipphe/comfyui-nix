{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "pulid-comfyui";
  version = versions.customNodes.pulid.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.pulid.owner;
    repo = versions.customNodes.pulid.repo;
    rev = versions.customNodes.pulid.rev;
    hash = versions.customNodes.pulid.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  # Face analysis dependencies - insightface works on all platforms via onnxruntime
  # (mxnet dependency is removed in python-overrides.nix for cross-platform support)
  passthru.pythonDeps =
    ps: with ps; [
      onnxruntime
      ftfy
      timm
      insightface
      facexlib
    ];

  meta = {
    description = "PuLID_ComfyUI - PuLID face ID implementation for ComfyUI";
    homepage = "https://github.com/cubiq/PuLID_ComfyUI";
    license = lib.licenses.asl20;
  };
}
