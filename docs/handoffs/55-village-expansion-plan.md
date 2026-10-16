# Furnished village expansion — approved P22-T11 scope

2026-10-15, inspected baseline `5e5c416`. This is a concrete implementation scope,
not implemented work or visual acceptance. The owner's request establishes the
direction: many more buildings, the current art style, appropriate artifacts,
and no people. [AGENTS.md](../../AGENTS.md) requires the exact P22 task ID before
execution. The owner explicitly authorized [P22-T11](../TASKS.md) on 2026-10-15
after reviewing this scope. Execute this task only and stop.

## Composition

Grow from three buildings to thirteen, retaining the Lodge, Guildhall, Workshop,
fountain and pavilion. Use the existing approximately 84m playable site and its
four approaches as the circulation spine. Connect new frontages with cobbled
lanes and small courts so destinations form streets rather than isolated houses
on grass. Favor a northern book/inn quarter, western food-and-herb frontages,
eastern trade shops and a southern inn/tavern court. Exact footprints must be
resolved against terrain, existing ramps, trees, boundary clearance and actual
eye-level renders during implementation.

Keep the fountain and taller Guildhall legible as orientation landmarks. Mix
lower shop roofs with taller inns, varied frontage widths, dormers, chimneys,
porches and restrained awnings. Continue terracotta roof courses, cream plaster,
warm oak, sandy stone, fresh planting and the blue mountain backdrop. Reuse the
current licensed materials and reproducible original model pipeline.

## Ten additional destinations

Names are working art labels. Each destination needs a readable sign, a distinct
exterior and an accessible furnished ground floor with a clear central aisle.

| Destination | Character and appropriate artifacts |
| --- | --- |
| Copper Kettle tavern | Broad welcoming frontage; timber bar, casks with hoops/taps, mugs, serving jugs, dining tables and benches |
| Hearthside tavern | Lower stone-and-timber silhouette; masonry hearth, stacked firewood, communal table, crockery and bottle shelf |
| Lantern Inn | Taller gabled frontage and porch; reception counter, key rack, luggage chest, guest ledger and waiting seats |
| Meadow Inn | Balcony/dormer silhouette; reception desk, travel trunks, folded linens and a breakfast table |
| Village Library | Prominent book-quarter frontage; stocked shelves, reading tables, book stacks, lectern and lamps |
| Bookbinder & Stationer | Small shop adjoining the library quarter; book press, paper stacks, bound volumes, rolls and writing tools |
| Bakery | Warm awning and shop display; bread oven, scored loaves, flour sacks, trays and a baker's peel |
| Apothecary | Green accents and planted frontage; labeled-style jars/bottles, mortar and pestle, dried herbs and small drawers |
| General Store | Broad display windows/canopy; produce crates, sacks, scales, baskets and shelving |
| Pottery | Craft-yard character; wheel, kiln, bowls/jugs, stacked clay and drying shelves |

Artifacts are physical decorative furnishings, with collision where needed for
walking and supported application placement. Do not imply commerce, inventory,
book-reading, cooking or crafting interactions that have not been implemented.
Provide a usable table or counter surface in each destination through existing
panel placement behavior. Keep delicate props clear of those working areas.
Upper floors may remain decorative; do not introduce blocked stairs that suggest
usable rooms. No people, animals, NPC/navigation system or animation scaffolding.

## Implementation boundaries

Keep buildings, furnishings and street layout location-owned. Reuse the existing
model authoring, material mapping, mesh collision and continuous entrance-ramp
patterns. Extend the terrain's authored paving layout without changing the
controller or substituting invisible flat floors. Preserve safe Home spawn,
existing approach walks, old entrances and pavilion access. Adjust planting only
where needed to keep new facades and paths clear.

Preserve compositor ownership, launcher behavior, application/world input modes,
client shaders, panel identities and nested/headless startup. Do not add new
dependencies, persistence, teleportation, host integration or application mocks.
Document the owner-requested expansion as a dated Decision 08 amendment when
P22-T11 is authorized; older exterior-only restrictions remain historical for
their original tasks. P22-T09 and P22-T10 are separate gates.

## Acceptance work

1. Capture matched baseline views and named-host rendering counters before
   editing. Record resolution, renderer, hardware and source revision.
2. Import and run the default world with the pinned tools. Verify model
   regeneration and provenance; inspect actual runtime views of every exterior,
   entrance and interior. Fix clipping, floating props, dark interiors,
   repetitive frontages and obstructed routes found in those images.
3. Add a bounded expansion trial that walks connecting lanes and enters/exits
   all ten buildings using the existing controller. Check continuous floors,
   doorway/ceiling clearance, enclosure, boundary separation and clear work
   surfaces. Check both headless and graphical modes.
4. In the new destinations, launch a real terminal, place its panel on a usable
   surface, walk away and return, verify the same entity/transform and shell
   PID/state, resume typing and close normally. Preserve the existing pavilion,
   Terminal/Vim and Firefox integration trials and exact application colors.
5. Run affected architecture, landscape, outdoor and original-interior checks;
   compare matched rendering cost and inspect the original square again. Run
   Python and Node/parser checks, document links and diff validation. Build/test
   C++ only if native implementation changes, which is not expected.
6. Record actual evidence and any unavailable checks in STATUS, ACCEPTANCE and
   the implementation handoff. Human art/comfort acceptance and target Steam
   Deck performance remain unobserved unless separately supplied. Tick P22-T11
   only after its acceptance passes, commit only its files and stop.

This document records the approved scope, not completion evidence. Implementation
and verification status is recorded in [STATUS](../STATUS.md).
