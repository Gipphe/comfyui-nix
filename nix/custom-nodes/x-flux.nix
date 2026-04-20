{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "x-flux-comfyui";
  version = versions.customNodes.x-flux.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.x-flux.owner;
    repo = versions.customNodes.x-flux.repo;
    rev = versions.customNodes.x-flux.rev;
    hash = versions.customNodes.x-flux.hash;
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
      gitpython
      einops
      transformers
      diffusers
      sentencepiece
      opencv4
    ];

  meta = {
    description = "x-flux-comfyui - XLabs Flux LoRA and ControlNet support";
    homepage = "https://github.com/XLabs-AI/x-flux-comfyui";
    license = lib.licenses.asl20;
  };
}
