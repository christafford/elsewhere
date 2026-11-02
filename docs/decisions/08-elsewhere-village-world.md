# Decision 08 — Elsewhere village world (2026-10-09)

**Status:** Accepted by owner for direction; implementation pending.

## Context

The existing Godot study proved useful 3D navigation, movable/rotatable
objects, and live application panels that can be left and revisited within a
session. Connected rooms and corridors do not provide the desired delight,
exploration, or memorable geographic identity. We are changing the physical
world while retaining the existing integration approach.

## Decision

- Product name is **Elsewhere**. P21-T67 completed the technical rename; retain
  its tested runtime identifiers and paths. This decision changes the world,
  not the naming baseline. See [handoff 38](../handoffs/38-elsewhere-rename.md).
- Start with a *single compact village square* in a beautiful, explorable
  alpine/temperate setting. One landmark, differentiated exteriors, a covered
  workspace, vegetation, paths, and convincing distant boundaries. No whole
  village or functional building interiors yet.
- Retain Godot renderer, C++ Wayland compositor and GDExtension bridge, current
  launcher, input/application modes, object manipulation, and nested/headless
  development/test paths.
- Decouple world-specific geometry from desktop services before replacing the
  active study world. Keep stable application/artifact identities independent
  of scene nodes, physical room paths, runtime handles, and PIDs.
- Remove old study geometry from the **active** scene only after safe runtime
  extraction and smoke tests. Preserve historical implementation or archive it
  in a reversible manner until affected tests and references are migrated.
- Visual acceptance requires inspecting actual Godot render captures.
  Runtime integration must be tested with real applications. Missing GUI access
  is an explicit blocker, not evidence of success.
- Task creatures, extra destinations, weather, NPCs, teleportation redesign,
  and persistence across restarts remain outside this milestone.
- Owner controls token usage: only explicitly requested single P22 task; no
  autonomous continuation to the next task.

## Consequences and guardrails

Project 21 remains history/evidence but is not the active world build plan.
P22-T01 must document actual dependencies in `world/scripts/study.gd` and
extract conservatively; avoid a speculative rewrite. P22-T02 establishes a
minimal outdoor replacement and must not claim application integration is
fully verified before P22-T06. Each task records checks and precise blockers.
The first acceptance gate is **visual delight** after P22-T05; the second is
**live desktop usability** after P22-T09 and owner review at P22-T10.

## Owner amendment: enterable existing buildings (2026-10-14)

The owner explicitly requested entry into the existing buildings and larger,
useful interiors. This supersedes the initial exterior-only restriction for the
Lodge, Guildhall and Workshop ground floors. Extend their rear footprints,
provide physical doorways and continuous walking access, and reuse the existing
workspace furniture and live application behavior. Keep the square-facing
routes, warm art direction, desktop services and nested/headless paths intact.
Upper floors/turrets remain decorative. This bounded request authorizes no new
building, roadmap continuation, P22-T09 performance gate or human acceptance.
See [handoff 54](../handoffs/54-building-interiors.md).

## Owner amendment: furnished village expansion (2026-10-15)

The owner explicitly authorized **P22-T11**: ten new buildings with furnished,
enterable ground floors, appropriate artifacts and connected streets, retaining
the current warm palette and existing square. Two taverns, two inns, a library,
bookbinder, bakery, apothecary, general store and pottery shop are in scope.
This supersedes the initial compact-square/no-extra-destinations restriction
for this task only. People/creatures, commerce/crafting simulation, new desktop
services and restart persistence remain excluded. Preserve the existing
playable boundary and real desktop behavior. Verification requires actual renders,
walking and real-app continuity. This authorizes neither P22-T09/P22-T10
acceptance nor another task. See [scope](../handoffs/55-village-expansion-plan.md).

## Owner amendment: stairs and second floors (2026-10-16)

The owner authorized **P22-T12** after reviewing its scope: internal stairs and
usable second floors in the Lodge, Guildhall, Copper Kettle, Lantern Inn, Library
and Meadow Inn. This supersedes the decorative-upper-floor restriction for those
six second floors only. Preserve exterior silhouettes, warm materials, existing
entries/workspaces and desktop behavior. Provide real ceiling openings, guarded
stairs/landings, headroom, finished rooms and appropriate furnishings. Verify
ordinary ascent/descent, actual renders and upstairs real-application continuity.
No additional buildings, further floors, NPCs, new services or restart persistence.
P22-T09/P22-T10 remain separate gates; stop after this task. See
[approved scope](../handoffs/57-village-upstairs-plan.md).

## Owner amendment: open perimeter (2026-10-17)

After reviewing P22-T13, the owner reiterated removal of the surrounding wall
so the village feels open to exploration. Remove the visible bank and join the
local ground continuously to the existing wooded foothills. The current travel
polygon may remain an invisible physical limit; retain application/object bounds.
This supersedes the visible-bank construction, without expanding the playable
area or authorizing another task. Preserve buildings, stairs, art style and live
desktop behavior. Inspect actual renders and verify containment and affected
interactions. P22-T09/P22-T10 remain separate gates. See
[approved scope](../handoffs/59-open-village-boundary-plan.md).


## Owner amendment: wandering village animals (2026-11-01)

The owner explicitly authorized **P22-T14** after reviewing its scope. Add pigs,
chickens, dogs, goats and cows as ambient outdoor inhabitants, with articulated
movement, species-appropriate pauses/feeding, collision-aware wandering and
navigation adaptable to later land/building changes. This supersedes the
no-creatures restriction for these animals only. Population stays small and
configurable; no task/reminder creatures, people, farming economy, breeding,
map expansion or restart persistence. The location owns animal models, behavior
and navigation; the compositor, desktop identities and input ownership remain
unchanged. Use original reproducible models and existing Godot/Python facilities;
no dependency is added. Preserve the independent unfinished P22-T13 work and
P22-T09/P22-T10 gates. See [approved scope](../handoffs/65-village-animals-plan.md).

## Owner amendment: temporary animal blasts (2026-11-01)

The owner directly requested four random double-click reactions on the existing
animals: Lightning-Blast, Fire-Blast, Cyclone-Blast and Love-Blast. This bounded
interaction is authorized independently of roadmap continuation. Effects are
brief and reversible, preserve collision-aware movement, and return to ordinary
animal life without damage or persistence. Retain application/launcher/help
input ownership and verify actual renders and real-client continuity. No new
species, destination, dependency, numbered milestone or human gate is authorized.
See [handoff 70](../handoffs/70-animal-blasts.md).
