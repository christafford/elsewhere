# P22-T11 — actual village and desktop evidence

2026-10-15, Codex agent-run/agent-observed, from `5e5c416` plus P22-T11.
P22-T11 verification passed; P22-T09 and human P22-T10 remain unchecked.
These are real Godot renders and live Wayland applications, not image-generation
mockups or screenshot replay. See [implementation handoff](../../handoffs/56-furnished-village.md)
and [approved scope](../../handoffs/55-village-expansion-plan.md).

## Explore the expanded village

| Destination | Exterior/street | Interior | Real terminal placed | Same shell revisited |
| --- | --- | --- | --- | --- |
| Copper Kettle tavern | [Frontage](copper-frontage.png) | [Room](copperkettle-interior.png) | [Desk](copperkettle-workspace.png) | [Shell](copperkettle-same-shell.png) |
| Lantern Inn | [Lane](lantern-lane.png) | [Room](lanterninn-interior.png) | [Desk](lanterninn-workspace.png) | [Shell](lanterninn-same-shell.png) |
| Village Library | [Street](library-street.png) | [Room](library-interior.png) | [Desk](library-workspace.png) | [Shell](library-same-shell.png) |
| Bookbinder | [Frontage](bookbinder-frontage.png) | [Room](bookbinder-interior.png) | [Desk](bookbinder-workspace.png) | [Shell](bookbinder-same-shell.png) |
| Morning Loaf bakery | [Frontage](bakery-frontage.png) | [Room](bakery-interior.png) | [Desk](bakery-workspace.png) | [Shell](bakery-same-shell.png) |
| Leaf & Root apothecary | [Frontage](herb-frontage.png) | [Room](apothecary-interior.png) | [Desk](apothecary-workspace.png) | [Shell](apothecary-same-shell.png) |
| Earthenware pottery | [Lane](trade-lane.png) | [Room](pottery-interior.png) | [Desk](pottery-workspace.png) | [Shell](pottery-same-shell.png) |
| Village Store | [Frontage](store-frontage.png) | [Room](generalstore-interior.png) | [Desk](generalstore-workspace.png) | [Shell](generalstore-same-shell.png) |
| Hearthside tavern | [Frontage](hearth-frontage.png) | [Room](hearthside-interior.png) | [Desk](hearthside-workspace.png) | [Shell](hearthside-same-shell.png) |
| Meadow Inn | [Frontage](meadow-frontage.png) | [Room](meadowinn-interior.png) | [Desk](meadowinn-workspace.png) | [Shell](meadowinn-same-shell.png) |

Other eye-level views: [retained square](square-north.png),
[northern quarter](north-quarter.png), [western shops](west-shops.png),
[southern court](southern-court.png). Artifact details:
[pottery wheel/vessels](pottery-artifacts.png), [produce crates](generalstore-artifacts.png),
[mortar and drawers](apothecary-artifacts.png), [reading lectern](library-artifacts.png).
The tables have clear working areas; the central aisles and doorway ramps remain
walkable. Upper stories/windows are decorative. No people or simulated commerce.

## Checks

- [Expansion headless](headless.txt) and [graphical](graphical.txt): all ten lanes
  walked both ways, all ten entries/interiors traversed, floor/enclosure/bank and
  support clearance checked, and safe Home return. The graphical run places a
  real terminal using mouse/wheel input in every new destination; entity,
  transform, shell PID and variable survive leaving/returning, followed by
  resumed typing and normal close. [Build/import and full helper](check.txt).
- [Architecture](architecture.txt), [landscape](landscape.txt) and
  [outdoor startup](outdoor.txt) pass headless/GPU. Both original landscape
  trials walk 337.8m, probe 24,178 ground points and keep floor error under 6mm.
- [Original interiors](interiors.txt): the Lodge, Guildhall and Workshop retain
  their walking and real-terminal placement/revisit/close checks.
- [Pavilion](pavilion.txt): table support, stool carry/rotate/cancel, same shell
  and 49 background revisions. [Render](pavilion-revisited.png).
- [Terminal/Vim](village-applications.txt): two original live instances, unsaved
  buffer and shell continuity with 23 background revisions.
  [Terminal](terminal-revisited.png), [editor](editor-revisited.png).
- [Firefox](firefox.txt): real typing, clipboard, pointer, reuse, independent
  windows, confirmed close and profile relaunch. [Render](firefox-relaunched.png).
- Six default graphical checks: [screen colors](screen_color.txt),
  [keyboard](terminal_input.txt), [pointer/scroll](terminal_pointer.txt),
  [resize](terminal_resize.txt), [launcher](app_launcher.txt),
  [transitions](application_transition.txt). [Regression summary](regressions.txt).
- [Python](python.txt): 14 tests. [Node/parser](node.txt): 62 tests.
  [Model SHA-256](models.sha256) and [budgets](model-budgets.json): twenty
  original GLBs regenerate byte-identically. Nine existing CC0 texture maps
  validate offline. [Document checks](documentation.txt) cover links, task IDs,
  parser compatibility and diffs.

The full retained suites preceded only the final change raising decorative
exterior flue bases above the finished ceilings. The affected expansion trial
and import were rerun after that final geometry correction. No old checkpoint
is substituted for a fresh run in the above list.

## Reproduction and host

From repository root, with the pinned Godot and an available graphical display:

```sh
python3 world/tools/build_village_expansion.py
tools/check-godot-expansion.sh
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
tools/check-godot-interiors.sh
tools/check-godot-pavilion.sh
tools/check-godot-village-applications.sh
tools/check-firefox-application.sh
python3 -m unittest discover -s tests -p 'test_*.py'
node --test --test-isolation=none .opencode/tests/*.test.js
```

The six default fixtures use `--path world --audio-driver Dummy --max-fps 60
--script res://tests/<name>.gd`, with names matching the six logs above and
isolated launcher state. The street fixture is `res://tests/village_streets.gd`;
its [log](streets.txt) covers fourteen fixed eye-level captures. Model generation
requires only the existing Python standard library; no network or source cache.

This session used `GODOT_BINARY="$PWD/.tools/p22-t11/godot-check.sh"` for the final
expansion and retained regression runs. Earlier captures used the equivalent
interiors wrapper. For graphical calls, the wrapper starts private Weston with
`--backend=headless --fake-seat --renderer=gl --width=1280 --height=800
--idle-time=0 --no-config` and a unique socket, then runs pinned Godot with
`--display-driver wayland`. Headless calls invoke Godot directly. The resize
fixture uses 1600×1000. No host service/session replacement. Versions observed:
Godot 4.7.2, Compatibility/OpenGL 3.3, NVIDIA RTX 3080/615.78.08, Weston 15.0.1.

## Iteration and limits

Render review corrected shelf-crown intersections, inn signs hidden behind
balconies, undersized lettering, one-sided awnings, gables intersecting hipped
roofs and exterior flue bases intruding into two ceilings. The initial
[lane failure](initial-lane-failure.txt) records the southern path hitting the
side of a raised ramp; its centerline now joins the straight ramp approach.
No collision/input assertion was weakened and no controller shortcut was added.

Initial import/Python calls were sandbox-blocked from editor-settings/local
socket operations; approved reruns pass. Optional Weston cursor/protocol warnings
and one shader-cache recompilation are retained in logs. Chrome and retained-study
source assets remain unavailable. No fresh full native suite, restart persistence,
general app compatibility, human art/comfort approval or P22-T09/P22-T10 acceptance
is claimed. Rendering measurements below describe only this named host.


## Named-host cost comparison

Fresh baseline at `5e5c416` and final P22-T11, identical seven camera views,
1280×800, Compatibility renderer, private Weston GL, `--max-fps 60` and vsync.
Raw [baseline](baseline-cost.json), [final](final-cost.json) and
[final run](atmosphere.txt). Each view uses a short 120-frame
sample; medians near 16.67ms are capped and do not measure GPU headroom.

| View | Draw calls before → after | Median ms before → after | p95 ms before → after |
| --- | ---: | ---: | ---: |
| arrival | 668 → 1455 | 16.661 → 16.645 | 17.034 → 17.370 |
| north-outlook | 61 → 423 | 16.677 → 16.693 | 17.096 → 17.055 |
| east-outlook | 53 → 59 | 16.669 → 16.682 | 16.939 → 17.130 |
| south-outlook | 38 → 38 | 16.666 → 16.662 | 16.965 → 17.122 |
| west-outlook | 41 → 41 | 16.668 → 16.663 | 17.078 → 17.018 |
| south-return | 732 → 2113 | 16.667 → 16.723 | 16.918 → 28.182 |
| pavilion-edge | 41 → 41 | 16.667 → 16.650 | 17.099 → 17.064 |

The denser geometry and interior lights raise draw calls substantially: 2.18× at
arrival and 2.89× at south-return. The final south-return p95 reaches 28.182ms;
this is recorded as measured, not treated as a guaranteed 60fps result. Draw
counts include rendering passes rather than unique objects. No target-device,
sustained, memory or uncapped throughput acceptance is inferred. Further
performance work belongs to separately authorized P22-T09.

Matched actual renders: arrival [before](baseline-arrival.png) / [after](final-arrival.png),
south-return [before](baseline-south-return.png) / [after](final-south-return.png).
