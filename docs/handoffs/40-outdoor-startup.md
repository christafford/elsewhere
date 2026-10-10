# P22-T02 — Minimal outdoor startup

## Revalidation after the owner's empty-startup change (2026-10-10)

Base `86db629` already contains P22-T02 (`95363f5`), followed by the owner's
"no starting terminal" change. That change commented out DesktopRuntime
initialization entirely. A fresh headless outdoor check reproduced
`Invalid access to property or key 'bindings' on a base object of type 'Nil'`
at `outdoor_startup.gd:28`; the process required its 20-second timeout.
See `.tools/p22-t02-recheck/before.log`. Geometry remained intact, but application
services were unavailable, so historical completion did not establish the
current acceptance.

The repair preserves empty startup and initializes the existing services.
DesktopRuntime exports `auto_start_terminal` (true for existing callers), which
is false on the outdoor scene and passed to the terminal/session owner before
its ready callback. The compositor starts and pumps even without an initial
client; the initial-terminal watchdog runs only after a requested autostart.
`--terminal` and `--terminal-demo` request that client explicitly.
`--no-terminal` retains its existing geometry-test meaning: no compositor.
The launcher records an automatic terminal only when its owned startup process
exists, preventing the first manually launched browser from being mislabeled.
Native code, movement, scene geometry, identity and application input policy
are unchanged. The retained study still starts its original terminal.

The default outdoor regression now waits 10.5 seconds with zero windows,
checks live/processing services and an empty status label, opens the launcher
with Tab in graphical mode, and launches a real Weston terminal before running
all prior navigation/panel/input assertions. Cleanup also checks launched
children. Five existing terminal-based interaction fixtures explicitly request
a startup terminal; their interaction assertions remain intact. Chrome starts
from the unmodified empty default and checks its first-window label/history.

Fresh evidence for this revalidation is kept in `.tools/p22-t02-recheck/`.
Commands use the same private GPU Weston wrapper documented below:

```sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-study.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh
node --test .opencode/tests/auto-continue.test.js
```

Import/default startup and headless/graphical outdoor checks pass, including the
empty wait, manual terminal launch and all four boundaries. Headless launcher
runs with `--terminal`, `--terminal-demo` and `--no-terminal` each exit zero
without Godot errors (`--max-fps 60 --quit-after 90`, isolated launcher state).
All 21 existing Godot regressions pass in this session, including terminal
input/pointer/resize, launcher/Vim/independent instances/close/relaunch, panel
manipulation, transitions, gravity and retained study/room checks. Detailed
logs from `/tmp/elsewhere-study-check.Zlg5Fw` are copied into
`.tools/p22-t02-recheck/regression-details/`. The fresh pointer selection image
was also inspected: upright text and a clearly visible selected range.
All eight Python catalog/launcher tests and 62 parser/plugin tests pass.
The retained study still matches `7d74847:world/scenes/main.tscn` byte-for-byte.
No native source changed and no fresh native Meson/binding suite result is
claimed.

The isolated Chrome trial passes (`CHROME_APPLICATION_OK failures=0`), covering
first-app launch/labeling from empty startup, trusted typing/click, scrolling,
resize, return, independent second window and client close. See
`.tools/p22-t02-recheck/chrome-isolated.log`.
An earlier direct invocation of `res://tests/chrome_application.gd` through the
same wrapper, while the study suite was running in a separate private Weston,
lost the first `E` in `Elsewhere browser 42!` (the same symptom recorded during
the original implementation). The DOM reported ready/focused, so the earlier
load/focus check does not eliminate this intermittent failure. The unchanged
isolated rerun passed; concurrency is a possible factor, not an established
cause or a fix. No input assertions were weakened, no text was retried, and no
new readiness workaround was added. The failing log and captures are preserved
as `chrome-concurrent.log` / `chrome-concurrent-captures/` under the recheck
log directory. This remains a limitation of the observed browser verification.

Agent-inspected fresh 1280×800 GPU renders:

- [Empty arrival](../evidence/p22-t02/recheck/empty-arrival.png): plain outdoor
  ground/sky/boundaries, working Applications button, no unsolicited panel or
  terminal status message.
- [Requested terminal](../evidence/p22-t02/recheck/application.png): upright,
  readable shell input and `OUTDOOR_OK` output from the real client.
- [Ground and boundary](../evidence/p22-t02/recheck/ground-and-boundary.png):
  live panel remains in the outdoor world after application return.
- [Chrome input](../evidence/p22-t02/recheck/browser-input.png): complete note
  and Save result in the successful isolated trial.
- [Chrome world return](../evidence/p22-t02/recheck/browser-in-room.png): the
  same browser returns to its outdoor panel (1000×700).

Local links, ten unique numeric P22 IDs, actual plugin parsing of the task list
and `git diff --check` pass. P22-T02 remains checked; all subsequent P22 tasks
remain unchecked. Historical suffixed P1 task IDs are left intact.

Observer: Codex agent, same Godot/Mesa/AMD/private-Weston platform recorded
below. Expected private-Weston cursor/decoration/icon/activation warnings are
present; no Godot errors or leaked-instance warnings in passing checks.
No human comfort, village-art or comprehensive P22-T06 integration claim is
made. P22-T03 remains unstarted. The original implementation evidence follows
as history; its automatically opened terminal is superseded by empty startup.

## Original implementation evidence

Owner-requested single task, 2026-10-10, base `7d74847` (P22-T01 plus the
owner's jump commit). Authority: Decision 08. P22-T03 is not started.

## Change and preserved boundaries

`world/scenes/main.tscn` now contains a plain outdoor startup area: 24m ground,
four visible 1.4m collision boundaries, procedural sky, ambient light and a
shadowed sun. The ground extends under the boundaries so there are no edge
gaps. Spawn is `(0, 0.05, 5)`, facing along -Z; the capsule settles onto y=0.
The boundary height contains the owner's existing jump from the ground.
This is deliberately a small primitive startup fixture, not the 70–100m village
landscape, circulation, architecture or art acceptance of later P22 tasks.

`outdoor.gd` makes the existing DesktopRuntime initialization call with its
player, presentation nodes and inset placement bounds. It loads no study or
hallway code/assets. The selected-preview mesh has a hidden parent, preserving
the existing selected texture/local visibility interface without adding a
physical monitor. Its shader uses the existing material factory. Independent
live application panels remain visible; a separate world status label still
reports startup/disabled/error states. The environment retains the exact Filmic
exposure/white contract used by the client screen shader.

The only controller change is exported spawn position/yaw/pitch used by startup
and Home. Its defaults retain the historical study pose. The owner's Space jump,
gravity, speeds, input, collision and focus logic are untouched. Desktop runtime,
terminal/session owner, launcher, application modes/objects/transitions, native
bridge, client launch recipes and stable-identity behavior are unchanged.

The original `main.tscn` is preserved byte-for-byte as `scenes/study.tscn`
(checked against `git show 7d74847:world/scenes/main.tscn`). No legacy geometry,
scripts, source assets, caches or tests were deleted. `project.godot` retains
its main-scene path and all `elsewhere` names/entry points remain intact.

## Deliberate test migration

Eleven tests containing study-specific geometry, camera views or placement
coordinates now load `res://scenes/study.tscn`; only that path changes:
`study_smoke`, `furniture_drag`, `hallway`, `elsewhere_rooms`, `merged_rooms`,
`room_furniture`, `grand_foyer`, `study_details`, `live_terminal`,
`application_objects`, `application_gravity`. Their existing assertions remain.

The existing general `terminal_input`, `terminal_pointer`, `terminal_resize`,
`app_launcher`, `application_transition` and separate `chrome_application`
trials still load `main.tscn`, so they now exercise the actual outdoor default.
The Chrome fixture/check now additionally waits for document load and input
focus before typing; its original interaction assertions remain unchanged.
`check-godot-study.sh` retains its entry point and all 21 trials; it is explicitly
a mixture of retained geometry regressions and current-default desktop checks.
Its name is not a claim that all trials now run in the old world.

The new `outdoor_startup.gd` resolves `application/run/main_scene`, checks that
no study/hallway/rooms/foyer scripts were loaded, and verifies sky/light, real
terminal mapping, floor support, walking/release, the owner's jump/landing,
walking/jumping against all four boundaries, diagonal corner containment,
configured Home and clean shutdown. In graphical mode it also exercises one
live panel's drag/rotation/cancellation, activation, shell-written marker and
return to the same instance, and records actual GPU renders. This bounded
startup regression does not replace P22-T06 or approve future village geometry.

## Commands and evidence

Run from the repository root with the existing pinned tools and installed
Weston terminal. The private GPU Weston wrapper from P22-T01 remains available
at `.tools/rename/godot-check.sh`; its command/settings are documented in
[handoff 39](39-desktop-runtime-extraction.md). It passes headless Godot calls
straight through and uses a separate GPU-rendered Weston virtual output for
graphical tests. It changes no host desktop or services.

```sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-study.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/run-godot.sh \
  --headless --audio-driver Dummy --max-fps 60 --quit-after 30 -- --no-terminal
node --test .opencode/tests/auto-continue.test.js
```

Logs are retained in ignored `.tools/p22-t02/`. Godot import/default headless
startup and explicit `--no-terminal` startup pass. The extension build/stage
runs through the normal launcher/validation helper; no native source changed.
The two outdoor modes pass (`OUTDOOR_STARTUP_OK`, four boundaries, zero failures),
with detailed logs in `/tmp/elsewhere-outdoor-check.9y9QdV`. The existing Node
plugin/parser suite passes all 62 tests. Shell syntax and retained-scene byte
identity checks pass.

All 21 existing Godot regression trials pass, including real terminal typing,
selection/scroll, resizing, relaunch, multiple live panels, transitions, placement
and gravity. All eight Python desktop-catalog/launcher tests pass. Detailed
trial logs are copied from `/tmp/elsewhere-study-check.JdLkBU` into
`.tools/p22-t02/regression-details/`; the two outdoor logs are also copied into
`.tools/p22-t02/outdoor-details/`. The existing selection capture was inspected:
selected text is upright and readable. No old assertion was weakened or removed.
Native Meson/binding test results remain historical P22-T01 evidence; they are
not represented as fresh runs for this scene-only task.

The final real Chrome 154.0.8037.57 trial passes (`CHROME_APPLICATION_OK
failures=0`): address entry, trusted typing/click, scroll, resize/reflow, world
return, second-window identity and client-initiated close. See
`.tools/p22-t02/chrome.log` and the initial-attempt explanation below.
Documentation links, unique numeric task IDs, actual P22 parser output and
`git diff --check` also pass.

The first outdoor-test attempt compared the exact 5cm spawn clearance after
awaiting frames; physics had already settled it onto the floor. The new test
now checks the reset immediately (as the existing controller trial does) and
separately exercises grounded movement. No controller behavior was changed to
accommodate that test-timing error. Both final outdoor modes pass.

The first Chrome trial lost the initial `E` in its note. Inspection found its
empty-value readiness check could accept a resize report before the fixture's
`onload` handler focuses the input. The missing first character is consistent
with that readiness race.
The fixture now reports document-complete plus focused-input readiness, and the
trial requires that before typing. This adds synchronization without changing
runtime input or any expected interaction result. The original failure log and
captures are retained under `.tools/p22-t02/chrome-initial*`.

Agent-inspected Godot Compatibility/OpenGL captures (1280×800 unless noted):

- [Arrival](../evidence/p22-t02/arrival.png): sky, flat ground, solid visible
  boundary, sunlight/shadows and one real terminal panel; no active study.
- [Ground and boundary](../evidence/p22-t02/ground-and-boundary.png): the plain
  walkable area from a second eye-level position, with the same live panel.
- [Application](../evidence/p22-t02/application.png): readable native-size
  shell command/output (`OUTDOOR_OK`) delivered through the retained compositor.
- [Chrome input](../evidence/p22-t02/browser-input.png): complete typed note
  and clicked Save result remain upright and readable.
- [Chrome in the world](../evidence/p22-t02/browser-in-room.png) (1000×700):
  the same running browser returns to its live panel in the outdoor scene.

Observer: Codex agent. Platform: Godot 4.7.2, Mesa 26.2.4, AMD Custom GPU 0405
(Steam Deck/Vangogh), private Weston 15.0.1. These renders demonstrate only the
minimal startup and live content. Flat materials, box boundaries and an empty
sky horizon are intentional scope limits; there is no village-art approval.

## Run and stop

Default: `tools/run-godot.sh --audio-driver Dummy`. No study assets are needed by
this scene. Existing nested/headless paths and `--terminal-demo` / `--no-terminal`
remain available. To revisit the preserved environment explicitly:

```sh
python3 world/tools/prepare_study_assets.py
tools/run-godot.sh --audio-driver Dummy res://scenes/study.tscn
```

The normal default uses the same real-client launcher and desktop services,
but comprehensive outdoor application integration belongs to P22-T06 after
the authored village and owner art checkpoint. Restart persistence, scene
streaming, popup/clipboard/GPU-buffer compatibility and human comfort remain
outside this task. No human task is ticked. Stop after P22-T02; P22-T03 and any
other work require a separate explicit owner request.
