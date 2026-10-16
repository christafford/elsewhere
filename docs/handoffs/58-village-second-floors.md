# P22-T12 — stairs and usable second floors

2026-10-16, from `9ba86aa`, under the owner's explicit authorization of
[scope 57](57-village-upstairs-plan.md) and the
[Decision 08 amendment](../decisions/08-elsewhere-village-world.md).
P22-T12 is verified. P22-T09 and human P22-T10 remain unchecked.

## Implementation

Lodge, Guildhall, Copper Kettle, Lantern Inn, Village Library and Meadow Inn now
have internal timber stairs to usable second floors. The thirteen-building
layout, seven lower buildings, entrances, roof silhouettes and original desktop
runtime remain. One tree moves four metres north to clear Lantern Inn's upper room. Only one upper floor is opened per selected building; higher
Guildhall/turret spaces, exterior balconies and windows remain decorative.

The existing solid upper volumes become hollow plaster shells under finished
wood roof undersides. Guildhall has a closed second-floor ceiling. Ceiling slabs
and beams are cut around actual stair openings. Each straight flight rises 3.32m
over 4.6m, with twenty 16.6cm rises and 23cm runs, 1.2m-wide solid treads, timber
stringers, handrails, landing guards and a continuous upstairs floor. Every room
has a pendant lamp, fixed existing-style application worktable and modest
purpose-specific artifacts: trunks/linens/seating, tavern crockery, a meeting
table/ledger, or reading furniture/bookshelves.

`upstairs.json` supplies six location IDs and geometry dimensions to Python and
Godot. `village_upper.py` adds model-level opening/shell helpers. The two existing
model generators rebuild the affected structures and four artifact layouts;
`build_village_upstairs.py` generates twelve original stair/furnishing models.
The selected ground-floor props move away from stair circulation; existing work
pads and movable stools keep their original positions and input behavior.

`village_upstairs.gd` adds the rooms after existing architecture is initialized.
Objects retain collision against actual treads. The character alone excludes
tread bodies and uses a closely fitted layer-8 walking surface; real railings,
landing guards and enclosure still collide. This follows the retained foyer's
stair precedent without loading its scene or changing `game_world.gd`. Upper
worktables reuse the existing constructor made static; no desktop service,
launcher, panel identity, lifecycle, application shader or input change.

The 22 changed/new GLBs total 136,024 triangles and 13,218,060 bytes, versus
115,524 and 11,207,892 before. Six reused worktables add 2,520 placed triangles
before LOD. All 39 rebuilt village GLBs regenerate byte-identically. No new dependency,
external asset or source cache; the nine existing CC0 texture maps remain pinned.

## Verification and iteration

The new fixture enters each building through its ordinary doorway, ascends in
ten checked segments, walks upstairs, presses against the stairwell guard,
checks 2.1m route headroom, floor/enclosure and work-pad clearance, descends slowly,
reenters and returns Home from upstairs. The graphical trial launches a real
terminal in every room, drags it onto the physical worktable, walks down/out/back
up and verifies the same panel entity/transform and shell PID/variable. It then
resumes typing and closes normally. No stair climbing, panel transform or shell
continuity is simulated.

Initial guide triangles faced the wrong direction for Godot collision; the
first stair ascent correctly failed. Winding was corrected without controller
or assertion changes. Actual initial renders exposed dormer bases entering the
new upstairs rooms; their hidden geometry is clipped above the main roof, leaving
its finished underside continuous. Copper Kettle seating was moved back to clear
its worktable, and visible pendant fixtures were added. A closer workspace view revealed a remaining flat chimney base: flues are now
trimmed to the roof slope. Lantern Inn's landing view also exposed neighboring
foliage through its wall; the tree moves from (-29,-32) to (-29,-36). The final
fixture checks its bank/lane/canopy clearance and 275 ceiling rays in both modes.
All six final room/stair/landing renders were inspected. See
[the evidence index](../evidence/p22-t12/README.md).

Full headless/GPU stair and live-terminal acceptance passed in all six buildings.
Retained architecture, landscape, outdoor, original interiors, all ten expansion
rooms, pavilion, Terminal/Vim, Firefox and six default interaction checks pass.
Both landscape modes walk 337.8m and query 24,178 ground points. Pavilion records
50 background revisions; Terminal/Vim records 22. Python passes 14 tests and Node
passes 62. The sandbox initially prevented Python socket fixtures; an approved
rerun passed. No system packages, host services or desktop session were changed.

The upstairs walking/live-app run preceded the final flue trim and tree move;
retained regressions started before the trim and finished before the move. These
last visual fixes leave stairs, floors, worktables and desktop logic unchanged.
Final import/startup/bridge build, headless/GPU roof/canopy checks, 42 fresh views,
model hashes and isolated rendering measurements follow both fixes. No full
native Meson/sanitizer rerun is claimed for this scene-only change.

Matched RTX 3080/Weston samples raise arrival draw calls from 1,455 to 2,080 and
south-return from 2,113 to 2,699. Median frame intervals stay near the 16.67ms cap;
final p95 values span 17.071–17.487ms. These short capped samples are not sustained
60fps or target-device headroom evidence. Commands, raw counters, logs and images
are preserved in the evidence index.

## Owner trial and limits

Restart Elsewhere. Enter any of the six listed buildings and follow the timber
stair along the right-hand wall. Walk upstairs and back down without jumping;
try the slow movement key on descent. Upstairs, launch an application with Tab,
return with Ctrl+Alt+Escape and drag it over the teal worktable pad. Leave the
building, climb back up, double-click the panel to resume, then close normally.
Home returns to the square. The original downstairs workspaces remain usable.

Human appearance/comfort approval, Steam Deck/sustained performance, general
application compatibility and restart restoration remain unverified. No new
people, NPC behavior, commerce, further floors or balcony access. P22-T09 and
human P22-T10 remain unchecked; stop after this task.
