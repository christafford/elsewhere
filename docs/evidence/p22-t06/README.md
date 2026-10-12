# P22-T06 — real outdoor application evidence

2026-10-12; Codex agent, based on `a13b671`. Owner explicitly requested this
single task after selecting version 2. All images here are actual Godot viewport
captures of the unchanged village and live Wayland clients. Input is injected
by the test agent; these are not personal usability/comfort observations.

## Continuous Terminal + Vim session

The default scene starts empty. Tab opens Applications; typed search and Enter
launch the installed application (the test selects the matching catalog row).
Terminal and Vim are separate live panels. The terminal prints timestamps while
Vim holds unsaved text. Pointer drag, wheel distance and both-buttons/wheel
rotation place the terminal on the square without moving Vim. Normal S/W
walking travels **12.291m away** down the south approach and back, without
teleporting or directly assigning player/panel transforms. The terminal advances
**24 frame revisions** while away and its actual pixels change. Both entity
objects/IDs, window bindings and placements survive the walk.

After double-click reactivation, the shell writes the same PID and session
variable: [before](before.txt) and [after](after.txt) both contain
`689740:still-here`. This PID is evidence of the same live shell, not its world
identity. Vim appends text to its unsaved buffer, then writes the exact
[two-line file](editor.txt). Vim closes itself, leaving Terminal intact; Terminal
then exits and its panel/focus disappear. Shutdown reaps owned launch children.

| Actual capture | Agent inspection |
| --- | --- |
| [Installed Vim search](search-vim.png) | Existing search overlay and catalog result appear over the village. |
| [Two live applications](two-live-applications.png) | Independent labeled Vim/Terminal panels show their own client frames. |
| [Placed applications](placed-applications.png) | Terminal moved right, turned and settled on the paving; Vim remains at its launch placement. |
| [Away on the south approach](away-south-approach.png) | Panels remain at the square, visibly distant from the player. |
| [Revisited applications](revisited-applications.png) | Both panels retain their placements; terminal output has continued. |
| [Returned terminal](terminal-revisited.png) | Readable native application view shows continued timestamps, Ctrl+C and the same shell state. |
| [Returned editor](editor-revisited.png) | Native application view shows the original unsaved line plus the new line, saved as two lines. |
| [After both clients close](world-after-close.png) | Panels are removed and world mode is restored. |

World thumbnails lose small text detail with distance; application mode remains
the text-working endpoint. The still image alone does not establish persistence:
identity, transform, process-state and buffer assertions supply that evidence.
The selected version 2 art, exposure and client shading are unchanged.

## Browser readiness correction

Two sequential Chrome trials lost the first `E` of the required string:
[first log](chrome-first-failure.txt), [unchanged rerun](chrome-rerun-failure.txt),
and [failed render](chrome-first-failure.png). These are failures, not passed
checks. Temporary tracing then showed `ready=true` with `document.hasFocus()`
false while Godot application mode, host focus and compositor focus were active;
see [the diagnostic excerpt](focus-diagnosis.txt). Element autofocus was an
insufficient readiness signal. This also shows concurrent trials are not
necessary for the historical failure to occur.

The local HTML fixture now requires document focus as well as document-complete
and focused-input state, reporting readiness on an animation frame once focused.
The existing exact first-try text assertion and all interaction assertions remain
unchanged. No input retry, extra key, fixed delay or production runtime change.
Temporary diagnostic tracing was removed. This addresses an observed readiness
gap; it is not a claim that every historical browser issue is resolved.

Two subsequent complete Chrome trials pass. Final agent-inspected renders:
[exact typing and Save click](browser-input.png),
[1000×700 host resize/reflow](browser-resized.png), and
[return to the village](browser-in-room.png). The page reports trusted events,
the exact text, one click, changed viewport dimensions and restored scroll;
see [final page output](browser-page.json). Its local HTML is test content in
the installed real browser, not a mock browser or screenshot replay.

## Verification results

[Durable result excerpts](verification.txt) record the new two-client trial,
headless/GPU outdoor checks, seven existing graphical interaction regressions,
both corrected Chrome trials, eight Python tests and 62 Node tests. All these
final checks pass. The sequential regression batch initially stopped at Chrome;
its two failing attempts and the later fixture correction are disclosed above.
The seven other interaction tests were unchanged and already passing.
Import/default startup, the existing bridge build and nine asset integrity
checks pass through the integration helpers. Shell/Python syntax, documentation
links, Project 22 task parsing and final diff validation also pass.

## Commands and environment

```sh
export GODOT_BINARY="$PWD/.tools/rename/godot-check.sh"
tools/check-godot-village-applications.sh
tools/check-godot-outdoor.sh
export ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/p22-t06/desktop-state"
for trial in screen_color terminal_input terminal_pointer terminal_resize \
             app_launcher application_objects application_transition; do
  timeout -k 2s 90s "$GODOT_BINARY" --path "$PWD/world" --audio-driver Dummy \
    --max-fps 60 --script "res://tests/$trial.gd"
done
tools/check-chrome-application.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
node --test .opencode/tests/auto-continue.test.js
bash -n tools/check-godot-village-applications.sh
git diff --check
```

Godot 4.7.2 Compatibility/OpenGL; AMD Custom GPU 0405 (Steam Deck/Vangogh),
Mesa 26.2.4; private Weston 15.0.1 with its headless GL backend and fake seat.
The wrapper passes `--headless` directly to Godot; graphical captures use an
actual GPU renderer and private Wayland display, with no host desktop changes.
World/terminal images are 1280×800; resize regression uses 1600×1000; Chrome
resizes to 1000×700. Clients: Weston Terminal 15.0.1, Vim 9.2 patches 1–1046
(inside a separate real Weston terminal), Google Chrome 154.0.8037.57.

Detailed local logs are `.tools/p22-t06/`. Integration helpers build/stage the
existing GDExtension and validate assets/imports/default startup. Native source
is unchanged; no fresh full Meson-suite pass is claimed. Optional libdecor,
xdg-decoration/activation/icon protocol, cursor and icon-theme warnings are
recorded environment limits. They do not stand in for successful assertions.

The first new trial detected an extra injected Enter in the test's Vim input;
that produced a third blank line. Removing that input preserved the exact
expected two-line assertion. See [handoff 46](../../handoffs/46-village-applications.md)
for scope and limitations. No new application architecture, furniture/anchors,
restart restoration, performance benchmark or P22-T07 work is included.
