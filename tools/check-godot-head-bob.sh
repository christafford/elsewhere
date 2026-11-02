#!/usr/bin/env bash
# Focused gait checks; graphical captures still require inspection.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/godot}"
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/elsewhere-head-bob-check.XXXXXX")
echo "Head bob logs: $LOG_DIR"
for mode in headless disabled graphical; do
    args=()
    user_args=(--no-terminal)
    if [[ "$mode" != graphical ]]; then args+=(--headless); fi
    if [[ "$mode" == disabled ]]; then user_args+=(--no-head-bob); fi
    if ! timeout -k 2s 90s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
        --max-fps 60 "${args[@]}" --script res://tests/head_bob.gd \
        -- "${user_args[@]}" > "$LOG_DIR/$mode.log" 2>&1; then
        cat "$LOG_DIR/$mode.log"
        exit 1
    fi
    cat "$LOG_DIR/$mode.log"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG_DIR/$mode.log" || \
        ! rg -q '^HEAD_BOB_OK .* failures=0$' "$LOG_DIR/$mode.log"; then
        echo "Head bob check failed: $mode" >&2
        exit 1
    fi
done
echo "Head bob checks passed; inspect .tools/head-bob-test/*.png."
