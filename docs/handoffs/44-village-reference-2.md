# Reference 2 — weathered mountain village comparison

Owner-requested alternative, 2026-10-11, base `340ca97`. The owner supplied
[reference 2](../art-direction/village-square-example-2.jpg), asked to use it
instead of the first direction and explicitly wanted to compare/switch back.
This is a bounded visual experiment under
[Decision 08](../decisions/08-elsewhere-village-world.md), not continuation into
P22-T05 or later tasks. The owner has not chosen between the candidates.

## Preservation and comparison

Reference 1 is unchanged in Git at commit `340ca97ff39e3d8c81b499ad7acc19fbc13a52b4`
and local tag `art-reference-1`. Its original nine architectural and five
application captures remain in `docs/evidence/village-reference/`. The new
candidate is the active default scene and is preserved at local tag
`art-reference-2` after verification/commit. Its renders are separate, under
`docs/evidence/village-reference-2/`; all nine architectural camera positions,
look targets and viewport dimensions match candidate 1.

Open [the comparison page](../art-direction/compare.html) directly in a browser.
Select a viewpoint, reveal either version or drag the split slider. The source
reference images are separately labeled below. The page loads repository files
only; it is not part of the desktop application or a substitute for live scenes.

To run reference 1 temporarily after saving any current changes:

```sh
git switch --detach art-reference-1
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy
# Close the running world before changing snapshots.
git switch --detach art-reference-2
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy
# Close it again; return to the working branch before editing.
git switch main
```

Validation refreshes Godot's imported mesh cache after each checkout.
This checks out the preserved snapshot without changing branch history. Switch
back to `main` before editing. For a permanent return, restore only this experiment's world/art changes from
`art-reference-1` in a new commit, retaining comparison/reference evidence and
reviewing any subsequent edits. Do not hard-reset or overwrite later runtime work. The final commit ID
is the commit that introduced this handoff (`git log --diff-filter=A --format=%h
-- docs/handoffs/44-village-reference-2.md`). Local tags were not pushed.

## What changes

The same lodge, hall, workshop and pavilion footprints frame the square.
The lodge gains weathered boarded gables and heavier braces. The hall becomes
a taller timber/plaster frontage with an attached pointed slate turret and
rust-colored pennant. Ivy replaces flower boxes; muted green canopies replace
the earlier bright foliage palette. The arch link is removed from the active
scene, opening the northern view. Its original asset remains dormant in the
repository; reference 1's full source is preserved in its commit.

The fountain keeps its 6.3m collision footprint but becomes stepped stone,
a broad basin and three bowls with decorative water jets. Animated shader
ripples suggest water; this is not a fluid simulation. Original weathering,
wood grain, stone joints and irregular cobble shading establish the cooler
palette. A fixed cloud sky and original distant rocky/snowy ridge frame the
village. Mountains are outside the playable boundary with no collision or new
destination. The existing boundary mesh receives stone detail, with unchanged
vertices/collision. Ground heights and routes are unchanged.

DesktopRuntime, controller, application shaders, identity/input/lifecycle and
native source stay unchanged. Exposure/tone mapping remain unchanged; only the
world sky, sun color/energy and ambient energy are adjusted. No new dependency,
source download, host service change or functional building interior.

## Render review and verification

Observer: Codex agent, Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4,
AMD Custom GPU 0405 (Steam Deck/Vangogh), private Weston, 1280 × 800. All nine
final architectural views are actual engine renders at player eye height:

- [Arrival](../evidence/village-reference-2/arrival.png) and
  [east square](../evidence/village-reference-2/east-square.png): tiered fountain,
  weathered frontage, ivy and mountain skyline.
- [Lodge](../evidence/village-reference-2/lodge.png),
  [hall](../evidence/village-reference-2/guildhall.png) and
  [workshop](../evidence/village-reference-2/workshop.png): timber grain,
  stone joints, ivy leaves and slate. The taller hall is cropped by the same
  close-up camera used for A; its complete silhouette is visible from the south.
- [Southern approach](../evidence/village-reference-2/south-approach.png) and
  [north return](../evidence/village-reference-2/north-return.png): the unchanged
  routes and footprint, with mountains beyond the boundary.
- [Pavilion](../evidence/village-reference-2/pavilion.png) and
  [covered view](../evidence/village-reference-2/pavilion-covered.png): supported
  ramp/floor and open view toward the altered village.

The first pass had bright faceted mountains, a ringed turret and thin ivy.
Reduced ridge height, smoothed terrain normals and made the spire continuous.
The second pass exposed regular leaf rows and hard triangle snow boundaries;
smaller irregular lobed leaves and a height/slope snow shader address those.
The final nine views were inspected again. Intermediate captures/logs remain
local under `.tools/reference-2/`; only final captures are committed.

The full architecture trial passes headless and graphically: imported models,
empty working desktop, exterior/fountain collision, pavilion ramp/covered floor
and Home return (`VILLAGE_ARCHITECTURE_OK ... failures=0`). Only the model-count
assertion changes, from six to five after removing the active bridge. All
walking/contact assertions and all comparison cameras are unchanged from A.
Logs: `architecture-final.log`, `/tmp/elsewhere-architecture-check.ss7lL7/`.

The comparison page was opened and inspected in actual headless Chrome.
All nine 1280 × 800 image pairs decoded, links tracked the selected view,
version buttons and range slider passed (`COMPARISON_OK views=9 ...`). The
initial ad-hoc probe ran before DOM load; waiting for the page fixes the probe.
No page error was hidden. The final page was tested again after adding explicit
version labels. See [browser capture](../evidence/village-reference-2/comparison-page.png)
and local `comparison-final.log` / `check-comparison.mjs`.

Seven active model rebuilds are byte-identical; the dormant bridge hash remains
unchanged. [Provenance](../../world/art/village/README.md) includes exact hashes,
triangle counts, source, coordinate conventions and limitations. Python syntax,
eight catalog/launcher tests and 62 parser/plugin tests pass. No dependency added.

Limits: the open layout, repetitive material detail, stylized jets, simple trees
and coarse ridge silhouette remain less detailed than the reference. The owner
has not selected/approved either candidate. This is not a comfort/performance
measurement or a completed P22 art/usability gate.


## Verification commands and regression evidence

The existing private GPU Weston wrapper preserves nested/headless development.
Commands run for this revision:

```sh
python3 world/tools/build_village_models.py
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-architecture.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-landscape.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
node --test .opencode/tests/auto-continue.test.js
node .tools/reference-2/check-comparison.mjs
```

The unchanged landscape trial passes in both modes: 24,178 ground samples,
337.8m walked, all four route round trips and square crossing, max grade 14.39°,
floor gap below 6mm. Logs: `landscape.log`,
`/tmp/elsewhere-landscape-check.QMBtiu/`.

The unchanged outdoor trial passes headless and graphically: empty startup
beyond the watchdog, real terminal launch, movement/jump/Home, all ten boundary
sections and corner, panel drag/rotation/cancel, typing/return, terrain-supported
live panel identity and shutdown (`OUTDOOR_STARTUP_OK ... failures=0`). Logs:
`outdoor.log`, `/tmp/elsewhere-outdoor-check.eyOlOQ/`. Reviewed captures:
[empty arrival](../evidence/village-reference-2/empty-arrival.png),
[terminal output](../evidence/village-reference-2/application.png),
[terrain-supported live panel](../evidence/village-reference-2/slope-panel.png).
This uses the existing fixture placement, not new pavilion work surfaces.

All unprefixed log paths here are under `.tools/reference-2/`. Complete logs
are copied into `architecture-details/`, `landscape-details/`, `outdoor-details/`.
The initial render passes also passed architecture checks; their geometry
checks do not substitute for the final run above.


All seven existing graphical regressions pass unchanged: `screen_color`,
`terminal_input`, `terminal_pointer`, `terminal_resize`, `app_launcher`,
`application_objects`, `application_transition`. They cover colors, ordinary
keyboard/repeat, pointer selection/scroll, real client resize, launcher/Vim/
relaunch, independent instances/manipulation and mode transitions. Five use the
outdoor default; color owns its fixture and the objects trial retains the study.
The native source, controller, desktop/application services and study scene
are byte-identical to reference 1. Each trial runs sequentially as:

```sh
ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/reference-2/desktop-check-state" \
  timeout -k 2s 90s .tools/rename/godot-check.sh --path "$PWD/world" \
  --audio-driver Dummy --max-fps 60 --script res://tests/terminal_input.gd
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh
```

Substitute the seven script names above. `regressions.sh` records the exact
sequence; `regressions.log` and individual logs contain zero-failure markers
without engine errors/leaks. The real Chrome trial passes typing/click,
scroll both ways, resize/reflow, world return, second-window identity and close
(`CHROME_APPLICATION_OK failures=0`). Reviewed
[browser input](../evidence/village-reference-2/browser-input.png) and
[world return](../evidence/village-reference-2/browser-in-room.png).
The historical first-character flake was not observed; no fix is claimed.
Known optional Wayland decoration/cursor and icon-theme warnings remain.

Documentation links, actual task parsing, ten unique P22 IDs, deterministic
model hashes and diff checks pass. Reference 1's image, captures and handoff are
byte-identical to `art-reference-1`. The new JPEG is preserved unchanged as the
owner's reference. Godot validation builds/stages the existing runtime; no
native source changed, and no fresh Meson/full historical 21-trial result is
claimed. This comparison revision is complete and committed independently;
P22-T05 and later gates remain unchecked. Stop here.
