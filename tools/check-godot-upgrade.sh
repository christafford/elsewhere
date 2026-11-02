#!/usr/bin/env bash
# Engine migration gate: current desktop, reusable queries and world behavior.
# Use GODOT_BINARY for an alternate engine or a private-display wrapper.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BINARY:-$ROOT/tools/godot}"
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
export ELSEWHERE_LAUNCHER_STATE_DIR="$ROOT/.tools/upgrade-launcher-check-$$"
LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/elsewhere-upgrade-check.XXXXXX")
echo "Upgrade check logs: $LOG_DIR"
INCLUDE_STUDY=false
if [[ "${1:-}" == --include-study ]]; then
    INCLUDE_STUDY=true
    python3 "$ROOT/world/tools/prepare_study_assets.py"
elif (( $# )); then
    echo 'Usage: tools/check-godot-upgrade.sh [--include-study]' >&2
    exit 2
fi
"$ROOT/tools/validate-godot-project.sh"
"$ROOT/tools/check-godot-binding.sh"
python3 "$ROOT/tests/test_godot_toolchain.py"
python3 "$ROOT/tests/test_godot_launcher.py"
python3 "$ROOT/tests/test_desktop_apps.py"
run() {
    local mode=$1 test=$2
    local args=()
    if [[ "$mode" == headless ]]; then args+=(--headless); fi
    local log="$LOG_DIR/$mode-$test.log"
    if ! timeout -k 2s 240s "$GODOT" --path "$ROOT/world" --audio-driver Dummy \
        --max-fps 60 "${args[@]}" --script "res://tests/$test.gd" -- --windowed > "$log" 2>&1; then
        cat "$log"; exit 1
    fi
    if rg -n 'ERROR:|crashed with signal|Leaked instance|ObjectDB instances leaked' "$log" || \
        ! rg -q '(_OK|STUDY_SMOKE).*failures=0$' "$log"; then
        cat "$log"; exit 1
    fi
    rg '(_OK|STUDY_SMOKE).*failures=0$' "$log"
}
for test in godot48_queries screen_transform keyboard_map pointer_map desktop_runtime outdoor_startup; do
    run headless "$test"
done
if [[ "$INCLUDE_STUDY" == true ]]; then
    for test in study_smoke application_objects application_gravity; do
        run graphical "$test"
    done
else
    echo 'Retired study art is not exercised; use --include-study with its verified source cache.'
fi
for test in outdoor_startup screen_color app_launcher application_transition \
    terminal_input terminal_pointer terminal_resize terminal_compatibility \
    help_overlay village_applications pavilion_workspace; do
    run graphical "$test"
done
run graphical rendering_upgrade
bash "$ROOT/tools/check-godot-head-bob.sh"
"$ROOT/tools/check-godot-animals.sh"
"$ROOT/tools/check-godot-upstairs.sh"
echo 'Upgrade runtime checks passed; inspect the generated renders before acceptance.'
