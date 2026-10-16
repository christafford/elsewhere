# P22-T12 — actual stair, upstairs and desktop evidence

2026-10-16, Codex agent-run/agent-observed, from `9ba86aa` plus P22-T12.
P22-T12 verification passed. P22-T09 and human P22-T10 remain unchecked.
These are actual Godot renders and live Wayland applications. See
[implementation](../../handoffs/58-village-second-floors.md) and
[approved scope](../../handoffs/57-village-upstairs-plan.md).

## Six converted buildings

| Building | Downstairs | Stair flight | Landing | Upstairs | Live terminal | Same shell revisited |
| --- | --- | --- | --- | --- | --- | --- |
| Lodge | [Room](lodge-downstairs.png) | [Stairs](lodge-stairs.png) | [Landing](lodge-landing.png) | [Room](lodge-upstairs.png) | [Desk](lodge-workspace.png) | [Shell](lodge-same-shell.png) |
| Guildhall | [Room](guildhall-downstairs.png) | [Stairs](guildhall-stairs.png) | [Landing](guildhall-landing.png) | [Room](guildhall-upstairs.png) | [Desk](guildhall-workspace.png) | [Shell](guildhall-same-shell.png) |
| Copper Kettle | [Room](copperkettle-downstairs.png) | [Stairs](copperkettle-stairs.png) | [Landing](copperkettle-landing.png) | [Room](copperkettle-upstairs.png) | [Desk](copperkettle-workspace.png) | [Shell](copperkettle-same-shell.png) |
| Lantern Inn | [Room](lanterninn-downstairs.png) | [Stairs](lanterninn-stairs.png) | [Landing](lanterninn-landing.png) | [Room](lanterninn-upstairs.png) | [Desk](lanterninn-workspace.png) | [Shell](lanterninn-same-shell.png) |
| Library | [Room](library-downstairs.png) | [Stairs](library-stairs.png) | [Landing](library-landing.png) | [Room](library-upstairs.png) | [Desk](library-workspace.png) | [Shell](library-same-shell.png) |
| Meadow Inn | [Room](meadowinn-downstairs.png) | [Stairs](meadowinn-stairs.png) | [Landing](meadowinn-landing.png) | [Room](meadowinn-upstairs.png) | [Desk](meadowinn-workspace.png) | [Shell](meadowinn-same-shell.png) |

The fixtures inspect normal ascent, slow descent, real guard collision, 2.1m
headroom along the route, supported upper floors, enclosure and work-pad
clearance. Graphical trials establish a shell PID/variable, place the real panel
using mouse/wheel input, descend and exit, climb back, verify identity/placement
and shell continuity, type again and close normally. Home returns from upstairs.
No jump, teleportation or controller adjustment is used to climb the stairs.

## Results and verification order

- [Full helper/import](check.txt), [headless stairs](headless.txt) and
  [graphical stairs/live apps](graphical.txt): six rooms, zero failures.
- [Architecture](architecture.txt), [landscape](landscape.txt), [outdoor startup](outdoor.txt),
  [original interiors](interiors.txt) and [village expansion](expansion.txt): both
  headless/GPU paths pass; original downstairs and all ten expansion worktables
  retain live-terminal placement/revisit/typing/close. Landscape walks 337.8m
  with 24,178 probes in each mode; maximum floor error stays under 6mm.
- [Pavilion](pavilion.txt): stool/placement/shell checks pass, 50 background
  revisions. [Terminal/Vim](village-applications.txt): same live instances and
  unsaved editor buffer survive revisiting, 22 background revisions.
  [Firefox](firefox.txt): typing, clipboard, pointer, reuse, independent windows,
  close and profile relaunch pass. Actual retained application renders:
  [pavilion](pavilion-revisited.png), [terminal](terminal-revisited.png),
  [editor](editor-revisited.png), [Firefox](firefox-relaunched.png).
- Six default graphical fixtures pass: [color](screen_color.txt),
  [typing](terminal_input.txt), [pointer](terminal_pointer.txt),
  [resize](terminal_resize.txt), [launcher](app_launcher.txt),
  [transition](application_transition.txt). [Regression summary](regressions.txt).
- [Python](python.txt): 14 passed. [Node/parser](node.txt): 62 passed.
  [Model budgets](model-budgets.json) and [SHA-256](models.sha256): all 39 rebuilt village
  GLBs regenerate byte-identically; the 22 changed/new assets are recorded here.
  [Documentation checks](documentation.txt) cover links/task parsing and diffs.
- After the final visual corrections, [import/bridge/startup](final-import.txt)
  passed again. [Headless roof/canopy checks](roof-headless.txt) and
  [graphical roof/canopy checks](views.txt) cover 275 ceiling rays, the moved
  tree's bank/lane/upper-room clearance, and 42 fresh actual views. Selected
  ceiling details: [Lodge](lodge-ceiling.png), [Copper Kettle](copperkettle-ceiling.png).

**Order matters:** the upstairs walking/live-app run and its workspace/shell
images preceded the final roof-shaped chimney trim and four-metre northward move
of the Lantern Inn's neighboring tree. Retained regressions started before the
chimney trim and finished before the tree move. These visual fixes leave stairs, floors,
worktables and desktop logic unchanged. All downstairs/stair/landing/upstairs
images in the table are fresh after both fixes; workspace application images
record the preceding live-app run (including its then-visible chimney base).
The final roof/canopy checks, import, renders and isolated cost sample follow
both fixes. The view fixture places capture cameras directly and is explicitly
not walking or application evidence; those come from the full stair fixture.

Initial failures/corrections: the walking guide needed Godot's clockwise face
orientation; dormer bases and chimney undersides were trimmed above the roof;
Copper Kettle seating was separated from its desk; pendant fixtures were added;
and the neighboring tree canopy was removed from the Lantern Inn stairwell.
No controller shortcut or weakened collision/input assertion was used.
Python socket fixtures initially failed under sandbox restrictions; an approved
rerun passed. Optional Weston protocol/cursor warnings, a shader-cache rebuild
and the GTK icon-theme warning are preserved in logs.

## Reproduction

From repository root, using pinned Godot and an available graphical display:

```sh
python3 world/tools/build_village_models.py
python3 world/tools/build_village_expansion.py
python3 world/tools/build_village_upstairs.py
tools/check-godot-upstairs.sh
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
tools/check-godot-interiors.sh
tools/check-godot-expansion.sh
tools/check-godot-pavilion.sh
tools/check-godot-village-applications.sh
tools/check-firefox-application.sh
python3 -m unittest discover -s tests -p 'test_*.py'
node --test --test-isolation=none .opencode/tests/*.test.js
```

Six default graphical fixtures use `--path world --audio-driver Dummy
--max-fps 60 --script res://tests/<name>.gd`: `screen_color`, `terminal_input`,
`terminal_pointer`, `terminal_resize`, `app_launcher`, `application_transition`.
Launcher state is isolated per trial. Final rendering samples use
`res://tests/village_atmosphere.gd`; the baseline adds `-- --baseline`. Final geometry/view inspection uses
`res://tests/village_upstairs_views.gd` in headless and graphical modes.

This session sets `GODOT_BINARY="$PWD/.tools/p22-t12/godot-check.sh"`. The wrapper
invokes pinned Godot directly for headless calls. Graphical calls start private
Weston with `--backend=headless --fake-seat --renderer=gl --width=1280
--height=800 --idle-time=0 --no-config` and a unique socket, then Godot with
`--display-driver wayland`. The resize trial uses 1600×1000. No host desktop or
service is replaced. Host observed: Godot 4.7.2, Compatibility/OpenGL 3.3,
NVIDIA RTX 3080/615.78.08. Rendering measurements are short, capped samples and
cannot establish target-device headroom or sustained frame rates.

## Limits

Agent render inspection and automated input are not personal comfort or human
art approval. Windows, exterior balconies and Guildhall's remaining upper
stories/turret remain decorative. No people, further floors, new services or
restart restoration. Chrome and retained-study sources remain unavailable.
No fresh full native Meson/sanitizer suite is claimed for this scene-only change;
the normal validator builds the bridge. P22-T09 and human P22-T10 remain separate.


## Named-host before/after cost

Both samples use identical seven views at 1280×800, Compatibility rendering,
private Weston GL, `--max-fps 60` and vsync, with 120 frames per view. The baseline
was captured before implementation at `9ba86aa`; the final sample runs alone
after the other graphical trials have exited. [Baseline log](baseline.txt),
[baseline counters](baseline-cost.json), [final log](atmosphere.txt),
[final counters](final-cost.json).

| View | Draw calls before → after | Median ms before → after | p95 ms before → after |
| --- | ---: | ---: | ---: |
| arrival | 1455 → 2080 | 16.676 → 16.679 | 17.303 → 17.346 |
| north-outlook | 423 → 465 | 16.660 → 16.683 | 17.265 → 17.110 |
| east-outlook | 59 → 56 | 16.653 → 16.673 | 17.044 → 17.198 |
| south-outlook | 38 → 38 | 16.678 → 16.670 | 17.243 → 17.210 |
| west-outlook | 41 → 41 | 16.653 → 16.656 | 17.247 → 17.098 |
| south-return | 2113 → 2699 | 16.658 → 16.692 | 17.360 → 17.487 |
| pavilion-edge | 41 → 41 | 16.669 → 16.670 | 17.284 → 17.071 |

Extra room geometry and lights increase draw calls: arrival 1,455 → 2,080,
south-return 2,113 → 2,699. Median intervals remain near the 16.67ms cap; the
final p95 range is 17.071–17.487ms. These short vsync-bound measurements do not
establish uncapped GPU headroom, stable sustained 60fps, memory budgets or Steam
Deck performance. P22-T09 remains unperformed.

Matched actual renders: arrival [before](baseline-arrival.png) / [after](final-arrival.png),
south-return [before](baseline-south-return.png) / [after](final-south-return.png).
