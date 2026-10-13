#!/usr/bin/env bash
# Pavilion workspace acceptance; requires a display and Weston Terminal.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/pavilion-launcher-check-$$"
LOG="$ROOT/.tools/pavilion-workspace-check.log"
if ! timeout -k 2s 180s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
    --max-fps 60 --script res://tests/pavilion_workspace.gd > "$LOG" 2>&1; then
    cat "$LOG"
    exit 1
fi
cat "$LOG"
if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
    ! rg -q '^PAVILION_WORKSPACE_OK failures=0$' "$LOG"; then
    echo 'Pavilion workspace check failed' >&2
    exit 1
fi
echo "Pavilion workspace checks passed; inspect $ROOT/.tools/pavilion-workspace-test/*.png."
