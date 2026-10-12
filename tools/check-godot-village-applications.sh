#!/usr/bin/env bash
# Real outdoor multi-application acceptance; requires a display, Weston and Vim.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/village-launcher-check-$$"
LOG="$ROOT/.tools/village-applications-check.log"
if ! timeout -k 2s 150s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
    --max-fps 60 --script res://tests/village_applications.gd > "$LOG" 2>&1; then
    cat "$LOG"
    exit 1
fi
cat "$LOG"
if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
    ! rg -q '^VILLAGE_APPLICATIONS_OK clients=2 failures=0$' "$LOG"; then
    echo 'Village application check failed' >&2
    exit 1
fi
echo "Village application checks passed; inspect $ROOT/.tools/village-applications-test/*.png."
