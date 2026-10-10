# P22-T03 — Village landscape and circulation

Owner-requested single task, 2026-10-10, base `eca98ab`. Authority:
[Decision 08](../decisions/08-elsewhere-village-world.md). P22-T04 is not started.

## Authored site and architectural boundary

The default `main.tscn` now instances a location-owned Landscape node instead
of the 24m startup floor and four box walls. `village_landscape.gd` defines a
fixed 7 × 7 height lattice, a flat 24 × 20m paved square with a level apron,
four 4m-wide paths, and a convex ten-section raised bank. The playable boundary
spans 84 × 84m; a 96 × 96m ground mesh extends under its outer shoulder so the
edge has no exposed gap. The bank's inner faces are 2.6–4.2m above local ground,
with shared corner endpoints, an outer shoulder and closed outer sides.
This is the current finite site boundary, not the distant scenery of P22-T08.

| Route | Square connection (x,z) | Outer turnaround (x,z) | Character |
| --- | --- | --- | --- |
| South approach | (0,10) | (-8,37) | Bend down toward the square |
| West rise | (-12,0) | (-31,-16) | Highest approach, looking back over the square |
| North saddle | (0,-10) | (5,-35) | Angled northern ascent |
| East shelf | (12,0) | (32,14) | Lower, broad eastern approach |

The exact centerlines and heights are maintained in the landscape script.
There is no randomness, seed, terrain streaming, plugin or new dependency.
Startup/Home remains `(0, 0.05, 5)` on the level square, facing north (-Z).
The existing controller, jump, speeds and input policy are unchanged.

The 0.5m terrain grid produces 73,728 triangles. Rendering and static collision
use the same mesh. Paths and paving are drawn on that surface rather than on
floating overlays or separate collision steps. Ground colors and the paving
shader are original repository code; no downloaded assets or new licenses are
introduced. They are provisional circulation materials, not P22-T05 curation.
No buildings, landmark, pavilion, vegetation, extra destinations or atmosphere
work is included.

`outdoor.gd` still calls the existing DesktopRuntime initialization with the
same player/presentation nodes and callback interface. Its placement callback
now insets the convex site boundary by the whole rotated application footprint,
and samples the terrain under that footprint to keep placement above ground.
The existing physics overlap queries remain authoritative for collision.
DesktopRuntime, native compositor, launcher, application modes/objects, identity,
client recipes and controller code are untouched. Empty startup and explicit
`--terminal` / `--terminal-demo` behavior remain unchanged; `--no-terminal`
retains the separate geometry-only path. The historical study is preserved.

## Verification and iteration

Commands use the existing private GPU Weston wrapper from handoff 39. It passes
headless calls directly to the pinned engine and gives graphical trials their
own nested Weston output; no host services or configuration are changed.

```sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-landscape.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
node --test .opencode/tests/auto-continue.test.js
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
```

`check-godot-landscape.sh` validates imports/default startup and runs the new
landscape trial headless and graphically. Both modes pass:

- 24,178 half-meter cell-center ground queries inside the playable boundary;
  no missing ground or unexpected interior obstacle, and rendered terrain
  collision agrees with the authored height function within 15mm.
- Maximum sampled grade 14.39° (under the 20° test budget), with more than 2.5m
  of elevation variation across the site.
- Approximately 337.8m of actual controller walking: each complete approach
  from its endpoint through the square and back, plus a lateral square/apron
  crossing. Both uphill and downhill traversal pass; maximum measured floor
  gap is under 6mm. Home returns safely to the square.
- Panel placement bounds stay inside the bank and above the sampled footprint.

Graphical traversal uses injected W/Shift and captured mouse-look events.
Headless traversal injects the same walking keys but sets yaw explicitly:
the headless display cannot capture a pointer. Neither traversal teleports
between points on a route. Fixture positioning is used only between independent
routes and fixed capture viewpoints. These are agent-run tests, not human feel.

Initial iteration evidence is retained in ignored `.tools/p22-t03/`:
`landscape-initial.log` found sharp rectangular grading corners whose analytical
height differed from the triangulated surface by more than 15mm. Rounding the
apron-distance function removed the cusp; the assertion remains unchanged.
`landscape-headless-input-initial.log` then exposed the test's headless pointer
capture assumption; explicit headless yaw fixed that harness issue without
changing the controller. The initial renders in `initial-captures/` showed
jagged/fuzzy path edges and overly bright paving. Interpolating distance rather
than clipped coverage cleaned the edges; explicit material colors and a lower
paving value improve contrast while preserving the application tone-map contract.

Landscape logs: `.tools/p22-t03/landscape.log` and
`landscape-details/` preserve the first full pass. Final review moved the
ground-support assertion after the lateral crossing so it covers every walk;
the complete headless/graphical replay passes in `landscape-final.log` and
`landscape-final-details/` (copied from `/tmp/elsewhere-landscape-check.jttdD4/`).
Both modes report `VILLAGE_LANDSCAPE_OK ... failures=0`.

The existing outdoor regression was migrated deliberately from the retired
four-wall rectangle to every section of the authored bank (ten sections plus
a diagonal corner attempt). Its empty-startup, real launcher, walking, jump,
Home, drag/rotation/cancel, typing, return and cleanup assertions remain.
Both modes pass `OUTDOOR_STARTUP_OK ... boundaries=10 failures=0`.
An additional graphical fixture positions that same live terminal above the
western slope, beyond the old startup footprint: the existing gravity lands
it on the actual terrain, `SLOPE_OK` is written through the shell, and return
preserves its entity/window binding. Fixture repositioning is explicit; this
does not claim a full village carry/revisit acceptance trial.
Logs: `.tools/p22-t03/outdoor.log` and `outdoor-details/` (copied from
`/tmp/elsewhere-outdoor-check.a44eGS`). The bank count increases the bounded
outdoor command timeout to 90 seconds; no interaction assertion is removed.

The final color adjustment changes no terrain or collision data. A separate
final graphical capture pass repeats the ground/placement checks and five
views (`LANDSCAPE_CAPTURE_OK failures=0`):

```sh
ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/p22-t03/capture-state" \
  timeout -k 2s 60s .tools/rename/godot-check.sh --path "$PWD/world" \
  --audio-driver Dummy --max-fps 60 --script res://tests/village_landscape.gd \
  -- --capture-only
```

All seven affected existing graphical Godot trials pass: `screen_color`,
`terminal_input`, `terminal_pointer`, `terminal_resize`, `app_launcher`,
`application_objects`, and `application_transition`. Five interaction trials
use the outdoor default; `screen_color` uses its own color fixture, and
`application_objects` rechecks the retained study. No assertions in these
existing trials were edited. Commands
are recorded in `.tools/p22-t03/affected-check.sh`; each invokes:

```sh
ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/p22-t03/desktop-check-state" \
  timeout -k 2s 90s .tools/rename/godot-check.sh --path "$PWD/world" \
  --audio-driver Dummy --max-fps 60 --script res://tests/terminal_input.gd
```

Substitute each of the seven script names above. Each log is checked for its
`*_OK ... failures=0` marker and for errors/leaks; the combined results are in
`.tools/p22-t03/affected.log`, with one log per script. The entire historical
21-trial study suite was not rerun: untouched room geometry retains its dated
P22-T02 evidence. The retained study scene is still byte-identical to the base.

The unchanged isolated real Chrome trial also passes on the landscape default:
trusted typing/click, scroll both ways, actual resize/reflow, world return,
second-window identity and client-initiated close (`CHROME_APPLICATION_OK
failures=0`). Run with
`GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh`;
see `.tools/p22-t03/chrome.log`. The historical intermittent first-character
failure recorded in handoff 40 was not observed in this run; no claim is made
that it is fixed.

All eight Python catalog/launcher tests and 62 parser/plugin tests pass.
The Python checks retain the known optional icon-theme/deprecation warnings.
No native source changed; no fresh Meson/binding-suite result is claimed.

## Agent-observed rendered evidence

Final actual Godot captures, 1280×800:

- [Arrival](../evidence/p22-t03/arrival.png): grounded square, paving edge and
  northern route, with the continuous visible bank behind it.
- [South approach](../evidence/p22-t03/south-approach.png): the approach bends
  into the square, with distinct side routes visible.
- [Western rise](../evidence/p22-t03/west-rise.png): the higher ground looks
  down over the graded square and connecting paths.
- [Northern saddle](../evidence/p22-t03/north-saddle.png): reverse approach into
  the square, including both side routes.
- [Eastern shelf](../evidence/p22-t03/east-shelf.png): lower approach and
  western rise beyond the square.
- [Slope panel](../evidence/p22-t03/slope-panel.png): real terminal supported by
  the western terrain, with its grounded shadow.
- [Application](../evidence/p22-t03/application.png): real terminal output from
  the unchanged native-size application presentation.
- [Chrome input](../evidence/p22-t03/browser-input.png): complete typed note
  and Save response in the real browser.
- [Chrome return](../evidence/p22-t03/browser-in-room.png): the same live browser
  in the square after returning from application mode (1000×700).

Documentation links, unique P22 task IDs, actual plugin task parsing, shell
syntax and diff checks pass. P22-T03 is checked; later tasks remain unchecked.

Observer: Codex agent. Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4,
AMD Custom GPU 0405 (Vangogh/Steam Deck), private Weston 15.0.1. The revised
images show connected routes, a visible level square, gentle terrain and no
exposed ground seams. The bank is still a simple faceted enclosure; paving
and turf are provisional, with no foliage or buildings. These limitations are
explicitly reserved for later tasks, not presented as finished village art.
No new human input/comfort or P22-T06/P22-T09 usability/performance gate is
claimed. Stop at P22-T03; P22-T04 requires a separate explicit owner request.
