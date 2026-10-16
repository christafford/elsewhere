# P22-T11 — furnished village expansion

2026-10-15, based on `5e5c416` and the owner's explicit P22-T11 authorization.
Scope: [approved plan](55-village-expansion-plan.md),
[Decision 08 amendment](../decisions/08-elsewhere-village-world.md).
P22-T11 verification passed; P22-T09 and human P22-T10 remain unchecked.

## Result and ownership

The location grows from three buildings to thirteen. Copper Kettle and Hearthside
are taverns; Lantern and Meadow are inns. The Library, Bookbinder, Morning Loaf
Bakery, Leaf & Root Apothecary, Earthenware Pottery and Village Store complete the
ten new destinations. Ten cobbled lane polylines connect their open entries to
the existing four approaches and to each other. The original square, fountain,
Lodge, Guildhall, Workshop, pavilion, trees, terrain heights and stone bank remain.

Each new ground floor has a continuous entrance ramp, solid floor/ceiling/walls,
warm light, finished timber/plaster or stone surfaces, a fixed application
worktable and trade-specific furnishings. Artifacts include books and a lectern,
a binding press and paper, casks and crockery, inn ledgers/key racks/trunks,
an oven and bread, herbs/jars/mortar, produce crates/scales, and pottery vessels,
kiln and wheel. Balconies, gables/hips, dormers, striped canopies, flower boxes and
signs differentiate the exteriors within the existing warm art family.

`village_expansion.gd` extends the existing location geometry helper, reusing its
mesh collision and entrance ramps. `expansion.json` supplies authored sites and
dimensions to both runtime and the standard-library model generator.
`village_lanes.gd` extends the ground's paving distance field, not its geometry.
The new root is `VillageExtension`; the original Architecture nodes and eight
movable stools are intact. Worktables reuse the existing GLB and fitted collision,
with physical support anchors and ordinary live-panel placement behavior.

No new dependency or external asset; twenty tracked, reproducible original GLBs
reuse the existing CC0 texture maps. They contain 192,672 triangles and total
18,740,208 bytes. Ten reused worktables add 4,200 placed triangles before LOD.
See [asset provenance](../../world/art/village/README.md) and
[model budgets/hashes](../evidence/p22-t11/README.md).
No compositor, launcher, client shader, input, lifecycle, identity, native-session
or persistence implementation changed. Trade furnishings are fixed decoration;
upper stories are decorative. No people, animals, commerce or crafting mechanics.

## Verification and corrections

The new headless/GPU fixture walks all ten lane polylines in both directions,
enters and exits all ten rooms through their real collision, probes floors and
enclosure, checks boundary separation and panel clearance, and returns Home.
The graphical trial launches a real terminal in each destination, establishes a
shell PID/variable, drags its panel onto the worktable, leaves and returns,
verifies entity/transform and shell continuity, types again and closes normally.
There is no fixture assignment of panel transforms or simulated application.

Actual street, entry, interior, artifact and application renders were inspected
by the agent. Initial review found books intersecting crown trim, inn signs behind
balcony rails, one-sided canopies and gables protruding through hip roofs. Those
were corrected, and lettering enlarged. The first lane run caught a lateral
approach into the Hearthside ramp's raised edge; the southern lane now joins its
centerline before the ramp. Final close inspection found exterior chimney bases
slightly entering the bakery/pottery ceilings; the flue bases were raised above
the finished ceiling, and the expansion trial repeated. No controller behavior
or assertion was relaxed.

Retained checks passed: headless/GPU architecture, landscape, outdoor startup,
the three original interiors with real terminals, pavilion placement/stool/shell
continuity, Terminal/Vim continuity, Firefox input/clipboard/reuse/close/relaunch,
and six default graphical input/color/resize/launcher/transition checks. Both
landscape modes traversed 337.8m with 24,178 ground queries; the pavilion advanced
49 background revisions and Terminal/Vim advanced 23. Original application pixels
retain their exact RGB/gray contract. These full retained suites preceded only
the final exterior-flue-base adjustment; the affected expansion trial and import
were rerun after that adjustment.

Fourteen Python tests and 62 Node/parser tests pass. Initial Python/import runs
hit sandbox socket/editor-settings restrictions; approved execution outside the
sandbox resolved them. No system packages, host services or desktop session were
changed. The normal import validator builds the bridge; no fresh complete native
Meson or sanitizer suite is claimed because no C++ implementation changed.
Chrome and retained-study source assets remain unavailable and are not counted
as passed. Complete commands, logs, images and measurement limits are in
[the evidence index](../evidence/p22-t11/README.md).

The matched RTX 3080/Weston sample raises arrival draw calls from 668 to 1,455
and south-return from 732 to 2,113. Median frame intervals remain near the 60Hz
cap, while final south-return p95 is 28.182ms versus 16.918ms before. Increased
scene cost is a material limitation; this short sample establishes neither
stable 60fps nor target-device headroom. Raw measurements and paired renders
are preserved in the evidence index.

## Owner trial and limits

Restart Elsewhere. Follow the north approach to the library/bookbinder and inns,
the west path to the bakery/apothecary, the east paths to the store/pottery, and
the southern court to Meadow Inn/Hearthside. Entrances are visibly open: walk
up the ramps without a door key. Tab launches an application; Ctrl+Alt+Escape
returns to world mode. Drag a panel above a teal worktable pad and release,
leave and return, then double-click the live panel to resume.

Human art/comfort approval, Steam Deck/sustained performance, general application
compatibility and restart restoration remain unverified. The named-host cost
comparison is a short vsync-bound sample, not the separate P22-T09 gate.
Stop after P22-T11; neither P22-T09, human P22-T10 nor any further expansion is
authorized by this work.
