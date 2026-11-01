#!/usr/bin/env bash
# Fullscreen startup, window restoration, reserved input and owned-client quit.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/window-launcher-check-$$"
LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/elsewhere-window-check.XXXXXX")
echo "Window check logs: $LOG_DIR"
for mode in fullscreen windowed; do
    user_args=()
    if [[ "$mode" == windowed ]]; then user_args+=(--windowed); fi
    if ! timeout -k 2s 120s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
        --max-fps 60 --script res://tests/desktop_window.gd -- "${user_args[@]}" > "$LOG_DIR/$mode.log" 2>&1; then
        cat "$LOG_DIR/$mode.log"
        exit 1
    fi
    cat "$LOG_DIR/$mode.log"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG_DIR/$mode.log" || \
        ! rg -q '^DESKTOP_WINDOW_OK failures=0$' "$LOG_DIR/$mode.log"; then
        echo "Window check failed: $mode" >&2
        exit 1
    fi
done
echo "Window checks passed; inspect .tools/desktop-window-test/*.png."
