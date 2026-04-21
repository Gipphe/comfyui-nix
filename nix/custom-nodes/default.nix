# Custom node packages for ComfyUI
#
# These are pre-packaged custom nodes with their source code.
# Python dependencies are provided by the main ComfyUI environment.
#
# Users can reference these in their NixOS config:
#
#   services.comfyui.customNodes = {
#     impact-pack = comfyui-nix.customNodes.impact-pack;
#   };
#
{ pkgs, versions }:
{
  # Impact Pack custom node
  impact-pack = pkgs.callPackage ./impact-pack.nix { inherit versions; };

  # rgthree-comfy - Quality of life nodes
  rgthree-comfy = pkgs.callPackage ./rgthree-comfy.nix { inherit versions; };

  # KJNodes - Utility nodes
  kjnodes = pkgs.callPackage ./kjnodes.nix { inherit versions; };

  # ComfyUI-GGUF - GGUF quantization support for native ComfyUI models
  gguf = pkgs.callPackage ./gguf.nix { inherit versions; };

  # ComfyUI-LTXVideo - LTX-Video support for ComfyUI
  ltxvideo = pkgs.callPackage ./ltxvideo.nix { inherit versions; };

  # ComfyUI-Florence2 - Microsoft Florence2 VLM inference
  florence2 = pkgs.callPackage ./florence2.nix { inherit versions; };

  # ComfyUI_bitsandbytes_NF4 - NF4 quantization support
  bitsandbytes-nf4 = pkgs.callPackage ./bitsandbytes-nf4.nix { inherit versions; };

  # x-flux-comfyui - XLabs Flux LoRA and ControlNet
  x-flux = pkgs.callPackage ./x-flux.nix { inherit versions; };

  # ComfyUI-MMAudio - Audio generation from video
  mmaudio = pkgs.callPackage ./mmaudio.nix { inherit versions; };

  # PuLID_ComfyUI - PuLID face ID for ComfyUI
  pulid = pkgs.callPackage ./pulid.nix { inherit versions; };

  # ComfyUI-WanVideoWrapper - WanVideo wrapper for ComfyUI
  wanvideo = pkgs.callPackage ./wanvideo.nix { inherit versions; };
}
