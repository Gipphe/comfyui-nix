{
  pkgs,
  lib,
  versions,
}:
final: prev: {
  torch = import ./torch.nix { inherit lib pkgs versions; } final prev;
  torchvision = import ./torchvision.nix { inherit lib pkgs versions; } final prev;
  torchaudio = import ./torchaudio.nix { inherit lib pkgs versions; } final prev;
}
