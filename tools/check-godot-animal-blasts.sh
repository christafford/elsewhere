#!/usr/bin/env bash
# Every effect/species, cleanup and input isolation; inspect actual GPU captures.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/godot}"
"$ROOT/tools/validate-godot-project.sh"
mkdir -p "$ROOT/.tools/animal-blasts"
for mode in headless graphical; do
  args=()
  if [[ "$mode" == headless ]]; then args+=(--headless); fi
  log="$ROOT/.tools/animal-blasts/$mode-final.log"
  if ! timeout -k 2s 240s "$GODOT" --path "$ROOT/world" --audio-driver Dummy --max-fps 60 \
      "${args[@]}" --script res://tests/animal_blasts.gd -- --no-terminal --windowed > "$log" 2>&1; then
    cat "$log"; exit 1
  fi
  cat "$log"
  if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$log" || \
      ! rg -q '^ANIMAL_BLASTS_OK .*failures=0$' "$log"; then exit 1; fi
done
echo 'Blast checks passed; inspect .tools/animal-blasts/*.png. No human acceptance implied.'
