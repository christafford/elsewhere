#!/usr/bin/env bash
# Compatibility entry point: the experimental C bridge was retired after review.
# Build and stage the supported ElsewhereCompositorSession binding instead.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if (( $# )); then
    echo "The retired bridge's build_dir argument is no longer supported." >&2
    echo "Run tools/build-godot-runtime.sh (build-godot-probe -> world/addons/elsewhere_runtime)." >&2
    exit 2
fi
exec "$ROOT/tools/build-godot-runtime.sh"
