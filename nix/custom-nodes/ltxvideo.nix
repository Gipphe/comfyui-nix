{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-ltxvideo";
  version = versions.customNodes.ltxvideo.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.ltxvideo.owner;
    repo = versions.customNodes.ltxvideo.repo;
    rev = versions.customNodes.ltxvideo.rev;
    hash = versions.customNodes.ltxvideo.hash;
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
      diffusers
      einops
      huggingface-hub
      transformers
      timm
    ];

  meta = {
    description = "ComfyUI-LTXVideo - LTX-Video support for ComfyUI";
    homepage = "https://github.com/Lightricks/ComfyUI-LTXVideo";
    license = lib.licenses.asl20;
  };
}
