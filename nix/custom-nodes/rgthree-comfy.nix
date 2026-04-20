{
  lib,
  stdenv,
  fetchFromGitHub,
  versions,
}:
stdenv.mkDerivation {
  pname = "rgthree-comfy";
  version = versions.customNodes.rgthree-comfy.version;

  src = fetchFromGitHub {
    owner = versions.customNodes.rgthree-comfy.owner;
    repo = versions.customNodes.rgthree-comfy.repo;
    rev = versions.customNodes.rgthree-comfy.rev;
    hash = versions.customNodes.rgthree-comfy.hash;
  };

  # Convert CRLF to LF and patch __init__.py to use WEB_DIRECTORY
  # instead of shutil.copytree (which fails with read-only Nix store)
  postPatch = ''
    # Convert line endings
    sed -i 's/\r$//' __init__.py py/power_prompt.py

    # Remove shutil import and PromptServer import
    sed -i '/^import shutil$/d' __init__.py
    sed -i '/^from server import PromptServer$/d' __init__.py

    # Replace the copytree logic with WEB_DIRECTORY
    sed -i '/^DIR_WEB_JS=/,/^shutil.copytree/d' __init__.py
    sed -i '/^DIR_PY=/a # Use ComfyUI'"'"'s WEB_DIRECTORY for serving web assets (Nix-compatible)' __init__.py
    sed -i '/WEB_DIRECTORY for serving/a WEB_DIRECTORY = "./js"' __init__.py

    # Fix SyntaxWarning: invalid escape sequence in power_prompt.py
    # Change pattern='<lora:...' to pattern=r'<lora:...'
    sed -i "s/pattern='<lora:/pattern=r'<lora:/" py/power_prompt.py
  '';

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  # No additional Python dependencies needed
  passthru.pythonDeps = ps: [ ];

  meta = {
    description = "rgthree-comfy - Quality of life nodes for ComfyUI";
    homepage = "https://github.com/rgthree/rgthree-comfy";
    license = lib.licenses.mit;
  };
}
