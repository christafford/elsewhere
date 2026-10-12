# Current direction — Elsewhere (2026-10-12)

The owner selected **version 2**, the weathered mountain village, and explicitly
requested P22-T06, authorizing progress past the P22-T05 art checkpoint.
Project 22 and [Decision 08](decisions/08-elsewhere-village-world.md) govern
current world work; Project 21 below is historical.
**P22-T01 through P22-T06 are complete. P22-T07 is unstarted and unauthorized.**

## P22-T06 verified (2026-10-12, from `a13b671`)

A new continuous outdoor trial launches real Weston Terminal and Vim through
Applications search, moves/rotates a panel, walks 12.291m down the south approach
and back, and reactivates both original instances. The shell retains its PID
and variable; Vim retains its unsaved buffer; background terminal pixels and
24 frame revisions advance. Placement, rotation, identities, focus, client-owned
close and shutdown checks pass. No production runtime, world art or native
architecture change was needed.

Verified by automated checks: Godot import/default startup and bridge build;
headless/GPU outdoor checks; the new outdoor multi-client trial; seven existing
graphical interaction regressions; eight Python and 62 Node tests. Chrome's
first two trials reproduced a historical missing-first-character failure.
Tracing found element autofocus could report ready without document focus.
The fixture now waits for both, retaining exact first-try typing and all other
assertions. Two subsequent Chrome trials pass. This fixes an observed test
readiness gap; comprehensive browser compatibility is not claimed.

Agent-observed: eight final Terminal/Vim/world renders and three final Chrome
renders inspected; the failed browser render is retained separately. Named
apps, actual outputs, commands, failure diagnosis and limits are in
[the evidence](evidence/p22-t06/README.md) and
[handoff 46](handoffs/46-village-applications.md). The selected art and both
comparison checkpoints are preserved. Human comfort, latency, final owner art
review and Project 22 acceptance remain unobserved; no restart persistence.

Next task: **stop after P22-T06**. P22-T07 requires its own explicit request;
no pavilion workspace, later task or unattended continuation was begun.

## P22-T05 verified (2026-10-11, from `82dd2a2`)

The selected version 2 now uses three curated Poly Haven material sets for
cobbles, plaster and timber, with tracked maps/import settings, source/license
metadata and offline integrity verification. Grain follows beams; carved stone
finishes unify the fountain and access surfaces. Fuller, varied leaf clusters
and adjusted daylight/fill preserve the weathered palette. Desktop ownership,
input, client shading, exposure and world collision geometry are preserved.

Verified by automated checks: Godot import/default startup; headless/GPU
architecture, landscape and outdoor trials; seven graphical interaction trials;
real Chrome; 11 Python tests (including material integrity failures) and 62 Node
tests. Final graphical architecture/outdoor/color/Chrome checks were refreshed
after correcting shadow striping. Model hashes, non-tree vertex preservation,
provenance, task parsing, documentation links and diff checks pass.

Agent-observed: twelve final actual Godot world captures plus terminal/browser
captures inspected. Multiple before/after views record fixes for repetitive
paving, noisy plaster, flat leaf layers, glare, distant aliasing and shadow
striping. [Render comparison/evidence](evidence/p22-t05/README.md) and
[handoff 45](handoffs/45-village-materials.md) record scope, commands and limits.
Both earlier reference checkpoints and their comparison remain unchanged.

Owner-observed: the owner's explicit version 2 selection in the 2026-10-11
request. Not observed by a person: approval of these P22-T05 refinements or
movement comfort. No performance benchmark; simple lawn/boundary, large stylized
leaves, repetitive large paved areas and decorative water remain limitations.

Checkpoint at that date: stop for owner art review and explicit authorization
before P22-T06. The subsequent 2026-10-12 request is recorded above; this earlier
result itself did not authorize continuation.

## Reference 2 comparison candidate verified (2026-10-11, from `340ca97`)

The owner supplied a second reference and requested a reversible alternative.
The default now uses weathered timber/stone, ivy, pointed slate turret, tiered
stone fountain, cobbles and a mountain/cloud backdrop. The first direction is
preserved at `340ca97` / local tag `art-reference-1`; its source renders remain
unchanged. [Compare nine matching views](art-direction/compare.html), or read
[switching instructions and evidence](handoffs/44-village-reference-2.md).

Verified by automated checks: Godot import/default startup; headless/GPU
architecture, landscape and outdoor tests; seven existing interaction trials;
real Chrome; eight Python and 62 Node tests; comparison-page browser checks.
Model rebuild hashes, documentation links, task parsing and diff checks pass.
The reference-1 source image, evidence and handoff remain byte-identical.
Version 2 is preserved at local tag `art-reference-2` after its separate commit.

Agent-observed: nine actual final Godot renders inspected after correcting
bright faceted mountains, a ringed spire, gridded ivy and hard snow patches.
The page's browser checks pass for all paired images, viewpoint selection,
slider and version buttons. No final owner choice or art approval is recorded.
Simple broad terrain, sparse frontage, procedural material repetition and
stylized water/mountains remain limitations against the reference's detail.

Next task: stop after this bounded comparison revision. No numbered task or
later gate is advanced; P22-T05 remains unchecked and requires a separate request.

## Reference 1 checkpoint: owner reference alignment verified (2026-10-11, from `e32c9dc`)

At this checkpoint, the [art brief](ART-DIRECTION.md) used the owner's
[courtyard reference](art-direction/village-square-example.jpg). The existing
buildings now frame the square more closely, with curved blue slate roofs,
dormers, warm timber and pale plaster, lattice windows, flower boxes and an
awning. A lower planted fountain, fixed trees, timber arch link and pale
patterned paving bring the scene toward that direction. Original reproducible
models/shaders preserve the existing terrain, player and desktop ownership.

Verified by automated checks: Godot import/default startup; headless/GPU
architecture, landscape and outdoor trials; seven existing graphical interaction
regressions; real Chrome; eight Python and 62 Node tests. Model regeneration
is byte-identical; documentation links, task parsing and diff checks pass.

Agent-observed: nine final actual Godot renders were inspected after correcting
sparse foliage, blue foundations and an undetailed hip roof. Compare
[before](evidence/p22-t04/arrival.png) / [after](evidence/village-reference/arrival.png).
The outer lawn/bank, simple tree silhouettes and regular paving remain
provisional; the reference's finished density/quality is not claimed.
See [handoff 43](handoffs/43-village-reference-alignment.md) for scope, evidence,
commands and verification results. Not observed by a person: art approval or
movement comfort. No performance benchmark or later task acceptance is claimed.

Next task: no continuation authorized. Stop after this owner-requested revision;
P22-T05 requires a separate request and owner review remains outstanding.

## P22-T04 verified (2026-10-10, from `e81c88c`)

A compass fountain marks the square, with a timber lodge, stepped-gable
guildhall with a decorative clock, low stone workshop and open timber pavilion. Five
original GLB models include roofs, joinery, windows on all elevations, door
surrounds and architectural profiles. Foundations/steps fit the terrain;
a north ramp gives ordinary walking access to the pavilion's covered floor.
The three buildings are sealed exteriors. Models, import settings, reproducible
source and provenance are tracked. No new dependency or desktop service change.

Verified by automated checks: Godot import/default startup; headless/GPU
architecture collision and pavilion access; complete landscape route/ground
checks; unchanged outdoor startup/live-terminal checks; seven existing Godot
interaction trials; real Chrome; eight Python and 62 parser/plugin tests.
Model rebuild hashes, documentation links, task parsing and diff checks pass.

Agent-observed: nine actual eye-level architectural captures show distinct
silhouettes, a recognizable landmark, open routes and a covered pavilion.
Reviewed default-startup, terminal, terrain-supported panel and browser captures
preserve readable real application content. See
[handoff 42](handoffs/42-village-architecture.md) for defects/fixes, commands,
images and limits. Not observed by a person: movement comfort or art approval.
Plain base materials and bright sunlit stone remain provisional. Material,
foliage and lighting curation (P22-T05) was unstarted at this checkpoint;
work surfaces/anchors remain P22-T07. No later acceptance gate is claimed.

## P22-T03 verified (2026-10-10, from `eca98ab`)

The default is now an approximately 84m authored site: a level 24 × 20m paved
square, four 4m-wide approaches, gently varied ground, and a continuous visible
ten-section boundary bank. Fixed heights and paths define the geography.
The scene reuses the existing controller and DesktopRuntime. Application
placement follows the expanded boundary and terrain; startup remains empty.
No native/runtime/input policy changed. The historical study remains intact.

Verified by automated checks: Godot import/default startup; headless and
rendered terrain checks (24,178 ground samples, 337.8m walked per mode, maximum
sampled grade 14.39°, floor gap below 6mm); all ten boundary sections and corner
containment; real terminal launch/drag/rotation/cancel/input/return, including
landing on the western slope. Seven affected existing Godot regressions,
the isolated real Chrome trial, eight Python tests and 62 parser/plugin tests
pass. No fresh native Meson or full historical 21-trial suite result is claimed
for this scene-only change.

Agent-observed actual GPU renders show arrival and all four approaches,
continuous ground/path joins, the enclosing bank, readable native terminal
output and a live panel on the raised terrain. See
[handoff 41](handoffs/41-village-landscape.md) for commands, captures, initial
failures, fixes and exact limits. Not verified by a person: movement comfort.
Materials and the simple bank remain provisional. Buildings, foliage, art
acceptance and comprehensive application integration retain their later tasks.

## P22-T02 revalidation (2026-10-10, from `86db629`)

The owner disabled startup terminal launch after the original implementation.
That also disabled DesktopRuntime initialization; a fresh outdoor check failed
on null application services. Runtime initialization is restored with a separate
`auto_start_terminal` setting, false outdoors. Startup stays empty, with the
compositor and Applications launcher ready. `--terminal` / `--terminal-demo`
explicitly request a client; `--no-terminal` retains the geometry-only path.
The first manually launched browser keeps its correct launcher identity.

Fresh automated checks pass: Godot import/default startup, headless and graphical
outdoor trials (including idle beyond the watchdog, manual terminal launch,
movement/jump/collision, panel drag/rotation/cancel, typing/return and shutdown),
explicit startup flag runs, all 21 existing Godot regressions, eight Python
catalog/launcher tests, 62 parser/plugin tests, and the isolated real Chrome
trial. A concurrent Chrome attempt lost the first typed character; the unchanged
isolated recheck passed. That intermittent failure remains documented, not
claimed fixed. Actual new GPU renders were inspected by the agent: empty arrival, readable requested terminal output,
and the live panel after world return. See [handoff 40](handoffs/40-outdoor-startup.md)
for commands, original failure and fresh evidence. Human comfort, village art,
and the comprehensive P22-T06 integration gate remain unaccepted.

## Original P22-T02 verification (2026-10-10)

From `7d74847`, the default is a minimal outdoor startup: flat ground, visible
solid boundaries, safe spawn, sky and sunlight. It reuses DesktopRuntime and
the existing controller, including the owner's jump. Home uses scene-authored
spawn coordinates; the old study is preserved unchanged as `scenes/study.tscn`.
Study-specific tests select that retained scene deliberately; general desktop
checks exercise the outdoor default. See [handoff 40](handoffs/40-outdoor-startup.md).

Verified by automated checks: import/default startup, explicit no-terminal
startup, headless and graphical outdoor movement/jump/collision/live-client
trials, all 21 existing Godot regressions, real Chrome, 8 Python tests and 62
plugin/parser tests. An initial Chrome test readiness race was addressed by
waiting for its page's loaded/focused input; existing assertions remain intact.
No native source changed, and no new native regression-suite run is claimed.

Agent-observed actual renders show the outdoor arrival, walkable ground and
boundaries, native terminal output, selected text and real Chrome content/world
return. Not verified by a person: physical-input feel or comfort. This is the
minimal startup acceptance only; village art and P22-T06's comprehensive outdoor
application integration remained unimplemented/unaccepted. P22-T03 was unstarted
at that checkpoint.

## P22-T01 verified (2026-10-09)

From `fd36f01`, the scene's DesktopRuntime node now composes and owns the
existing desktop services and shutdown policy. The study supplies its player,
screen/status nodes and unchanged placement limits; application objects no
longer import hallway geometry. The active study, controls, native compositor,
launcher and identity semantics remain intact. See
[handoff 39](handoffs/39-desktop-runtime-extraction.md) for the dependency audit,
before/after commands, logs, rendered evidence and remaining boundaries.

Automated: Godot import/default startup, all 21 Godot trials (including two
real-client sessions without study construction), real Chrome interaction,
34 Meson tests, 8 Python tests and 62 plugin/parser tests passed. The unchanged
native binding suite also passed in the pre-extraction baseline.
Agent-observed: before/after GPU captures preserve the study and rotated live
panels; terminal typing/selection and Chrome content are readable in the reviewed
views. Human physical-input feel/comfort is not newly observed or claimed.

Retain Godot rendering, the C++ compositor/GDExtension, movement, input,
launcher, application objects, and existing session-local placement behavior.
Do not claim restart persistence. P21-T67 already completed and verified the
technical rename; retain the `elsewhere` commands, identifiers and paths recorded
below. New place-specific geometry must not own the desktop runtime.

---

# Project status

The project is now **elsewhere**, hosted at
[christafford/elsewhere](https://github.com/christafford/elsewhere).
The owner-requested P21-T67 rename covers maintained text, identifiers and paths;
see [handoff 38](handoffs/38-elsewhere-rename.md). The native binary is
`build/elsewhere`, and environment overrides use `ELSEWHERE_`.

Current authority: basic Chrome and surface-tree T65–T66 verified 2026-10-09
from `2cdfd15`. Grand foyer T64 verified 2026-10-09 from `817aff3`;
merged exploration wings T63 verified 2026-10-09 from `95ea216`. Longer rooms
and movable furnishings T62 were verified
2026-10-08–09 from `58d2be5`. Exploration rooms T61 were verified 2026-10-08
from `e1deea6`. Hallway T60 was verified 2026-10-08 from `139214d`.
Furnishings, walls, instances and transitions T56–T59 were verified
2026-10-06, starting from `e618487`.
Previous authority: owner-requested room details and physics T53–T55 verified
2026-10-06, starting from `35d6b3d`. Application rotation T52 verified 2026-10-05
from `cabde04`, following navigation/carrying T51; recovery begun 2026-10-03;
T44 and navigation/launcher T46–T48 verified 2026-10-04; owner-requested application objects T49 verified 2026-10-05,
starting from `4c0c078` plus the existing
uncommitted overnight work. [Decision 06](decisions/06-godot-poly-haven.md) remains
the direction. [Previous status](handoffs/15-status-before-frontend-recovery.md)
is historical; its extension/visual completion claims were contradicted by tests.

## Historical Project 21 continuation (not the current queue)

The owner's initial graphical-application work passes bounded T65–T66: real
Chrome starts, types, clicks, scrolls, resizes, returns to its room panel and opens
multiple windows. See [handoff 37](handoffs/37-graphical-applications.md). This is
not general application compatibility. The next browser compatibility work is
`xdg_popup` menus and clipboard; both remain unimplemented, and popup requests
can still disconnect a client. The unrelated roadmap task remains below.

**P21-T45: finish targeted client close and its lifecycle acceptance.**
Recovery T36–T44 passes its bounded acceptance: furnished study, retained
compositor, live output, typing, selection/scroll and actual client resize.
See [tasks](TASKS.md) and [resize handoff](handoffs/23-godot-terminal-resize.md).
The independent panel rotation follow-up is recorded in
[handoff 29](handoffs/29-godot-application-rotation.md).
The owner's navigation and application-carrying controls are recorded in
[handoff 28](handoffs/28-godot-natural-navigation.md); they supersede the earlier
[handoff 24](handoffs/24-godot-navigation.md) controls and do not complete T45.
The requested application wheel/search and explicit terminal relaunch now pass
T48; see [handoff 25](handoffs/25-application-launcher.md). Reuse that launcher.
The owner-requested movable live application panels are recorded in
[handoff 26](handoffs/26-application-objects.md). This bounded request does not
start a broader roadmap run. Next send targeted xdg close requests without using
process termination as a window-close implementation. Cursor images, clipboard
and popup menus remain unsupported; carry these into concrete follow-up tasks.
Broader T00–T19 gates remain unchecked until their full evidence exists.

## Run the current outdoor frontend

```sh
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy
```

The default is the authored landscape and square with no application open.
Tab opens Applications; `-- --terminal` explicitly starts a terminal. No study assets are
needed for it.
See [current controls and checks](../world/README.md). The following retained
study instructions and detailed Project 21 evidence describe the old world.

## Run the retained study explicitly

```sh
python3 world/tools/prepare_study_assets.py
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy res://scenes/study.tscn
```

Uses the existing local engine and downloaded source cache. Missing/corrupt model
dependencies fail explicitly. Fresh-machine bootstrap remains unfinished.
`tools/run-godot.sh --editor` opens the editor. The study requires the explicit
scene argument above; the default runs outdoors.
The launcher builds/stages the standard native extension and starts installed
`/usr/bin/weston-terminal` with `/bin/sh`. For a changing clock/counter, use
`tools/run-godot.sh --audio-driver Dummy -- --terminal-demo`.
The launcher now defaults to SDL's classic Linux joystick path to avoid the
reported pre-render startup crash. Explicit `SDL_JOYSTICK_LINUX_CLASSIC` overrides
are preserved; see [startup evidence](handoffs/27-godot-startup.md). This is a
tested workaround for the bundled engine, not an upstream engine repair.
`build/elsewhere --room-camera` still uses the separate legacy renderer.

WASD walks relative to your heading; A/D always strafe. Hold right mouse to
look (mouse right turns right, mouse up looks up); release to free the pointer.
Your view stays where you aimed, with no automatic return. Shift moves faster;
hold Ctrl or toggle M for slow walking. Slow mode takes priority over Shift.
Escape stops movement and frees the pointer; Home stops and resets to arrival.
Enter activates the terminal. Ctrl+Alt+Escape returns to the room. Application
mode uses physical US keys and native-size text when it fits; ordinary Escape,
Tab, Home and camera keys reach the terminal. Host focus loss returns to world
mode. Left-drag selects text and the wheel scrolls terminal history. Type `exit`
to close the shell; use the application wheel to relaunch. In application mode,
resize the host window to resize the actual terminal and its rows/columns.

Tab in world mode (or the Applications button) opens eight recent-app slots.
Newest is at twelve o'clock, then clockwise; unused slots stay empty. Click the
center to search installed application names/keywords with their icons. Enter,
double-click or Launch starts a new instance, including selections in recents.
Double-click an existing room panel to use that particular instance. Esc returns from search to the wheel, then to the room.
Tab still belongs to applications in application mode. Recents persist in
`.tools/launcher-state/recent.json`; tests use an isolated state directory.
Chrome launched through Applications uses native Wayland/software rendering and
a separate browser profile under `.tools/browser-profiles`; restart Elsewhere to
load the new native runtime. Browser menus using `xdg_popup` and clipboard are
not yet supported. Failed launches show a diagnostic log path under the current
launcher session directory instead of guessing which protocol is missing.
Every mapped window also has a separate live panel in the room. Single-click
selects it; double-click activates it with a quick 220ms zoom toward the camera.
Ctrl+Alt+Escape reverses the animation to its current room placement. Your
position stays unchanged. Typing starts immediately; pointer input starts when
the image settles. Left-drag moves the panel. Keep holding
left mouse to carry it while using WASD and right-mouse look; dropping it does
not interrupt held walking keys. Wheel up pushes it farther away, wheel down
brings it nearer. While both mouse buttons are held, wheel up turns the panel
left and wheel down turns it right (10° per notch), keeping its center/depth
and your view unchanged. Release right mouse to adjust depth again. Escape
restores both the original position and orientation and stops navigation.
After a move, releasing the panel lets it fall upright onto furniture or the
floor. Holding it pauses gravity; Escape restores its previous placement and
falling state. Moving the supporting chair away lets it fall again. A single
click or opening an untouched application does not drop it. Settled panels
retain their positions when returning with Ctrl+Alt+Escape, and background
applications keep updating. The chair, potted plant and bookcase use the same left-drag, wheel and
carrying controls. Walking into them pushes them across the floor; they stay
upright and come to rest. The study desk and its accessories remain fixed. Placement lasts for this session; closing
a client removes its panel. Restart restoration is not implemented.

Discovery uses freedesktop entries and icon themes without a KDE service.
Verified clients are Weston terminal and Vim through Terminal=true. Other
graphical apps may fail; Flatpak launch is explicitly unavailable for now.

Turn away from the desk to enter the hallway. The study doorway has no door.
Two room doors remain on the left, one on the right, and one at the far end.
The former first left and second right entrances are sealed. Remaining doors
swing open as you approach and stay open for the session.
The surviving middle-left doorway leads into the combined library/winter garden;
the first right doorway leads into the combined atlas/cabinet gallery. Both wings
are 7.8m wide. The inventor's room stays separate at the last left doorway, with
the grand foyer at the end. The foyer measures 20 × 24m beneath a 13m stone
vault, with a central 40-riser spiral stair leading to a gallery at 5.6m. Walk
the stair with ordinary controls, including while carrying an application.
Both levels have usable placement space; tables and plants remain movable.
Carry applications through the doorways
and release them onto tables or floors; launch new instances where you are
working. Instances elsewhere retain their locations for this session.
Rooms 01–04 are twice as deep (12.8m); room 05 retains its size. The library has
black antique bookcases with warm wood interiors
and a reading table with a green banker lamp. Common furnishings throughout
the elsewhere use the same drag/carry/rotate/push controls: bookcases, chairs,
plants, worktables, cabinets, instruments, display stands and parts bins.
Books, ornaments, table lamps and sculptures move with their furniture.
Moving a supporting table away lets an application fall and remain usable.
Fixed architecture and mounted decorations stay fixed. Restart restoration
remains unimplemented.

## Verified by automated checks in this recovery

- T67 (2026-10-09, from `9c2de0c`): project rename to elsewhere. Fresh Meson
  build and 34 tests, native/Godot binding suite, clean Godot import/runtime,
  20 study trials, real Chrome check, 8 Python tests and 62 plugin/parser tests
  pass under the new names. Maintained text and filenames have no old-name
  references; UIDs are preserved. See [handoff 38](handoffs/38-elsewhere-rename.md).

- T65–T66 (2026-10-09, from `2cdfd15`): real Google Chrome 154.0.8037.57 through
  the installed desktop entry; omnibox subsurface, local page navigation, trusted
  typing/click, wheel scroll both ways, configure/ack/commit resize with DOM reflow,
  room return, two independent panels and browser-initiated close of one window.
  Native output v1/v2/v3 and surface-tree fixtures, 34 Meson tests, standard
  binding suite, 20 graphical/headless Godot study trials, 8 Python tests and
  62 plugin/parser tests passed. Surface-tree and runtime lifecycle checks also
  passed ASan/UBSan with leak detection. Agent-inspected GPU captures and exact
  scope/commands are in [handoff 37](handoffs/37-graphical-applications.md).

- T64 (2026-10-09, from `817aff3`): foyer entry, actual 40-riser ascent carrying
  a live terminal, descent, inner/outer stair guards and gallery guard,
  upper-floor landing/typing/return, real tread support and ground-floor table
  use pass. Import/runtime, 20 Godot trials and 7 Python tests pass; five affected
  trials pass again after final lighting tuning. Four GPU views inspected and
  profiled. Occlusion, shared balusters and distance-faded local lights reduce
  hidden rendering work; detailed evidence and limits are in handoff 36.

- T63 (2026-10-09, from `95ea216`): four remaining door routes, two sealed
  entrances, twelve actual walking/live-panel crossings of removed partitions,
  continuous floors, typing, eight furniture categories and four gravity support
  regressions pass. Godot import/runtime passes; two GPU wing views inspected.
  Stable zone IDs remain separate from physical room boundaries. See handoff 35.

- T62 (2026-10-08–09, from `58d2be5`): four doubled room depths, antique library,
  eight furniture categories with drag/rotate/cancel/drop/walking-push behavior,
  scaled pot collision, carried contents, extended-room live application routes,
  moving-table support removal and subsequent shell typing pass. Import/runtime,
  18 Godot trials and 7 Python tests pass across bounded runs. The transition
  trial's client-close assertion failed once and passed unchanged on standalone
  recheck; this is recorded, not claimed resolved. Eight GPU captures inspected.
  Mesh batching preserves details/shadows and restores roughly 60 FPS median in
  the sampled room views. See handoff 34 for percentiles and limits.

- T61 (2026-10-08, from `e1deea6`): six approach-opening doors and furnished
  rooms; actual walking/carrying in/out, solid boundaries, floor/support/table
  landing, independent live terminals and shell input in two locations pass.
  Import/runtime, 17 Godot trials and 7 Python tests pass across bounded runs.
  The full script's launcher hit its 45-second limit; standalone passed in 46s.
  Agent inspected ten GPU captures; six fixed views measured median 16.66–16.68ms
  and p95 16.84–17.09ms at a 60 FPS cap. This is not a human/latency gate.
  See handoff 33. Furnishings were fixed at T61; T62 supersedes that behavior.
  Placements remain session-local.

- T60 (2026-10-08, from `139214d`): doorway traversal both ways, six closed
  doors and hallway walls, carried live terminal landing/activation, rotated
  placement bounds; five fixed GPU views inspected. Import, all 16 Godot study
  trials and 7 Python tests passed across host and isolated GPU Weston runs.
  Host launcher attempts lost focus; isolated launcher/application trials passed
  without changing product policy. See handoff 32 for exact logs and limits.

- T56–T59 (2026-10-06): chair/plant/bookcase picking, carrying, rotation, release,
  cancellation and walking pushes; real independent terminal instances and
  isolated shell state; live 220ms entry/return, endpoints, native pixels,
  interruption/focus/resize/close. Import, 15 Godot trials and 7 Python tests
  pass from `c60d037` plus T59. Walnut and transition GPU captures inspected by
  the agent; see handoff 31. Human comfort remains unobserved.

- T55 (2026-10-06): real application panels fall onto floor, desk, bookcase and
  chair, including edge contact; moving support away resumes falling. Re-grab,
  cancellation, live updates and close pass. Import, all 13 Godot study trials
  and 7 Python tests pass (host input; isolated GPU resize). Agent-inspected
  landing captures are in handoff 30; owner comfort remains unobserved.

- T54 (2026-10-05): walking pushes the chair, friction/damping stop it, and
  desk/wall/floor collision and upright constraints pass. Import and expanded
  graphical controller trial pass. See handoff 30.

- T53 (2026-10-05): fluorescent downlights, bounded subtle flicker, original
  botanical prints, clock and noticeboard. Import, rendered shadow comparison
  and client RGB test pass; fixed GPU views inspected by the agent. See handoff 30.

- T52 (2026-10-05): both buttons + wheel rotates only the held panel, preserving
  camera/center/depth and other clients. Fractional steps, switching back to
  depth, retained orientation, full-transform cancellation, blocked rotations,
  live Terminal/Vim interaction and the full study suite pass. An inspected
  1280×800 capture shows the rotated terminal and updated hint. Mouse-capture
  release no longer ends the drag early. See handoff 29; physical feel remains
  owner-unobserved for this change.

- T51 (2026-10-05): consistent WASD strafing, normal mouse-look without camera
  return, slow/fast speeds, diagonal normalization, level walking while pitched,
  collision, GUI release and focus cleanup pass. Real Terminal/Vim tests pass
  walking/turning while carrying, continued movement after dropping, both wheel
  directions and fractional steps, cancellation, bounds and input isolation.
  Import and the full study suite pass using host input and isolated GPU-rendered
  four-size resize. Updated controls/panels were inspected in a 1280×800 capture.
  Physical mouse feel and owner comfort remain unobserved; see handoff 28.

- T50 (2026-10-05): supplied crash addresses matched SDL's evdev joystick sort;
  GDB confirms the launcher's classic-backend default avoids that branch.
  Five graphical starts, headless startup, real Terminal/Vim object interaction,
  and launcher environment/argv tests pass. Exact intermittent trigger remains
  unproven. The earlier `bssh` GTK-seat warnings remain a separate unverified
  client compatibility issue.
- T49 (2026-10-05): real Terminal and Vim coexist with independent live textures,
  entity IDs and placements. Injected drag/wheel, targeted double-click typing,
  cancellation, occlusion, room bounds and client-exit cleanup pass. GPU captures
  inspected; import, existing color/output/keyboard/pointer/launcher checks pass.
  Four-size resize plus world-panel pixel dimensions/aspect pass in an isolated
  GPU-rendered Weston virtual desktop. At that trial the host was portrait
  800×1280, so its width clamp prevented the 900–1280px resize test from passing.
- Historical T49 full-suite limitation: the then-current controller failed
  `Pitch return fights mouse after re-grabbing`. T51 removes camera-return
  behavior at the owner's request, replaces those expectations with persistent
  view regressions, and passes the full suite. Original evidence stays in
  [handoff 26](handoffs/26-application-objects.md).

- Six glTF packages staged with their manifest-checked buffer/texture dependencies.
- Godot import and runtime pass; validator rejects an invalid-script fixture.
- Graphical scene smoke: 56 textured surfaces, walking/key release, wall
  collision, focus cleanup, mouse capture/look/release and Home assertions pass.
  These are injected controller events, not a physical-input or human trial.
- Navigation T46 (2026-10-04): reversed left/right look, upward/downward pitch
  return, preserved yaw/held movement, interrupted return and Home reset pass in
  the graphical controller test. Physical mouse feel remains owner-unobserved.
- T47 navigation rechecked during T48: A/D turn by default and both strafe with
  right mouse held. The in-world help now describes these controls accurately.
- T48 launcher: six Python metadata/Exec/environment tests, actual center-click
  and typed search, camera/input isolation, cancel, eight-slot ordering,
  deduplicated persistent history, real Vim launch/typing, recent-window switch,
  terminal exit/relaunch with a shell-written marker and owned child cleanup pass.
  The complete Godot study suite passes in this session. Eight-entry visual
  history is a labeled layout fixture; only Terminal/Vim launch compatibility is
  claimed. See [launcher evidence](evidence/application-launcher/).
- Standard C++ binding: fresh import and three clean runtime processes, 300
  native instances/calls/releases. Separate build uses consistent generated headers.
- Real Wayland window protocols: sixteen standalone and sixteen Godot trials.
  Initial configure/ack/buffer commit, seat v1/v4 capabilities, parsable keymap,
  version-correct events/releases, partial destruction, disconnect, server stop
  and five invalid request sequences pass. Godot frames advance; resources,
  socket and private directory are cleaned up.
- Owned frame transport: 32 standalone + 32 Godot pixel/state barriers across
  repeated sessions. Exact RGBA/alpha/padding, buffer reuse/destruction, pending
  state, detach/remap, scale/transform metadata, callbacks and handle invalidation
  pass. Six malformed/unsupported buffer/state cases are rejected in each harness.
  These checks alone do not establish rendered usability.
- Live output: two real Weston terminal sessions, changing pixels/revisions,
  aspect ratio, unchanged-frame skip, disconnect clearing, child/socket cleanup
  and unchanged host display environment pass. Eight inverse image transforms
  and eleven GPU color patches under strong colored lighting pass.
- Keyboard protocol: focused delivery to two independent clients, same-client
  focus switches, US key/modifier values, duplicate suppression, held/locked
  state reset, late binding, detach, destruction and stale handles pass.
- Real shell input via injected Godot events: mixed case/punctuation, Backspace,
  Ctrl+U, client repeat, Ctrl+C interrupt, mode transitions, resumed world
  movement, host-focus-loss notification and shell exit pass. Flat view preserves
  7,571 sampled opaque client pixels at native size. These are agent-run trials.
- Pointer protocol: client isolation, fractional coordinates, button/axis values,
  implicit grabs, duplicate suppression, outside drag, late binding, reset,
  detach, destruction, disconnect and stale handles pass. 302 Godot assertions
  cover drawn-rectangle mapping, scale/rotation, corners/margins and buttons.
- Real Weston pointer trial via injected Godot events: text selection, release
  outside the image, scrollback up/down, held-button mode exit, world control
  recovery, focus-loss notification and disconnect pass. Captures were inspected;
  physical mouse/touchpad input and latency are not inferred.
- Resize protocol (T44, 2026-10-04): configure/ack/commit separation, retained
  snapshots during delay/decline, min/max limits, committed geometry, client-chosen
  sizes, serial validation, bounded pending requests and destruction pass.
  Native resize AddressSanitizer + UBSan + leak detection also pass.
- Real Weston resize: four host sizes (1000×700, 1200×780, 900×620, 1280×800)
  change character grids to 77×22, 95×25, 68×18, 103×26. Typing/selection continue,
  8,573 sampled opaque pixels match native-size GPU views, and the world preview
  updates. These are agent-injected window/input checks, not physical drag-resize.
- Standalone pointer runtime AddressSanitizer + UBSan + enabled leak detection
  pass in T43.
- Standalone keyboard runtime AddressSanitizer + UBSan + enabled leak detection
  pass in T42; frame ownership sanitizer checks passed in T40.
- C++ build and 33/33 Meson tests pass; 62/62 Node plugin tests passed during T39.
  The Meson/plugin checks alone do not validate the Godot integration.
- The local editor's first-import shutdown race has a tested paced-startup
  workaround, not an engine fix; see [TOOLCHAIN.md](TOOLCHAIN.md).

## Agent-observed visuals

[Three rendered views](evidence/godot-recovery/) show real desk, chair, lamp,
plant, books and shelving, room textures, daylight/shadows and the earlier inactive
monitor preview. Captures were inspected, including correction of the initially
backward desk/chair. Compatibility/OpenGL on AMD Custom GPU 0405.
This passes visible frontend recovery, not final art acceptance.

[Live terminal captures](evidence/live-terminal/) now show real Weston 15.0.1
output on the monitor, upright text, changing UTC clock/counter and clearing on
disconnect. Agent inspection: 2026-10-03, Godot 4.7.2, Mesa 26.2.4, 1280×800.
Room and close-up GPU views were inspected; `client-frame.png` is a source frame,
not a render. This is output acceptance, not typing or human readability acceptance.

[Application-mode evidence](evidence/terminal-input/) shows real command results
and return to the room after shell exit. Agent inspection, 2026-10-03, same
engine/renderer/hardware as above. Text is upright and comfortably sized in this
capture; no human, physical-keyboard or latency acceptance is inferred.

[Pointer evidence](evidence/terminal-pointer/) shows a highlighted real output
line, earlier/later scrollback and return to the live study. Agent inspection,
2026-10-03, same engine/renderer/hardware. This is selection/scroll acceptance;
it does not establish clipboard transfer or popup-menu support.

[Resize evidence](evidence/terminal-resize/) shows four real terminal sizes,
matching selections and the updated world monitor. Agent inspection, 2026-10-04,
same renderer/hardware, at the recorded host viewport sizes. Text remains upright
and at native size. Physical host resizing and human comfort remain unobserved.

## Verified by a person

Historical owner confirmation on 2026-10-02: legacy launch, input and vertical
orientation fixes worked. Owner response on 2026-10-03 to the recovered view: “finally! that looks great.”
This records approval of its appearance, not a terminal/input/comfort trial.

## Not verified / unfinished

- Compositor close requests. In-app terminal relaunch now passes T48. Keyboard,
  selection/scroll, resize and ordinary shell exit pass; full terminal
  usability and physical input are not verified. IME/composed text and selectable
  layouts are not implemented; the current seat/mapping is US.
- General graphical-app launch compatibility and durable/multiwindow assignment.
  Weston editor failed because text-input-manager is absent. The launcher records
  an app only after mapped content; a catalog entry is not a compatibility claim.
  Flatpak handoff and D-Bus activation remain unsupported. Third-party single-
  instance IPC may reuse a host instance; private display variables are not a
  process sandbox. The verified Terminal/Vim paths create owned private clients;
  Chrome uses a separate Elsewhere profile and the browser sandbox stays enabled.
  Concurrent Elsewhere frontends need separate browser profile roots.
- Client cursor images, clipboard/primary selection and popup menus. The host
  cursor remains visible; highlighting does not implement copy/paste. A right-click
  menu request can disconnect the client because xdg_popup remains unsupported.
- Original addon initialization: reproduced segmentation fault; isolated with
  `world/addons/elsewhere_godot/.gdignore`, source and binary preserved.
- Full renderer-independent compositor extraction: socket/wl_compositor/shm
  lifecycle, initial xdg-shell/seat checks and owned shm snapshots pass. Broader
  protocol conformance and popup presentation remain open; bounded subsurface
  composition and input now pass T66.
- Finished art rubric, furniture selection/cohesion, performance, physical host
  input and human comfort. No blank capture counts as visual acceptance.
- Fresh-clone dependency provenance and asset fetching/offline negative checks.

The earlier recovery preserved overnight edits and saved this local backup:
`.tools/recovery/20261003T185319Z/`. Never sweep them into a recovery commit.
