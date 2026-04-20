{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-bitsandbytes-nf4";
  version = versions.customNodes.bitsandbytes-nf4.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.bitsandbytes-nf4.owner;
    repo = versions.customNodes.bitsandbytes-nf4.repo;
    rev = versions.customNodes.bitsandbytes-nf4.rev;
    hash = versions.customNodes.bitsandbytes-nf4.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  passthru.pythonDeps = ps: [ ps.bitsandbytes ];

  meta = {
    description = "ComfyUI_bitsandbytes_NF4 - NF4 quantization for Flux models";
    homepage = "https://github.com/comfyanonymous/ComfyUI_bitsandbytes_NF4";
    license = lib.licenses.agpl3Only;
  };
}
