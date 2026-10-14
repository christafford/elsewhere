#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/interiors-launcher-check-$$"
mkdir -p "$ROOT/.tools/interiors"
for mode in headless graphical; do
    args=()
    if [[ "$mode" == headless ]]; then args+=(--headless); fi
    LOG="$ROOT/.tools/interiors/$mode.log"
    if ! timeout -k 2s 360s "$GODOT" --path "$ROOT/world" --audio-driver Dummy --max-fps 60 \
        "${args[@]}" --script res://tests/village_interiors.gd > "$LOG" 2>&1; then
        cat "$LOG"; exit 1
    fi
    cat "$LOG"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
        ! rg -q '^VILLAGE_INTERIORS_OK .*failures=0$' "$LOG"; then exit 1; fi
done
echo 'Interior checks passed; inspect .tools/village-interiors-test/*.png.'
