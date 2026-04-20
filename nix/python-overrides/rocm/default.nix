{
  pkgs,
  lib,
  versions,
}:
final: prev: {
  torch = import ./torch.nix { inherit pkgs lib versions; } final prev;
  torchvision = import ./torchvision.nix { inherit pkgs lib versions; } final prev;
  torchaudio = import ./torchaudio.nix { inherit pkgs lib versions; } final prev;
}
