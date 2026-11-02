#!/usr/bin/env bash
# Real-client modal help and small-window rendered layout.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/godot}"
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/help-launcher-check-$$"
LOG=$(mktemp "${TMPDIR:-/tmp}/elsewhere-help-check.XXXXXX")
echo "Help check log: $LOG"
if ! timeout -k 2s 150s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
    --max-fps 60 --script res://tests/help_overlay.gd -- --windowed > "$LOG" 2>&1; then
    cat "$LOG"
    exit 1
fi
cat "$LOG"
if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
    ! rg -q '^HELP_OVERLAY_OK failures=0$' "$LOG"; then
    echo 'Help check failed' >&2
    exit 1
fi
echo 'Help checks passed; inspect .tools/help-overlay-test/*.png.'
