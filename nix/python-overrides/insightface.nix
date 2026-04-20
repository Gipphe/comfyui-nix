{ lib }:
final: prev:
prev.insightface.overridePythonAttrs (old: {
  # Remove mxnet from dependencies - it's only used for one legacy CLI command
  # and prevents the package from working on macOS (mxnet is Linux-only in nixpkgs)
  dependencies = builtins.filter (dep: dep.pname or "" != "mxnet") (old.dependencies or [ ]);

  # Skip the problematic CLI test that requires mxnet
  disabledTests = (old.disabledTests or [ ]) ++ [
    "test_cli" # Uses rec_add_mask_param which requires mxnet
  ];

  # Verify the package works without mxnet (face analysis uses onnxruntime)
  pythonImportsCheck = [
    "insightface"
    "insightface.app"
    "insightface.model_zoo"
  ];

  meta = (old.meta or { }) // {
    # Now works on all platforms since we removed mxnet dependency
    platforms = lib.platforms.unix;
  };
})
