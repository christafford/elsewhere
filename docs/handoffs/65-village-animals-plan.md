# Village animals — approved P22-T14

2026-11-01, inspected baseline `3b14342` plus the existing uncommitted P22-T13
perimeter work. The owner requests pigs, chickens, dogs, goats and cows wandering
the navigable village naturally, with future buildings and more land in mind.
This records the approved scope for [P22-T14](../TASKS.md). Implementation and
verification are recorded separately in [handoff 66](66-village-animals.md). [AGENTS.md](../../AGENTS.md) requires an explicit P22 task ID before
execution; the owner explicitly authorized P22-T14 on 2026-11-01. Do not complete or commit P22-T13 as
part of this task.

## Population and appearance

Start with twelve animals: two pigs, four chickens, two dogs, two goats and two
cows. Keep these counts configurable and conservative for the current thirteen
buildings and limited open ground. Distribute small groups across suitable
outdoor patches rather than crowding the arrival square. Validate placement and
space before spawning; never force an animal into an occupied or unreachable
position merely to reach a configured count.

Use cohesive, finished 3D models with recognizable anatomy, natural proportions,
species-specific coats, and articulated movement suited to the warm village art.
Provide walking and idle/feeding animation, with foot speed tied to actual
travel, smooth starts/stops/turns and terrain contact. Inspect close and street
views and moving sequences; primitive stand-ins do not satisfy acceptance.
Prefer licensed reusable animated models where they meet the art and technical
requirements, or reproducibly authored original assets. Record source, license,
hashes, import settings, units, animation names and geometry budgets under the
existing [asset pipeline](../ASSET-PIPELINE.md). Asset selection remains open.

## Behavior and navigation

Alternate movement with species-appropriate pauses: cows and goats graze, pigs
sniff/root, chickens peck and take short steps, and dogs sniff, rest and wander
farther. Vary timing and pace between individuals. Keep chickens and grazing
animals loosely near companions without lockstep motion or permanent crowding.
Animals yield to the approaching player and one another, with bounded reactions
and recovery rather than constant fleeing or following the camera.

The current scene has terrain heights, collision and a convex travel boundary,
but no animal navigation layer. Add location-owned navigation and animal nodes
beside the existing outdoor geometry; preserve DesktopRuntime ownership and
input. Derive outdoor walkable space from the authoritative terrain, boundary
and constructed obstacles after location initialization. Filter out interiors,
stairs, roofs, fountain water and decorative terrain beyond the travel polygon.
Account for species body size, clearance and slope when choosing a route; a gap
usable by a chicken must not automatically admit a cow.

Choose reachable destinations, follow paths around buildings, and use local
avoidance for moving animals, the player, stools and live panels. Physical
movement must still respect obstacles and ground support. Keep entrances,
stairs and worktable approaches clear. Detect stalled routes, retry with bounded
work, then pause safely if no destination exists. No visible teleporting,
wall sliding as the entire navigation strategy, or endless retries.

Store species tuning, population, habitat preferences and stable animal IDs as
location data separate from movement logic and native desktop handles. Reference
the existing terrain/boundary instead of duplicating today's dimensions in each
animal. Rebuilding navigation after a future map edit must admit new connected
land and exclude new buildings without rewriting behavior. Population increases
remain explicit configuration changes, not automatic breeding or density growth.
This task does not expand the map, add buildings, simulate farming, add people,
or implement restart persistence or world streaming.

## Verification

1. Validate asset provenance, offline imports, scripts and animation availability.
   Inspect actual Godot close-ups of all five species and street-level movement
   sequences for proportions, gait, foot contact, intersections and visual fit.
2. Add deterministic headless and graphical behavior trials across several seeds:
   all species move and pause, remain grounded and inside the boundary, avoid
   architecture and one another, and recover from blocked/unreachable targets.
   Exercise player approach, dynamic obstructions and narrow routes; distinguish
   numerical assertions from agent-observed naturalness.
3. In an isolated navigation fixture, extend connected ground and add an obstacle;
   regenerate navigation and verify animals use the new area and route around
   the obstacle without changes to their behavior code. Do not expand the live
   village or count decorative foothills as walkable land.
4. Run affected landscape/outdoor, building/stair and pavilion checks with animals
   active. Exercise real Terminal/Vim launch, typing, placement, world travel,
   revisit and close; verify panel identity/content and reserved controls remain
   intact while animals continue moving. Preserve nested and headless paths.
5. Measure matched animals-disabled/enabled rendering and simulation cost on the
   named host, including a bounded crowded-route trial. Use shared resources,
   staggered decisions and bounded path requests; record target-device and human
   comfort limits honestly. Do not infer P22-T09 or P22-T10 acceptance.
6. Record evidence in STATUS, ACCEPTANCE and a completion handoff, amend Decision
   08 for this explicitly requested ambient-animal scope, validate links/task
   parsing/diffs and commit only this task's changes. Stop after P22-T14.

## Historical scope-document validation

Local links, unique Project 22 task IDs, the live P22-T14 parser check, all 62
Node/plugin tests and `git diff --check` pass. A preliminary whole-file uniqueness
check found historical repeated task IDs; comparison with HEAD confirms those
duplicates are unchanged. No build, animal runtime or rendered check was run
for this documentation-only scope. Existing user edits remain uncommitted and
separate; this scope does not claim completion of either P22-T13 or P22-T14.
