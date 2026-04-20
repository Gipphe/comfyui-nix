{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "comfyui-kjnodes";
  version = versions.customNodes.kjnodes.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.kjnodes.owner;
    repo = versions.customNodes.kjnodes.repo;
    rev = versions.customNodes.kjnodes.rev;
    hash = versions.customNodes.kjnodes.hash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  # Python dependencies required by KJNodes
  passthru.pythonDeps =
    ps: with ps; [
      color-matcher
      mss
    ];

  meta = {
    description = "ComfyUI KJNodes - Various utility nodes";
    homepage = "https://github.com/kijai/ComfyUI-KJNodes";
    license = lib.licenses.gpl3;
  };
}
