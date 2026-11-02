#!/usr/bin/env bash
# Elsewhere — Run the Godot world frontend.
# Launch the outdoor startup. The legacy C++ executable remains separate.
#
# Usage:
#   tools/run-godot.sh                  # open fullscreen (F11 toggles, Alt+F4 quits)
#   tools/run-godot.sh -- --windowed    # open a resizable development window
#   tools/run-godot.sh res://scenes/study.tscn  # retained study (requires assets)
#   tools/run-godot.sh --editor         # open the editor
#   tools/run-godot.sh --headless       # run without GUI (for CI)
#
# Environment:
#   GODOT_BINARY=<path>  override the default binary location
#   SDL_JOYSTICK_LINUX_CLASSIC=0  opt back into SDL's evdev joystick backend

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../world"

# Resolve the shared pin; an explicit override supports comparison runs.
GODOT_BIN="${GODOT_BINARY:-$SCRIPT_DIR/godot}"

if [ ! -x "$GODOT_BIN" ]; then
	echo "ERROR: $GODOT_BIN is not executable."
	exit 1
fi

"$SCRIPT_DIR/build-godot-runtime.sh"
# The pinned engine can crash in SDL's evdev device sort before opening a window
# on Steam Deck. Classic joystick enumeration avoids that sysfs-ordering path;
# keyboard/mouse input still comes from the focused host window. Respect an
# explicit override. See docs/handoffs/27-godot-startup.md for address-level proof.
export SDL_JOYSTICK_LINUX_CLASSIC="${SDL_JOYSTICK_LINUX_CLASSIC:-1}"
exec "$GODOT_BIN" --path "$PROJECT_DIR" "$@"
