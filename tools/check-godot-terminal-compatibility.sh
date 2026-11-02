#!/usr/bin/env bash
# Real installed Alacritty/Ghostty: fullscreen launch, resize, revisit and close.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/terminal-compatibility-launcher-$$"
LOG=$(mktemp "${TMPDIR:-/tmp}/elsewhere-terminal-compatibility.XXXXXX")
echo "Terminal compatibility log: $LOG"
if ! timeout -k 2s 180s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
    --max-fps 60 --script res://tests/terminal_compatibility.gd > "$LOG" 2>&1; then
    cat "$LOG"
    exit 1
fi
cat "$LOG"
if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
    ! rg -q '^TERMINAL_COMPATIBILITY_OK failures=0$' "$LOG"; then
    echo 'Terminal compatibility failed' >&2
    exit 1
fi
echo 'Terminal compatibility passed; inspect .tools/terminal-compatibility-test/*.png.'
