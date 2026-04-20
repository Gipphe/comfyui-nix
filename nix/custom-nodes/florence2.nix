{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-florence2";
  version = versions.customNodes.florence2.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.florence2.owner;
    repo = versions.customNodes.florence2.repo;
    rev = versions.customNodes.florence2.rev;
    hash = versions.customNodes.florence2.hash;
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
      transformers
      matplotlib
      timm
      pillow
      peft
      accelerate
    ];

  meta = {
    description = "ComfyUI-Florence2 - Microsoft Florence2 VLM inference";
    homepage = "https://github.com/kijai/ComfyUI-Florence2";
    license = lib.licenses.mit;
  };
}
