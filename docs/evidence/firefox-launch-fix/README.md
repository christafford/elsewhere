# Firefox repair evidence — 2026-10-13

Codex agent-run and agent-observed, based on `4235435` plus this repair.
[Handoff 52](../../handoffs/52-firefox-launch.md) records scope and limitations.
Logs retain their results with trailing whitespace trimmed.
PNG files are actual Godot captures, not mockups. Local HTML is test content in
real Firefox 157.0.1. No host browser profile content is captured.

- [Input and copy/paste](firefox-input.png), [repeat launch](firefox-reused.png),
  [trusted click/save](firefox-pointer.png), [world return](firefox-in-world.png),
  [quit confirmation](firefox-quit-confirmation.png), [fresh relaunch](firefox-relaunched.png).
  Text remains readable in application mode; the narrow text input scrolls its
  long value normally. [Final page report](page.json) records trusted new typing.
- [Terminal](terminal-revisited.png), [editor](editor-revisited.png) and
  [pavilion](pavilion-revisited.png) are final retained-interaction renders.
- [Final browser run](final-check.txt): zero failures, zero windows and owned
  children after confirmed quit; subsequent relaunch succeeds. The Gecko
  compositor-unavailable message occurs during test-owned runtime shutdown.
- [Native build](build.txt), [36-test suite](meson.txt), [binding](binding.txt),
  [sanitizer build](asan-build.txt), [ASan/UBSan test](asan-test.txt),
  [Python helper](desktop-apps.txt), [Python launcher](godot-launcher.txt),
  [Node/parser](node.txt), [default graphical checks](default-checks.txt),
  [village continuity](village-applications.txt), [pavilion](pavilion.txt).
  Individual default-check logs sit beside this index. Missing icon themes and
  private-Weston optional-global warnings did not fail input/render assertions.
- **Superseded failures:** [second profile contender](failed-profile-contender.png)
  and [initial trial log](failed-first-trial.txt); [GTK without a seat](failed-gtk-input.png)
  and [log](failed-input-trial.txt); [unconfirmed quit trial](failed-quit-trial.txt).
  These are failures, not acceptance. The final fixture consents to Firefox's
  real quit dialog without changing its safety preference.

Graphical runs used this repository-local wrapper via `GODOT_BINARY` (normal
interactive output works too):

```sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(pwd)"
for arg in "$@"; do
  if [[ "$arg" == --headless ]]; then
    exec "$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64" "$@"
  fi
done
width=1280
height=800
if [[ "$*" == *terminal_resize.gd* ]]; then width=1600; height=1000; fi
exec weston --backend=headless --fake-seat --renderer=gl \
  --width="$width" --height="$height" --socket="elsewhere-firefox-check-$$" \
  --idle-time=0 --no-config --log="$ROOT/.tools/firefox-weston-$$.log" -- \
  "$ROOT/tools/Godot_v4.7.2-stable_linux.x86_64" --display-driver wayland "$@"
```

Run `tools/check-firefox-application.sh`, `tools/check-godot-village-applications.sh`
and `tools/check-godot-pavilion.sh` with that wrapper. The six default trials
invoke Godot with `--path world --audio-driver Dummy --max-fps 60 --script`
`res://tests/<name>.gd`, for `screen_color`, `terminal_input`, `terminal_pointer`,
`terminal_resize`, `app_launcher`, `application_transition`. Test state uses an
isolated `ELSEWHERE_LAUNCHER_STATE_DIR`; no test overwrites normal launcher recents.

Native sanitizer reproduction:

```sh
meson setup .tools/firefox-launch-fix/asan-build -Db_sanitize=address,undefined -Db_lundef=false
meson compile -C .tools/firefox-launch-fix/asan-build test_data_device
ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 UBSAN_OPTIONS=halt_on_error=1 \
  meson test -C .tools/firefox-launch-fix/asan-build data-device --print-errorlogs
```

This is not human acceptance, target-hardware performance, general browser
compatibility, host clipboard or drag/drop evidence. No P22 roadmap task changed.
