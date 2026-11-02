#!/usr/bin/env bash
# Open-perimeter containment and rendered landscape seam; inspect captures too.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/boundary-launcher-check-$$"
mkdir -p "$ROOT/.tools/p22-t13"
for mode in headless graphical; do
    args=()
    if [[ "$mode" == headless ]]; then args+=(--headless); fi
    LOG="$ROOT/.tools/p22-t13/$mode.log"
    if ! timeout -k 2s 180s "$GODOT" --path "$ROOT/world" --audio-driver Dummy --max-fps 60 \
        "${args[@]}" --script res://tests/village_boundary.gd > "$LOG" 2>&1; then
        cat "$LOG"; exit 1
    fi
    cat "$LOG"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
        ! rg -q '^VILLAGE_BOUNDARY_OK .* corners=10 stools=10 failures=0$' "$LOG"; then exit 1; fi
done
echo 'Boundary checks passed; inspect .tools/p22-t13/boundary/*.png.'
