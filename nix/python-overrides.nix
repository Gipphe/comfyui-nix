{
  pkgs,
  versions,
  gpuSupport ? "none", # "none", "cuda", "rocm"
}:
let
  lib = pkgs.lib;
  useCuda = gpuSupport == "cuda" && pkgs.stdenv.isLinux;
  useRocm = gpuSupport == "rocm" && pkgs.stdenv.isLinux;
  useDarwinArm64 = pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isAarch64;
in
final: prev:
# CUDA torch from pre-built wheels - avoids 30-60GB RAM compilation
# The wheels bundle CUDA libraries internally, providing full GPU support
lib.optionalAttrs useCuda (import ./python-overrides/cuda { inherit pkgs lib versions; } final prev)
# macOS Apple Silicon - use PyTorch 2.5.1 wheels to avoid MPS bugs on macOS 26 (Tahoe)
# PyTorch 2.9.x in nixpkgs has known issues with MPS on macOS 26
// lib.optionalAttrs useDarwinArm64 (
  import ./python-overrides/darwinArm64 { inherit pkgs lib versions; } final prev
)
# ROCm torch from pre-built wheels - avoids 30-60GB RAM compilation
# The wheels bundle ROCm libraries internally, providing full GPU support
// lib.optionalAttrs useRocm (
  import ./python-overrides/rocm { inherit pkgs lib versions; } final prev
)
# Spandrel and other packages that need explicit torch handling
// lib.optionalAttrs (prev ? torch) {
  spandrel = import ./python-overrides/spandrel.nix { inherit pkgs lib versions; } final prev;
}
# Note: When useCuda=true, torch/torchvision/torchaudio are replaced with pre-built wheels
# above. Packages that depend on torch (kornia, accelerate, etc.) will automatically
# use our wheel-based torch via final.torch since we've overridden it in the overlay.
// lib.optionalAttrs (pkgs.stdenv.isDarwin && prev ? sentencepiece) {
  sentencepiece = import ./python-overrides/sentencepiece.nix { inherit pkgs; } final prev;
}
# Note: On Darwin, av uses ffmpeg 7.x and torchaudio uses ffmpeg 6.x.
# These versions are mutually incompatible for building. The resulting runtime
# warning about duplicate Objective-C classes is harmless in practice.

# Override av (PyAV) to use pre-built wheel for comfy_api_nodes compatibility
# Using wheels avoids FFmpeg version issues (wheels bundle their own FFmpeg)
# This fixes build failures when nixpkgs has FFmpeg 8.x (AVFMT_ALLOW_FLUSH removed)
// lib.optionalAttrs (prev ? av) {
  av = import ./python-overrides/av.nix { inherit pkgs lib; } final prev;
}

# Disable tests for open-clip-torch (they hang waiting for model downloads)
// lib.optionalAttrs (prev ? open-clip-torch) {
  open-clip-torch = prev.open-clip-torch.overridePythonAttrs (old: {
    doCheck = false;
  });
}

# Disable tests for albumentations (very slow test suite, well-tested upstream)
// lib.optionalAttrs (prev ? albumentations) {
  albumentations = prev.albumentations.overridePythonAttrs (old: {
    doCheck = false;
  });
}

# Fix torchmetrics build: nixpkgs torchmetrics doesn't declare setuptools as a build backend
# dependency, so PEP517 build fails with "Cannot import 'setuptools.build_meta'".
// lib.optionalAttrs (prev ? torchmetrics) {
  torchmetrics = prev.torchmetrics.overridePythonAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      final.setuptools
      final.wheel
    ];
  });
}

# Disable accelerate test that fails with torch 2.10.0 inductor in Nix sandbox
// lib.optionalAttrs ((useCuda || useRocm) && (prev ? accelerate)) {
  accelerate = prev.accelerate.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [ "test_convert_to_fp32" ];
  });
}

# Disable failing timm test (torch dynamo/inductor test needs setuptools at runtime)
// lib.optionalAttrs (prev ? timm) {
  timm = prev.timm.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [ "test_kron" ];
    # test_optim needs setuptools at runtime (torch dynamo/inductor)
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      final.setuptools
      final.wheel
    ];
  });
}

# Relax xformers torch version requirement (relaxes torch version constraint)
# Limit build parallelism to prevent OOM during flash-attention CUDA kernel compilation
# (sm_90 CUTLASS kernels with CUDA 12.8 consume ~3GB RAM each)
// lib.optionalAttrs (prev ? xformers) {
  xformers = prev.xformers.overridePythonAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.pythonRelaxDepsHook ];
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "torch" ];
    preBuild = (old.preBuild or "") + ''
      export MAX_JOBS=2
    '';
  });
}

# Disable failing ffmpeg test for imageio (test_process_termination expects exit code 2 but gets 6)
// lib.optionalAttrs (prev ? imageio) {
  imageio = prev.imageio.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [ "test_process_termination" ];
  });
}

# Disable filterpy tests on Darwin (test_hinfinity triggers BPT trap in pytest)
// lib.optionalAttrs (prev ? filterpy) {
  filterpy = prev.filterpy.overridePythonAttrs (old: {
    doCheck = if pkgs.stdenv.isDarwin then false else (old.doCheck or true);
  });
}

# Fix bitsandbytes build - needs ninja for wheel building phase
// lib.optionalAttrs (prev ? bitsandbytes) {
  bitsandbytes = prev.bitsandbytes.overridePythonAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.ninja ];
  });
}

# color-matcher - not in older nixpkgs, needed for KJNodes
// {
  color-matcher = import ./python-overrides/color-matcher.nix { inherit pkgs versions; } final prev;
}

# facexlib - face processing library needed by PuLID
# Patched to support FACEXLIB_MODELPATH env var for read-only Nix store compatibility
// {
  facexlib = import ./python-overrides/facexlib.nix { inherit pkgs versions; } final prev;
}

# insightface - override to remove mxnet dependency for cross-platform support
# MXNet is only used for one CLI command (rec_add_mask_param.py) which we don't need.
# Face analysis uses ONNX Runtime which works on all platforms including macOS.
# This enables PuLID and other face-related nodes on macOS Apple Silicon.
// lib.optionalAttrs (prev ? insightface) {
  insightface = import ./python-overrides/insightface.nix { inherit lib; } final prev;
}

# Segment Anything Model (SAM) - not in nixpkgs
// lib.optionalAttrs (prev ? torch) {
  segment-anything = import ./python-overrides/segment-anything.nix {
    inherit pkgs lib versions;
  } final prev;

  # Segment Anything Model 2 (SAM 2) - not in nixpkgs
  sam2 = import ./python-overrides/sam2.nix { inherit pkgs lib versions; } final prev;
}
