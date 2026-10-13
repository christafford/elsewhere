# P22-T08 — atmosphere and visual boundaries

2026-10-13, Codex agent, base `e063fba` plus this task's changes. Owner request:
P22-T08 only, under current AGENTS.md and Decision 08. Agent inspection of actual
Godot renders; no owner/human visual approval or P22-T09 acceptance is claimed.

## Changes and actual views

A continuous foothill ring meets the outside of the existing stone bank and
falls beneath the distant mountain mesh. Four low rises, 144 varied firs,
meadow/rock color patches and two narrow track stretches give depth beyond the
square. Mountain-local haze reduces distant contrast. The near broadleaf trees,
architecture, worktables, sky, sunlight, application materials and collision
boundary remain intact. The tracks are decorative glimpses, with no gate,
functional destination or extra traversable area.

Seven final 1280×800 actual GPU captures were inspected individually:

| View | Agent observation |
| --- | --- |
| [Arrival](arrival.png) · [before](baseline/arrival.png) | Buildings and fountain remain dominant; a wooded rise and track fill the gap behind the square. |
| [North outlook](north-outlook.png) · [before](baseline/north-outlook.png) | A narrow earth track climbs out of view between firs; low green terrain layers in front of the distant ridge. |
| [East outlook](east-outlook.png) · [before](baseline/east-outlook.png) | A wooded knoll replaces the bare sky gap immediately beyond the bank. |
| [South outlook](south-outlook.png) | Asymmetric grove and rise; much of the second track is screened from this angle. |
| [West outlook](west-outlook.png) | A higher wooded shoulder closes the west side without overlapping the playable ground. |
| [Return toward square](south-return.png) | Near buildings, middle foothills and distant mountains read as separate layers. Pavilion and approaches stay clear. |
| [Pavilion edge](pavilion-edge.png) · [before](baseline/pavilion-edge.png) | The second track appears briefly along a slope, then disappears behind the grove/bank. |

No exposed outer mesh edge, obvious void or clipping was observed in these
views. The stone retaining boundary remains clearly visible and impassable.
These are staged eye-level views of the actual scene, not proof of free access
to the decorative surroundings. Existing traversal tests supply movement evidence.

The [initial firs](initial-firs.png) had overly angular, continuous branch skirts.
The final original model uses separate boughs and needle sprays; its crown was
also narrowed after inspection. No renderer/input workaround was needed.

## Bounded rendering-cost check

Same seven camera positions/headings, renderer, resolution and output, before
production edits and after the final art. Each sample covers 120 process frames
after capture/settling. Raw [baseline counters](baseline/render-cost.json) and
[final counters](render-cost.json) retain per-view median, p95, draw calls and
Godot's primitive monitor.

| View | Draw calls before → after | Median ms before → after | p95 ms before → after |
| --- | ---: | ---: | ---: |
| Arrival | 422 → 426 | 16.668 → 16.665 | 17.001 → 17.014 |
| North | 57 → 61 | 16.647 → 16.673 | 17.143 → 17.251 |
| East | 49 → 53 | 16.645 → 16.689 | 17.023 → 17.207 |
| South | 34 → 38 | 16.656 → 16.667 | 17.068 → 17.003 |
| West | 37 → 41 | 16.669 → 16.674 | 17.109 → 17.010 |
| Return | 445 → 449 | 16.658 → 16.669 | 17.068 → 17.209 |
| Pavilion edge | 37 → 41 | 16.666 → 16.676 | 16.969 → 17.072 |

Four extra draw calls: three opaque fir material surfaces in one MultiMesh and
one terrain surface. No added shadows, transparent sorting or per-frame scripts.
Foothills have 1,680 triangles; 144 × 3,327 tree triangles gives 480,768 added
placed triangles before LOD. Godot's primitive monitor rises by 5,007, counting
the instanced model once; it is not the complete instanced triangle workload.
Geometry budgets and all 144 rendered instance origins outside the existing
playable polygon are checked. No decorative CollisionObject3D is allowed.

This is a short host comparison on a 60 Hz, vsync-bound output, even with
`--max-fps 0`. It detects no distracting frame-time regression in this sample;
it does not measure uncapped GPU headroom, sustained load, target hardware,
latency or human comfort. P22-T09 and Steam Deck performance remain unperformed.

## Reproduce

```sh
python3 world/tools/build_village_surrounds.py
tools/check-godot-atmosphere.sh
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
tools/check-godot-pavilion.sh
tools/check-godot-village-applications.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
python3 tests/test_village_materials.py
node --test .opencode/tests/auto-continue.test.js
bash -n tools/check-godot-atmosphere.sh
git diff --check
```

All graphical trials in this task use a private Weston 15.0.1 headless GL
output with a fake seat and actual GPU rendering, preserving the host desktop.
Save [the wrapper](godot-check.txt) as `.tools/p22-t08/godot-check.sh`, make it
executable, and export `GODOT_BINARY="$PWD/.tools/p22-t08/godot-check.sh"` before
these checks. Godot's headless runs pass straight through. Graphical output is
1280×800 (1600×1000 for the existing resize trial). Godot 4.7.2 Compatibility,
OpenGL 3.3, NVIDIA RTX 3080 driver 615.78.08, CachyOS Linux. Actual nested clients
use the embedded Elsewhere compositor; Weston Terminal 15.0.1 and Vim 9.2,
patches 1–1178. No packages, host configuration or services changed.

The pre-edit baseline used the same new `village_atmosphere.gd` fixture with
`-- --baseline`, against `e063fba` production code, on that wrapper. This bypasses
only the new surroundings assertions so matched old-world views can be captured.
The normal helper always requires the final surroundings and checks both modes.

Six existing default-world graphical scripts are also run directly with
`--path "$PWD/world" --audio-driver Dummy --max-fps 60 --script res://tests/NAME.gd`:
`screen_color`, `terminal_input`, `terminal_pointer`, `terminal_resize`,
`app_launcher`, `application_transition`. Four existing headless scripts use the
same command plus `--headless`: `screen_transform`, `keyboard_map`, `pointer_map`,
`desktop_runtime`. All runs require their success marker and no Godot error,
crash or leaked-instance report. Full local logs are in `.tools/p22-t08/`.

## Verification result

Task acceptance passes. Import/default startup and native bridge build;
headless/GPU atmosphere, architecture, landscape and outdoor checks; real pavilion
and two-client Terminal/Vim trials; all six default-world graphical regressions;
four headless transform/map/runtime checks; 11 Python tests and 62 Node tests pass.
Both landscape modes sample 24,178 points and walk 337.8m with four successful
route round trips. Model regeneration is byte-identical. Syntax, documentation
links, task parsing and final diffs are validated. Exact success markers, placement
and live-session values are in [verification.txt](verification.txt).

The existing pavilion trial retains shell `77225:at-my-desk` across placement
and walking away/back: [before](pavilion-before.txt), [after](pavilion-after.txt),
[actual reactivated terminal](pavilion-same-shell.png). Fifty background revisions
advance; stool movement/rotation/cancel, close and shutdown pass. The two-client
trial retains shell `78803:still-here`, both entity identities/placements and
[the original Vim buffer](editor.txt), with 22 background revisions during a
12.291m outward walk and return. The [reactivated editor render](editor-revisited.png)
and pavilion terminal render were inspected: text remains legible in application
mode. These are real clients with injected input, separate from human acceptance.

## Test correction and limits

The first new headless transform assertion reported every instance at the origin:
[initial failure](headless-readback-failure.txt). Godot's dummy renderer does not
retain MultiMesh transform readback. Geometry/count/collision checks still run
headless; the transform checks now run against every actual graphical instance,
where they pass. No existing assertion or application test was weakened.

Fresh environment inspection still finds only `.gdignore` in the retained-study
source cache, and no Google Chrome executable/desktop entry. The full retained
study and browser trials were not rerun or claimed as passed; their missing
fixtures and restoration commands are recorded in
[the preceding task's evidence](../p22-t07/README.md#unavailable-regression-fixtures).
The current outdoor/available-client regressions are separate. No C++ source
changed; no fresh full Meson/native suite claim beyond the bridge build.
No restart persistence, general app compatibility, owner approval or human
comfort/latency result is inferred. The owner's untracked art image is untouched.
