{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-mmaudio";
  version = versions.customNodes.mmaudio.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.mmaudio.owner;
    repo = versions.customNodes.mmaudio.repo;
    rev = versions.customNodes.mmaudio.rev;
    hash = versions.customNodes.mmaudio.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  passthru.pythonDeps =
    ps: with ps; [
      librosa
      torchdiffeq
      einops
      timm
      omegaconf
      open-clip-torch
      accelerate
      ftfy
    ];

  meta = {
    description = "ComfyUI-MMAudio - Synchronized audio generation from video";
    homepage = "https://github.com/kijai/ComfyUI-MMAudio";
    license = lib.licenses.mit;
  };
}
