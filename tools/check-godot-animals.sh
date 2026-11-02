#!/usr/bin/env bash
# Real outdoor animal behavior, map growth, and actual rendered capture checks.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64}"
"$ROOT/tools/validate-godot-project.sh"
mkdir -p "$ROOT/.tools/p22-t14"
for mode in headless graphical; do
  args=()
  if [[ "$mode" == headless ]]; then args+=(--headless); fi
  for test in animal_navigation village_animals; do
    log="$ROOT/.tools/p22-t14/$mode-$test.log"
    if ! timeout -k 2s 300s "$GODOT" --path "$ROOT/world" --audio-driver Dummy --max-fps 60 \
      "${args[@]}" --script "res://tests/$test.gd" -- --no-terminal --windowed > "$log" 2>&1; then
      cat "$log"; exit 1
    fi
    cat "$log"
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$log" || \
      ! rg -q '^(ANIMAL_NAVIGATION|VILLAGE_ANIMALS)_OK .*failures=0$' "$log"; then exit 1; fi
  done
done
echo 'Animal checks passed; inspect .tools/p22-t14/*village.png and *motion*.png.'
