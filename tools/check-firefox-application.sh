#!/usr/bin/env bash
# Requires installed native Firefox and a graphical output.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/firefox-launcher-check"
LOG="$ROOT/.tools/firefox-application-check.log"
if ! timeout -k 2s 120s "$GODOT" --path "$ROOT/world" --audio-driver Dummy --max-fps 60 \
    --script res://tests/firefox_application.gd > "$LOG" 2>&1; then
    cat "$LOG"
    exit 1
fi
cat "$LOG"
if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$LOG" || ! rg -q '^FIREFOX_APPLICATION_OK failures=0$' "$LOG"; then
    echo 'Firefox application checks failed' >&2
    exit 1
fi
echo 'Firefox application checks passed; inspect .tools/firefox-application-test/*.png.'
