{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-gguf";
  version = versions.customNodes.gguf.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.gguf.owner;
    repo = versions.customNodes.gguf.repo;
    rev = versions.customNodes.gguf.rev;
    hash = versions.customNodes.gguf.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  # Python dependencies required by ComfyUI-GGUF
  passthru.pythonDeps =
    ps: with ps; [
      gguf
      sentencepiece
      protobuf
    ];

  meta = {
    description = "ComfyUI-GGUF - GGUF quantization support for native ComfyUI models";
    homepage = "https://github.com/city96/ComfyUI-GGUF";
    license = lib.licenses.asl20;
  };
}
