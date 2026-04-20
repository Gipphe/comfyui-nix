{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-wanvideo";
  version = versions.customNodes.wanvideo.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.wanvideo.owner;
    repo = versions.customNodes.wanvideo.repo;
    rev = versions.customNodes.wanvideo.rev;
    hash = versions.customNodes.wanvideo.hash;
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
      ftfy
      accelerate
      peft
      diffusers
      sentencepiece
      protobuf
      gguf
      opencv4
      scipy
      einops
    ];

  meta = {
    description = "ComfyUI-WanVideoWrapper - WanVideo wrapper for ComfyUI";
    homepage = "https://github.com/kijai/ComfyUI-WanVideoWrapper";
    license = lib.licenses.asl20;
  };
}
