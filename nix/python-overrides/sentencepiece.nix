{ pkgs }:
let
  sentencepieceNoGperf = pkgs.sentencepiece.override { withGPerfTools = false; };
in
final: prev:
prev.sentencepiece.overridePythonAttrs (old: {
  buildInputs = [ sentencepieceNoGperf.dev ];
  nativeBuildInputs = old.nativeBuildInputs or [ ];
})
