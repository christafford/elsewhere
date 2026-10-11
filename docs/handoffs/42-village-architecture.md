# P22-T04 — Village landmark, exteriors and pavilion

Owner-requested single task, 2026-10-10, base `e81c88c`. Authority:
[Decision 08](../decisions/08-elsewhere-village-world.md). P22-T05 is not started.

## Architecture and scope

The default village now has a compass fountain in the square, three distinct
sealed building exteriors, and an open covered pavilion. Fixed placements keep
all four P22-T03 approaches and the spawn/cross-square walking lines open.

| Structure | World center (x,z), meters | Architectural identity |
| --- | --- | --- |
| Compass fountain | (-5,-4) | Twelve-sided stone basin, turned column, bronze spouts and compass crown, 4.5m high |
| Alpine lodge | (-17,-18) | Broad pitched roof, deep eaves, exposed timber frame, bracketed balcony, shutters, chimney |
| Guildhall | (12,-18) | Tall stepped gable, arched entry, stone quoins/cornices, decorative clock |
| Stone workshop | (24,-10), facing west | Low hipped roof, divided windows, arched door, side lean-to, twin chimney pots |
| Work pavilion | (-18,18) | 9 × 7m open floor, six posts, knee braces, king-post trusses, hipped roof and north ramp |

The fountain occupies the northwestern part of the square without blocking
its crossing axes. Buildings face the square and have modeled side/rear
windows as well as complete fronts. Their foundations bury into the existing
terrain; individual entrance steps connect the visible closed thresholds to
the grade. Building interiors, door-opening behavior, animated water and a
functional clock are not implemented or implied. The pavilion has a walkable
covered floor; work furniture and anchors remain P22-T07.

Five original GLB models (11,520 triangles total) and explicit import settings
are tracked, along with their deterministic Python standard-library authoring
source. No downloaded assets, dependencies or engine upgrades were added.
[Model provenance](../../world/art/village/README.md) records dimensions,
coordinates, normals/UV conventions, named base materials and SHA-256 hashes.
The source rebuild produces byte-identical GLBs. The included models work
without running Python at launch or contacting any asset provider.

`main.tscn` adds one sibling `Architecture` node with
`village_architecture.gd`. That script places the imported meshes, fits their
foundations/steps to the existing height function and supplies static mesh
collision, including the pavilion ramp. It has no desktop ownership or input
logic. Existing collision queries see these structures on the ordinary world
layer. The landscape, player, placement callback, DesktopRuntime, launcher,
application objects/modes and native compositor are unchanged.

The terrain-coverage test now excludes only the tagged architecture bodies
from its ground rays, so it still checks the actual terrain under the buildings.
No route, grade, coverage or support assertion was removed. Its controller
walks still collide with the entire scene. The new architecture trial checks
sealed facades, the fountain, and walking up/down the covered pavilion ramp.

## Actual render review

Observer: Codex agent, Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4,
AMD Custom GPU 0405 (Vangogh/Steam Deck), private Weston 15.0.1, 1280 × 800.
Cameras use the real player's 1.6m eye height above its supported feet.
These are engine renders, not concept images or serialization checks.

Reviewed final views:

- [Arrival](../evidence/p22-t04/arrival.png): fountain, lodge and tall guildhall
  establish distinct shapes around an unobstructed northern approach.
- [East square](../evidence/p22-t04/east-square.png): gables, balcony and fountain
  remain recognizable across the paved square.
- [Northern return](../evidence/p22-t04/north-return.png): fountain and open
  pavilion frame the south/west circulation.
- [Southern approach](../evidence/p22-t04/south-approach.png): all three exteriors
  read separately, with the pavilion at the left and a clear approach route.
- [Lodge](../evidence/p22-t04/lodge.png),
  [guildhall](../evidence/p22-t04/guildhall.png) and
  [workshop](../evidence/p22-t04/workshop.png): modeled roofs, joinery, window
  reveals/mullions, closed door surrounds and terrain-fitted entrance steps.
- [Pavilion](../evidence/p22-t04/pavilion.png) and
  [covered view](../evidence/p22-t04/pavilion-covered.png): roof thickness,
  posts/braces/trusses, grounded floor and open view back to the village.

Initial renders are retained locally in `.tools/p22-t04/initial-captures/`.
They exposed an overly bare tall lodge plinth, blank side elevations and a
misaligned lean-to roof. Added entrance steps, contrasted the architectural
plinth, modeled side/rear windows and corrected the lean-to offset. Moved the
lodge capture back at the same eye height to include its complete roof.
Final captures were inspected again after these changes.

The first collision trial walked away from each facade because the test heading
was reversed. Correcting the test yaw, and aiming beside the newly modeled
entrance steps, preserves its original wall-contact assertion. Both headless
and graphical trials then pass. Initial failure evidence is retained in
`.tools/p22-t04/architecture-initial.log` and
`/tmp/elsewhere-architecture-check.ShjfQs/`; no controller change was made.

Base materials, bright sunlit stone, plain grass and the faceted outer bank
remain provisional. This task establishes recognizable modeled architecture
and walkable routes, not the P22-T05 material/foliage/lighting or visual-delight
gate. No new human comfort observation, final performance claim or P22-T06/P22-T09
application acceptance is made.

## Verification

The existing private GPU Weston wrapper gives each graphical trial a nested
output and passes headless runs directly to the pinned engine. No host service
or configuration is changed.

```sh
python3 world/tools/build_village_models.py
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-architecture.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-landscape.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
node --test .opencode/tests/auto-continue.test.js
```

Architecture import/default-startup and both headless/graphical trials pass
`VILLAGE_ARCHITECTURE_OK ... exteriors=3 landmark=1 pavilion=1 failures=0`.
They assert empty working desktop startup, actual imported models, closed
facade/fountain collision, actual controller travel up/down the pavilion ramp,
supported floor under a real roof collider and safe Home return. See
`.tools/p22-t04/architecture.log` and `/tmp/elsewhere-architecture-check.48tF5E/`.
The earlier capture-only run is labeled `ARCHITECTURE_CAPTURE_OK`; it does not
claim walking/collision coverage.

Eight Python catalog/launcher tests and 62 parser/plugin tests pass. The known
optional icon-theme/deprecation warnings remain. Python syntax, shell syntax
and deterministic model rebuild checks pass.

The full landscape trial passes headless and graphically with the buildings
present: 24,178 ground samples, approximately 337.8m walked, maximum sampled
grade 14.39°, floor gap below 6mm. All four full route round trips and the
cross-square path are unchanged. Logs: `landscape.log` / `landscape-details/`
(copied from `/tmp/elsewhere-landscape-check.Hn0bnt/`).

The unchanged outdoor trial passes in both modes: empty startup beyond the
watchdog, manual real-terminal launch, walking/jump/Home, all ten boundaries
and corner, panel drag/rotation/cancel, typing/return, terrain-supported live
panel identity and cleanup. Logs: `outdoor.log` / `outdoor-details/` (from
`/tmp/elsewhere-outdoor-check.obj51r/`). Agent-inspected captures:
[default empty arrival](../evidence/p22-t04/empty-arrival.png),
[terminal output](../evidence/p22-t04/application.png), and
[the live panel beside the lodge](../evidence/p22-t04/slope-panel.png).
The last uses the existing explicit fixture repositioning; it does not claim
a new pavilion workspace or the P22-T07 revisit/anchor acceptance.

All seven existing graphical regressions pass unchanged: `screen_color`,
`terminal_input`, `terminal_pointer`, `terminal_resize`, `app_launcher`,
`application_objects`, `application_transition`. They verify colors, keyboard
repeat, pointer selection/scroll, actual client resizing, launcher/Vim/relaunch,
independent live instances/manipulation and transitions. Five use the outdoor
default, the color check owns its fixture, and the object trial exercises the
retained study. The study scene, runtime/controller/application scripts and
native source are byte-identical to the base.

Exact commands are preserved in `.tools/p22-t04/regressions.sh`; each Godot
trial has an isolated launcher state and runs as:

```sh
ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/p22-t04/desktop-check-state" \
  timeout -k 2s 90s .tools/rename/godot-check.sh --path "$PWD/world" \
  --audio-driver Dummy --max-fps 60 --script res://tests/terminal_input.gd
```

Substitute the seven script names above. Each trial's log is checked for errors,
leaks and its `*_OK ... failures=0` marker. `.tools/p22-t04/regressions.log`
records the complete sequence, and individual script logs retain full output.

The unchanged real Chrome trial passes: trusted typing/click, scrolling both
ways, actual resize/reflow, world return, second-window identity and client
close (`CHROME_APPLICATION_OK failures=0`). See `chrome.log`, the reviewed
[typed browser note](../evidence/p22-t04/browser-input.png), and
[world return](../evidence/p22-t04/browser-in-room.png) (1000 × 700). The earlier
historical Chrome first-character flake was not observed; no fix is claimed.

All log paths without a prefix above are under ignored `.tools/p22-t04/`.
Architecture logs are also copied into `architecture-details/`. No native
source changed; no fresh Meson or full historical 21-trial study-suite result
is claimed. Documentation links, unique task IDs, actual task parsing, shell
syntax and diff checks pass. P22-T04 is complete; P22-T05 remains unchecked and
requires a separate explicit owner request. Stop here.
