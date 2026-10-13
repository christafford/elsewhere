# P22-T07 — pavilion workspace evidence

2026-10-13, Codex agent, base revision `3478f0d` plus this task's changes.
The owner requested P22-T07 only. Decision 08 and current AGENTS.md govern.
Actual Godot renders and real Wayland clients; injected input and agent visual
inspection are not a person's comfort or art approval.

## Workspace and live continuity

Two timber tables face the square beneath the existing pavilion roof. Their
raised teal pads provide physical application supports; local WorkAnchor markers
record the tops without creating a new binding or snapping system. Two round
stools use existing furniture drag, rotate, cancel and push behavior. The north
ramp and central passage remain open. Tables are fixed; seating is decorative.

The trial walks from spawn up the ramp, launches Weston Terminal from the
Applications search, sets a shell variable, and starts changing timestamp output.
It drags/releases the panel onto the west pad through existing pointer/wheel
controls. Physics confirms contact with the table and pad height. It moves and
rotates the east stool, releases it onto the floor, then checks cancellation of
a later grab. The player walks down the ramp into the square and returns without
repositioning either entity. W/Shift drive the ordinary controller; the test
sets headings toward waypoints. It never sets player/panel positions.

Object reference, entity ID, runtime handle and full panel transform remain
unchanged. Client revisions and actual pixels advance while away. Double-click
reactivates the same shell, whose PID and variable match in
[before.txt](before.txt) and [after.txt](after.txt). `exit` removes its panel and
returns to world mode; runtime shutdown reaps launcher-owned children.
The final shell is `43110:at-my-desk`; 50 background frame revisions advance.
Exact transforms and results are in [verification.txt](verification.txt).

| Actual render | Agent observation |
| --- | --- |
| [First layout, superseded](first-layout.png) | Work view faces the outer boundary; raised narrow planks obscure the pad. |
| [Covered work area](pavilion-covered.png) | Table, pad, overhead joinery and open view form a usable covered location. |
| [Pavilion exterior](pavilion.png) | Existing roof/ramp and open circulation remain intact. |
| [Final worktables](worktables.png) | Pad visible on a continuous top; shaded timber and trestle joinery fit the pavilion. Work view overlooks the square. |
| [Terminal on pad](terminal-on-worktable.png) | Live panel rests upright on the west pad, below the roof and outside the central aisle. |
| [Moved stool](stool-moved.png) | Stool rests on the floor after committed movement and rotation; the other table remains usable. |
| [Away in the square](away-in-square.png) | Workspace stays beneath the pavilion, reached by the open ramp. |
| [Returned workspace](workspace-revisited.png) | Same placement; terminal output has advanced. |
| [Same shell reactivated](same-shell.png) | Native-size readable terminal shows timestamps and the original PID/session variable. |

The first model's plank cross-section dimensions were reversed. Correcting them
makes the tabletop match collision and exposes the pad. The desks were moved to
the north side to face the fountain/buildings. Final visuals were inspected after
rerunning the complete trial. The first invocation also caught a new-test
GDScript inference error, fixed with an explicit Vector3 type. The existing
[outdoor startup check](outdoor-first-failure.txt) initially classified any
movable furniture as legacy study geometry. It now requires exactly the two
named pavilion stools and keeps its old-script/door exclusions. This reflects
the intended new furniture, rather than permitting arbitrary legacy content.

The world panel is a distant thumbnail; application mode provides ordinary
readable text. Still images alone do not prove session continuity; live-state
assertions and shell outputs provide that evidence.

## Reproduce

```sh
tools/check-godot-pavilion.sh
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
tools/check-godot-village-applications.sh
tools/check-godot-study.sh
tools/check-chrome-application.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
python3 tests/test_village_materials.py
node --test .opencode/tests/auto-continue.test.js
python3 world/tools/build_pavilion_furniture.py
bash -n tools/check-godot-pavilion.sh
git diff --check
```

Pavilion acceptance requires a graphical display and installed Weston Terminal;
absence fails explicitly. Architecture checks run headless and graphical with
both work-pad contact/clearance/roof queries and ordinary ramp/aisle traversal.
Landscape queries still sample all terrain under intentional structures, now
excluding the added workspace colliders as well as architectural colliders.
Existing route and collision assertions remain intact.

The first two multi-client regressions on the shared X11 host display failed:
[activation failure](log.txt), [earlier typing/search failure](second-log.txt),
and [failed editor activation render](village-host-failure.png). Neither is
counted as a pass. The unchanged test passes on the documented private Weston
headless GL output with a fake seat: the same real Vim buffer is preserved in
[village-editor.txt](village-editor.txt). Temporary diagnostic prints were
removed; no production focus change or relaxed assertion. These results are
consistent with shared-host input/focus interference, but its exact source was
not established. No claim of a general focus defect repair.

To reproduce the isolated display, save [the wrapper](godot-check.txt) as
`.tools/p22-t07/godot-check.sh`, make it executable, and set
`GODOT_BINARY="$PWD/.tools/p22-t07/godot-check.sh"` before the graphical checks.
Headless engine runs pass straight through. Graphical runs use Weston 15.0.1
`--backend=headless --fake-seat --renderer=gl --no-config --idle-time=0` with a
unique socket, then the pinned Godot with `--display-driver wayland`. The normal
output is 1280×800; the terminal resize trial uses 1600×1000. This renders actual
GPU frames without changing the host desktop/services.

Environment: CachyOS Linux; Godot 4.7.2 Compatibility/OpenGL 3.3; NVIDIA GeForce
RTX 3080, driver 615.78.08. Architecture/landscape/outdoor graphical trials
used an X11 host window; isolated multi-client and remaining interaction trials
use the private Weston output above. Both use the embedded Elsewhere Wayland
compositor for application clients. Weston Terminal 15.0.1; Vim 9.2 patches
1–1178 for the existing multi-client trial. No host service changes or system
packages. This differs from prior Steam Deck evidence and is not target-device
performance evidence. Full local logs: `.tools/p22-t07/`.

## Verification result

Task acceptance passes. Import/default startup and bridge build; headless/GPU
architecture, landscape and outdoor checks; the real pavilion trial; the unchanged
isolated Terminal/Vim trial; six default-world graphical regressions (color,
keyboard, pointer, resize, launcher and transitions); four headless
transform/map/runtime checks; 11 Python tests and 62 Node tests pass. Eight final
pavilion renders were inspected, plus the initial layout and the failing/passing
multi-client editor renders. Furniture regeneration is byte-identical, the old
village models remain unchanged, and shell/Python syntax, documentation links,
task parsing and diff validation pass. Broader unavailable checks follow.

## Unavailable regression fixtures

The full retained-study suite stops when the legacy scene cannot load its
untracked models and walnut texture: [error excerpts](study-missing-assets.txt).
The local `world/assets/cache` contains only `.gdignore`; the existing
[staging command fails](study-staging.txt) on the first missing source package.
The four preceding headless transform/map/runtime checks pass. Retained-study
geometry, furniture, live-terminal, gravity and application-object trials are
not claimed as freshly verified. Restore the documented source cache, run
`python3 world/tools/prepare_study_assets.py`, then rerun
`tools/check-godot-study.sh`. No source workaround, substitute fixture or assertion
weakening was added. Native C++ source is unchanged; no fresh full Meson or
binding-suite result is claimed beyond the normal bridge build.

The [Chrome check](chrome-unavailable.txt) fails explicitly because this machine
has no installed `google-chrome.desktop` entry or Google Chrome executable.
No fresh browser compatibility result is claimed. Rerun
`tools/check-chrome-application.sh` on an environment with the documented browser;
no package installation was attempted as part of this pavilion task.

## Limits

No restart persistence, general application compatibility, new native compositor
acceptance, human comfort/latency, owner visual approval or performance benchmark
is claimed. Existing source models, comparison checkpoints, controls, client
shader and native ownership remain unchanged. No new dependency.

See [handoff 50](../../handoffs/50-pavilion-workspace.md) for implementation and
scope. Stop after P22-T07; no P22-T08 or other task work is authorized.
