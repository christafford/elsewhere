# Open village perimeter — approved P22-T13

2026-10-16, inspected baseline `00d6076`. The owner requests removal of the
surrounding wall because it diminishes the feeling of exploration. Travel beyond
the current boundary is optional; this scope retains the current playable area.
The owner reiterated the instruction to proceed after reviewing this **P22-T13**
scope, authorizing implementation on 2026-10-17. This plan itself is not
implementation or visual acceptance. [AGENTS.md](../../AGENTS.md) limits execution
to this task.

## Existing construction

`world/scripts/village_landscape.gd` creates a ten-sided `BoundaryBank` mesh:
stone faces, a turf shoulder and collision derived from those same triangles.
Its crest is 2.6–4.2m above the local ground. The polygon also defines application
placement bounds. Ground extends across a 96m square around the playable area.

`world/scripts/village_surrounds.gd` starts its decorative foothills at the
outer shoulder, at bank-crest height. Simply deleting or hiding the bank would
leave the terrain join exposed. The distant trees and mountains already supply
the landscape beyond the village; no new asset dependency is needed.

## Bounded implementation

Remove the visible enclosing stone faces and raised turf shoulder. Separate the
physical limit from visible geometry: retain an invisible collision perimeter
at the same polygon, with reliable containment during walking and jumping.
Retain the existing placement bounds and collision behavior for movable objects.

Regrade the near edge of the decorative surroundings to meet the local terrain
continuously. Resolve overlaps with the existing ground mesh to avoid cracks,
z-fighting, floating trees or abrupt exposed edges. Keep the distant wooded hills,
mountains and occasional track glimpses in the established art style. Preserve
open views between village buildings and into the landscape; do not replace the
wall with a continuous steep ridge or dense vegetation screen.

Keep all thirteen buildings, six stair routes, workspaces and existing circulation.
No new explorable area, destinations, people, input behavior, desktop services,
dependencies or persistence work. Record the visible-boundary change in Decision
08 and current architecture/art documentation once implementation is authorized.
Earlier evidence describing the bank remains explicitly historical.

## Verification and completion

1. Capture matched before/after renders at arrival, streets, all ten perimeter
   sections and representative upstairs outlooks. Inspect actual images for
   open sightlines, terrain continuity, ground edges and vegetation grounding.
2. Retain the existing outdoor boundary trials: walking/jumping into all ten
   sections, diagonal corner motion and Home. Extend corner coverage as needed;
   test physical object containment and panel placement near the perimeter.
   Update obsolete bank terminology without relaxing containment assertions.
3. Run headless/GPU ground, route and startup checks, affected building/stair
   checks and retained live-application placement/revisit/input/close regressions.
   Run Godot import/script validation and applicable repository checks.
4. Record matched named-host render cost. Do not infer Steam Deck, sustained
   performance or human acceptance. Document observed results and limitations in
   STATUS, ACCEPTANCE and a completion handoff, validate links/task parsing/diffs,
   then commit this task's files and stop. P22-T09/P22-T10 remain separate gates.
