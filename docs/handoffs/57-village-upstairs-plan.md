# Village stairs and usable second floors — approved P22-T12

2026-10-16, inspected baseline `9ba86aa`. The owner requests stairs to second
floors in buildings tall enough to accommodate them. This document defines the
bounded implementation for [P22-T12](../TASKS.md); it is not implementation or
visual acceptance. [AGENTS.md](../../AGENTS.md) requires an explicit P22 task ID
before execution. The owner explicitly authorized this scope on 2026-10-16.

## Buildings and usable space

Prioritize the six buildings with clearly expressed upper stories: Lodge,
Guildhall, Copper Kettle, Lantern Inn, Village Library and Meadow Inn. Their
model eave/ridge heights are respectively 5.1/9.3m, 8.1/12.2m, 5.2/8.5m,
6.2/9.5m, 5.8/9.4m and 6.0/9.1m above the local ground floor. The existing ceiling
slab tops out at 3.32m. These are source dimensions, not verified upstairs
headroom: roof thickness, beams, the Guildhall tower and chimney geometry must
be accounted for in implementation and actual walking/render checks.

Create one usable second floor in each selected building. Use sloped ceilings
and enclosed low eaves where needed, with at least 2.1m clear height along the
stair route, landings and usable upstairs circulation. Preserve roof silhouettes
and footprints. Do not count ridge height alone as adequate living space.
Leave the seven lower shop/workshop buildings unchanged in this bounded task;
attic conversions and further floors are separate work. Guildhall's higher
stories/turret remain decorative.

## Construction and art

The current upper volumes are solid extruded model geometry, not empty rooms.
Replace the selected volumes with finished wall/roof shells and a solid second
floor. Cut an actual stairwell in the existing ceiling slab and reroute any
intersecting ceiling beams. Add compact internal timber stairs, solid landings,
handrails and guards around the opening. Select straight or turning flights to
fit the room without blocking its entrance, central circulation or application
worktables. Relocate only directly affected decorative props where necessary.

Continue warm oak, cream plaster, terracotta exteriors and the existing material
pipeline. Finish and light the upstairs rooms, with modest matching artifacts:
inn/lodge seating, trunks and linens; tavern tables and crockery; library reading
shelves; Guildhall meeting furniture. Provide a clear existing-style worktable
upstairs in each converted building. No people or new interaction systems.

Reuse location-owned model/collision patterns. The retained `grand_foyer.gd`
provides a precedent for visible treads plus a tightly fitted character-only
walking guide, while objects collide with the real treads. Reuse that approach
where appropriate without loading the retired study or changing controller
behavior. Stairs must work by ordinary walking, ascending and descending,
without jumps, teleportation or input changes. The guide must follow the stair
flight closely; it is not a substitute for visible stairs and proper enclosure.
Keep existing desktop ownership, live panels, placement and nested/headless paths.

## Verification

1. Record current renders of affected exteriors and rooms; inspect real renders
   after conversion from downstairs, on each flight/landing and upstairs in all
   six buildings. Check headroom, stair openings, railings, floors, light and props.
2. Add a bounded headless/GPU walking trial through the normal doorway, upstairs,
   around the usable room, back down and outside. Exercise normal/slow movement,
   turns and descent; check support, floor/ceiling/guard collision, stair endpoints
   and clear circulation. Verify Home return from upstairs.
3. In every upstairs room launch a real terminal, place it on the worktable using
   ordinary controls, descend/leave/revisit, verify panel placement/entity and
   shell state, resume typing and close. Keep downstairs application work usable.
4. Run import/script validation and affected original-interior, expansion,
   architecture, landscape/outdoor and retained pavilion/Terminal/Vim/Firefox
   checks. Preserve exact application-color and input behavior. Update checks
   for intended openings without weakening their enclosure/walking assertions.
5. Check deterministic asset regeneration/provenance and matched named-host
   rendering cost. No target-device or human acceptance is inferred. Record
   actual results and limitations in STATUS, ACCEPTANCE and a completion handoff;
   validate links/task parsing/diffs, then commit only this task and stop.

No new buildings, third floors, exterior balcony access, NPCs, new desktop
services, persistence or dependencies. Record the second-floor exception in
Decision 08 when implementation is authorized. P22-T09 and human P22-T10 remain
separate unchecked gates; no unattended continuation is authorized.
