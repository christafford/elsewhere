# Animal blast evidence — 2026-11-01

Agent-run against `1cc1469` plus this bounded change. Actual GPU captures use
Godot `4.8.beta2.official.cafc17a19`, Forward+/Vulkan 1.4.351, NVIDIA GeForce
RTX 3080, a private Weston headless GL/Wayland display and 1280×800 viewport.
Headless assertions are separate from actual render inspection. No human or
sustained/target-device performance acceptance is implied.

## Final results

- `suite.txt`: offline assets, bridge build, Godot import/startup, then both
  effect modes pass. `headless-final.txt` and `graphical-final.txt` each pass all
  20 species/effect combinations and input/lifecycle cases with zero errors.
- `retained-headless-animals.txt`: normal twelve-animal wander/forage, player
  yielding, clearance and crowded crossing pass; maximum foot error 0.001003m,
  maximum step 0.015900m, minimum normal separation 0.959 of summed padded radii.
- `retained-village_applications.txt`: real Terminal/Vim pass typing, placement,
  20.49m outbound travel/revisit, same shell variable and unsaved editor, resumed
  typing and close. Four concurrent effects expire during client use without
  stealing focus. Animals travel 34.68m during the first typing segment.
- `retained-help_overlay.txt`, `retained-application_transition.txt`,
  `retained-terminal_pointer.txt`, `retained-screen_color.txt` and
  `retained-pavilion_workspace.txt`: modal input/restore, world/application
  transition, real selection/scroll, exact client colors, and pavilion
  panel/furniture/shell continuity all pass. Pavilion records 48 background
  revisions and the same shell/entity on return.
- `node-tests.txt`: all 62 existing parser/plugin tests pass. New checker shell
  syntax, changed document links, unchanged roadmap task parsing and final
  diff validation pass. No C++ source change or new native test result claimed.

Agent inspected actual final bolt/charcoal, red player beam/eye-fire, cyclone
sequence, smoke-heart/licking and restored dog/pig/chicken/goat/cow frames. The
softened funnel is translucent, hearts remain legible and dissipate, temporary
colors/transforms are absent after expiry. Returned live Terminal/Vim renders
and the updated F1 overlay were also inspected. Human appearance/comfort,
physical mouse behavior and sustained/target-device performance remain unobserved.

## Reproduction

```sh
# Import, bridge build, every effect/species, input and lifecycle assertions:
XDG_CONFIG_HOME="$PWD/.tools/godot-check-config" tools/check-godot-animal-blasts.sh
# Normal population behavior/crowding (no forced effect):
tools/godot --headless --path world --audio-driver Dummy --max-fps 60 \
  --script res://tests/village_animals.gd -- --no-terminal --windowed
# Real Terminal + Vim, including four concurrent effects during client typing:
tools/godot --path world --audio-driver Dummy --max-fps 60 \
  --script res://tests/village_applications.gd -- --windowed --exercise-animal-blasts
node --test .opencode/tests/*.test.js
```

`GODOT_BINARY` may point to a private-display wrapper for the shell checker.
The session used `.tools/animal-blasts/gpu-godot`: Weston `--backend=headless
--fake-seat --renderer=gl --width=1280 --height=800 --idle-time=0 --no-config`,
a unique socket, and Godot `--display-driver wayland`. No host desktop/services
were changed. Use a separate `ELSEWHERE_LAUNCHER_STATE_DIR` for live-client checks.

## Fixture scope

`animal_blasts.gd` stages a subject and a stationary companion on clear square
terrain, runs the real animal controller, and forces each outcome on each of
five species. This is explicitly a staged effect fixture, not natural animal
placement or a mocked desktop. Normal rendered timing is 60Hz; the headless
trial accelerates time 4× with 240Hz physics, retaining the 1/60s simulation step.

Checks cover all 20 species/outcome combinations, authored eye anchors, nearest
companion choice, pursuit and interaction, lightning travel/jump, cyclone lift,
grounded collision reservation, expiry/coat/pose cleanup, repeat-click rejection,
64 random activations covering all four outcomes, solo fire/love cleanup and
no leaked eye/tongue nodes. Input uses actual `Input.parse_input_event` dispatch
for single/double clicks and ownership modes. Headless cannot capture a physical
pointer, so mouse-look capture is tested graphically. The synthetic ownership
fixture has no client and suppresses pointer routing during its fake app state;
real-client continuity is tested separately.

Physical occlusion uses an actual StaticBody3D fixture. Panel occlusion uses the
real application housing class, explicitly without synthetic client content;
front/back housing blocks animal picking, and an animal blocks picking a panel
behind it. Existing real Terminal/Vim and pavilion trials verify live panels.

## Render inventory

Ignored actual captures live under `.tools/animal-blasts/`:
`effect-0-frame-011.png` shows the sky bolt/charred jump;
`effect-1-frame-011.png` the red player beam and `effect-1-frame-155.png` eye-fire;
`effect-2-frame-{011,035,083,155}.png` the descending/lifting/spinning cyclone;
`effect-3-frame-035.png` the smoke-heart beam and `effect-3-frame-155.png`
companion-facing licking/hearts. `<species>-<kind>-restored.png` captures each
species after each effect. These are rendered frames from running controllers,
not scene serialization, replay or human observation.

## Diagnosed failures

Initial eye lookup searched children but omitted the Head mesh itself; the
lookup now includes it. Chicken pursuit initially ended at a coarse graph
point short of interaction range; checked final approach segments fix that.
Ray picking initially passed static bodies to a typed animal array lookup;
a type guard now handles walls/ground without errors. Initial cyclone ribbons
were too harsh; soft ribbon edges and a translucent tapered funnel improve the
actual render. Fixture-only issues (headless pointer capture and fake app mode
without a client session) were isolated without weakening production routing.
