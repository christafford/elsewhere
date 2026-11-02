# P22-T14 — wandering village animals

2026-11-01, agent implementation/verification against `3b14342` plus the owner's
existing, uncommitted P22-T13 perimeter work. Only P22-T14 is authorized. The
[approved scope](65-village-animals-plan.md) remains the acceptance boundary;
no new buildings or land are added here.

## Implementation

The default village contains two pigs, four chickens, two dogs, two goats and
two cows. Original, reproducible GLBs have recognizable proportions, coats and
articulated heads, tails and two-part legs. Warm stylized rendering matches the
village. Walking follows actual distance; terrain foot placement, body pitch,
head motion and species-specific forage/rest timing supply ambient movement.
Cows/goats graze on grass, chickens peck, pigs root/sniff and dogs sniff/wander.
Downloaded asset candidates were rejected; none ships in the scene.

`Animals` is a location-owned sibling of the architecture and desktop runtime.
Three outdoor AStar3D graphs account for animal size. Terrain, collision ground
and the existing travel boundary are authoritative: top-down support checks and
swept shapes reject buildings, roofs, steep/unsupported ground and narrow gaps.
Path smoothing preserves those exclusions. Local separation and physical bodies
handle animals, the player and movable objects. An actor already within padded
clearance can escape outward; it cannot move deeper into the overlap. Blocked
routes pause and retry with bounded work. Decisions are staggered to one animal
per physics tick, and navigation yields on a 1.5 ms slice budget. Model resources
load with the scene, with first instantiation/rendering spread over frames.

The location data in [population.json](../../world/art/animals/population.json)
controls counts, habitats, movement and pauses. Stable animal IDs have no desktop
or process-handle meaning. `--animal-seed=2214` repeats a trial; `--no-animals`
disables animals/navigation for comparison. Future map edits regenerate the
same graph from the new terrain/bounds/buildings. Adjust habitat centers/counts
explicitly when opening more land; behavior code does not embed today's map
extents. No automatic breeding, farming, streaming or restart persistence.

## Verification and limits

See [evidence, commands and measurements](../evidence/p22-t14/README.md).
Import/script validation and the bridge build pass. Original model regeneration
is byte-identical; offline asset verification rejects missing/corrupt assets.
Headless/GPU navigation and behavior trials pass, including two RNG seeds,
map growth, a new building, chicken-versus-cow clearance, covered-ground
exclusion, occupied maps, player yielding and a crowded dog/goat crossing.
All twelve animals move, complete routes and alternate activity. Solver
foot-to-target errors stay below 1.3 mm in these trials. Vertical support follows
the same authoritative terrain sampled by navigation; physical body sweeps resolve
obstacles and other actors. This avoids expensive wide-body contacts against the
dense ground triangle mesh. Resting bodies retain collision and skip idle sweeps.

Agent inspected actual five-species close renders and normal-speed motion
sequences, plus real Terminal/Vim revisits. These establish the recorded visual
observations, not human appearance/comfort approval. The live application test
also verifies animals continue moving during typing and preserve animal IDs
across application launch, placement, world walking, revisit and close.

Retained outdoor/architecture/interior/pavilion checks pass, as do all ten added
buildings and six upstairs rooms with live shell revisits. Four-size resize,
help/input isolation, native color and application transitions pass. The
transition fixture now waits for asynchronous population initialization before
its unchanged flight assertions. No walking tolerances were relaxed.

Matched 1280×800 RTX 3080 samples show 16.6–17.1 ms frame medians with animals,
18.6–29.9 ms p95, and 5.9–7.1 ms median physics versus 1.2–1.3 ms without animals.
Navigation initializes in 11.7–15.5 s in recorded trials; the desktop starts
before the animals appear. These costs remain explicit limits for expansion.

P22-T09/P22-T10 and the unfinished P22-T13 are unchanged. No new full native
Meson/sanitizer run is claimed: the implementation changes Godot/assets/tests,
not C++ compositor behavior. Human physical-input/comfort, sustained and
Steam Deck performance, restart restoration and larger populations remain
unverified. Short named-host samples do not establish those gates.

Stop after P22-T14. No next task is authorized by this handoff.
