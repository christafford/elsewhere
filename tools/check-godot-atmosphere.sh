#!/usr/bin/env bash
# P22-T08: exterior-only geometry budgets and matched actual landscape captures.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/atmosphere-launcher-check-$$"
mkdir -p "$ROOT/.tools/p22-t08"
for mode in headless graphical; do
    args=()
    if [[ "$mode" == headless ]]; then args+=(--headless); fi
    LOG="$ROOT/.tools/p22-t08/atmosphere-$mode.log"
    if ! timeout -k 2s 120s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
        --max-fps 0 "${args[@]}" --script res://tests/village_atmosphere.gd > "$LOG" 2>&1; then
        cat "$LOG"
        exit 1
    fi
    cat "$LOG"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || \
        ! rg -q '^VILLAGE_ATMOSPHERE_OK .* baseline=false failures=0$' "$LOG"; then
        echo "Atmosphere check failed: $mode" >&2
        exit 1
    fi
done
echo "Atmosphere checks passed; inspect .tools/p22-t08/final/*.png and render-cost.json."
