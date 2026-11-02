# P22-T14 evidence — 2026-11-01

Agent-run/agent-observed against `3b14342` plus P22-T14 and the pre-existing
uncommitted P22-T13 perimeter edits. Godot 4.7.2 Compatibility/OpenGL on an
NVIDIA GeForce RTX 3080 (driver 615.78.08), private Weston headless GL/Wayland,
1280×800 window unless resizing is the subject. These are actual rendered
frames and live clients, not scene serialization or replay. Human acceptance
and target-device/sustained performance remain unobserved.

## Animal checks

`headless-animal_navigation.txt` and `graphical-animal_navigation.txt`: four
actual-physics navigation rebuilds pass connected-land expansion, routing
around a new building, roof/interior rejection, a chicken-only narrow gate,
outward escape from dynamic clearance overlap, inward-overlap rejection and
a fully occupied map returning no path safely. No live village land is added.

`headless-village_animals.txt` and `graphical-village_animals.txt`: all twelve
animals spawn clear outdoors, travel, finish routes and change activity during
90 simulated seconds at fixed 1/60s physics steps (6× test acceleration).
Containment, outdoor support, foot placement, speed/teleport bounds and pair
separation pass. Player approach causes bounded yielding; four dogs/goats
traverse a crowded crossing over another 30 simulated seconds. Seed 2215 also
passes in `headless-seed-2215-final.txt` after the final source cleanup.

Seed 2214 builds 2957/2653/2380 clearance nodes. Headless/GPU trials report
maximum height-field support error below 0.000001 m, solver foot-to-target error
0.001003 m, and one-step displacement 0.01590 m. Minimum center separation is
0.959 of summed padded radii (physical radii are 0.72 of padded radii); the
crowded trial reaches 0.908. Animals travel 17.2–59.6 m and all species naturally
select foraging. Seed 2215 passes with 0.001007 m solver foot error, 0.01747 m
maximum step, 0.861 normal separation and 0.860 crowded separation. These are
bounded trials, not guarantees for arbitrarily dense future populations.

Navigation construction takes 12.723 s headless / 11.694 s graphical for seed
2214, and 15.523 s in the second headless run. Work is spread across frames with
a 1.5 ms slice budget. The desktop starts while navigation builds; animals appear
once it finishes. Larger maps need fresh startup and steady-state measurements.

`*-village.png` shows all five species at their natural spawn locations.
`*-motion-sheet.png` combines twelve normal-speed captures per species, ten physics
frames apart (no animation-time acceleration), ordered left to right then down.
The agent inspected the original frames/close views and contact sheets: animals
remain grounded, swing/plant their legs, turn and pause, with distinct silhouettes
and warm coats fitting the stylized village. The capture camera reframes the
subject; animal movement still uses its live controller. Head/feeding and tail
motions come from the procedural joint animator; the GLBs contain no embedded
animation clips.

`*-forage-pose.png` is a separately labeled art fixture: animals are staged on
clear grass and their real controller settles into its feeding pose. These
frames verify head/neck placement, including chickens lowering their neck to
reach the ground. They are not evidence of natural destination selection; the
behavior trial separately asserts all five species select foraging themselves.

## Desktop and retained world checks

`animals-live-applications.txt`: real Terminal and Vim launch, typing, panel
placement, world walking, revisit, unsaved buffer/shell continuity and normal
close pass. Animals travel an aggregate 60.84 m while typing; their IDs remain
stable. `terminal-revisited.png` and `editor-revisited.png` show the returned
live shell and unsaved editor, inspected by the agent.

`retained-headless.txt` records outdoor startup, 338.2 m landscape walking,
architecture, original interiors, ten added buildings and all six upstairs
routes passing with animals active.

Individual `graphical-*.txt` logs record passing pavilion placement and pushing,
outdoor startup, 338.3 m landscape walking, architecture, original interiors,
ten added buildings and all six upstairs routes. Real upstairs shells survive
placement, descent, exterior travel and return. Four-size terminal resize and
selection, F1 help/input isolation and native client color checks pass.
`application-transition.txt` records flight/endpoints, native pixels, live-world
margins, input isolation and lifecycle with the full population initialized.
The agent also inspected the current pavilion terminal and Lodge upstairs
renders (`pavilion-terminal.png`, `lodge-upstairs.png`).

## Matched rendering cost

Sequential samples on the named host, capped at 60 fps: 120 warm-up frames and
180 measured frames per matched view. Twelve animals versus `--no-animals`.
All times are milliseconds. Raw JSON and actual enabled/disabled images accompany
this table; moving animal positions can change the visible draw counts.

| View | Frame median/p95 off | Frame median/p95 on | Physics median off/on | Draw calls off/on |
| --- | --- | --- | --- | --- |
| square | 16.681 / 17.270 | 17.052 / 29.853 | 1.193 / 6.480 | 1025 / 1508 |
| meadow | 16.669 / 17.212 | 16.596 / 18.973 | 1.258 / 7.060 | 293 / 495 |
| east | 16.681 / 17.108 | 16.684 / 18.634 | 1.254 / 5.860 | 623 / 761 |

Animals add approximately 4.6–5.8 ms to median physics time in these samples.
Frame medians stay near the cap, but the square p95 reaches 29.9 ms. These are
short samples with finite frame-time variation, not a sustained 60 fps promise
or Steam Deck acceptance. Increasing population requires another cost check.

## Build, assets and test procedure

`validation-final.txt` records offline asset verification, Godot import/script
checks, bridge build and default startup. `python.txt` records 14 passing Python
tests; `node.txt` records 62 passing plugin tests. Five original model GLBs
regenerate byte-identically. Missing and corrupt model fixtures fail offline
verification. Manifest SHA-256, geometry counts and node contracts live with the
[assets](../../../world/art/animals/README.md); no downloaded animal assets or
new dependencies ship. Model total is 19,720 triangles; twelve instances place
47,760 triangles before renderer accounting/shadows.

From the repository root:

```sh
python3 world/tools/verify_village_animals.py
XDG_CONFIG_HOME="$PWD/.tools/godot-check-config" tools/validate-godot-project.sh
# Use a display-capable Godot or a private Weston wrapper as GODOT_BINARY:
XDG_CONFIG_HOME="$PWD/.tools/godot-check-config" tools/check-godot-animals.sh
# Additional deterministic seed (same scene, physics step and assertions):
tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path world \
  --audio-driver Dummy --max-fps 60 --script res://tests/village_animals.gd \
  -- --no-terminal --windowed --animal-seed=2215
# Run once each with and without --no-animals, sequentially on an idle GPU:
tools/Godot_v4.7.2-stable_linux.x86_64 --path world --audio-driver Dummy \
  --max-fps 60 --script res://tests/animal_render_cost.gd -- --no-terminal --windowed
```

Retained tests use `--script res://tests/<name>.gd -- --windowed` with the same
Godot/audio/max-fps settings and an isolated `ELSEWHERE_LAUNCHER_STATE_DIR` per
trial. Headless geometry tests additionally use `--headless`. Private Weston
uses `--backend=headless --fake-seat --renderer=gl --width=1280 --height=800
--idle-time=0 --no-config`, a unique socket, and launches Godot after a one-second
startup delay with `--display-driver wayland`. Resize uses a 1600×1000 output.

## Failures investigated and verification order

Initial script typing errors were fixed before behavior acceptance. Trials
exposed two goats unable to leave already-overlapping clearance envelopes;
outward-only escape and a focused regression fix that deadlock. Path smoothing
initially could cross open-sided covered ground; exterior checks now apply to
smoothed segments and steering as well as graph nodes, with a roof regression.
Rendered leg/hip gaps and floating hooves were corrected with continuous hip
geometry and terrain foot solving before the final five-species captures.

The first private-display live-app runs reported unavailable host focus. The
same unchanged application assertions pass when the private display matches
the 1280×800 window; no production input code was changed for that harness issue.
Final enhanced Terminal/Vim evidence is separate from that failed batch entry.

The first rendered expansion/stair trials missed walking targets and the latter
then failed to reach its live panel. Matched samples exposed an actual physics
cost regression: wide animal bodies repeatedly swept the dense ground mesh,
raising median physics time from about 1.2 ms to 18–20 ms. A rounded collider
alone did not fix it. The final controller samples terrain height for vertical
support, validates real exterior ground through navigation, retains physical
obstacle/actor sweeps, and avoids idle movement sweeps. The original measurements
are preserved in `render-cost-initial.json`. No walking tolerances or application
assertions were relaxed. Fresh full rendered checks pass all ten added buildings,
all six upstairs rooms and Terminal/Vim continuity after that correction.

The first application-transition trials also missed the short intermediate
flight during startup. Navigation now yields on an elapsed-time slice budget,
and model resources preload with the scene; first instantiation/rendering is
spread across frames. Diagnostics showed that this legacy fixture entered its
first 0.22 s flight while navigation was still building and zero animals existed;
by the following
render callback the flight had completed and correctly cleared its material.
The fixture now waits for the asynchronous population to be ready and asserts
all twelve animals are present before exercising the unchanged flight/input/
lifecycle assertions. The final isolated transition trial passes all assertions.

The final headless/GPU animal suite, seed-2215 trial, cost samples and startup
transition run follow the terrain-support and startup-scheduling fixes. Retained
geometry/pavilion/resize/help/color runs precede those final animal-only fixes;
full rendered expansion/upstairs/Terminal+Vim retries follow terrain support.
Upstairs and Terminal/Vim also follow the startup scheduling change.
Final documentation/diff/parser validation and the scoped local commit follow
all checks. P22-T13 files remain uncommitted; no human gate is advanced.
