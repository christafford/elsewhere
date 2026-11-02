# Village animals — P22-T14

Five original Elsewhere models authored by Codex on 2026-11-01. The authoritative
source is `world/tools/build_village_animals.py`, reusing the existing village
`Model` geometry helpers and Python standard library. No downloaded model,
texture, font, animation library or new dependency is included. External CC0
candidates were evaluated in `.tools/p22-t14/` and rejected for missing walk
cycles or mismatched proportions; they are not runtime assets.

Rebuild and verify from the repository root:

```sh
python3 world/tools/build_village_animals.py
python3 world/tools/verify_village_animals.py
```

The five GLBs, their Godot import settings and `manifest.json` are tracked for
offline startup. The manifest records actual byte sizes, SHA-256, triangle counts
and joint names. The models contain 19,720 triangles total; the default twelve
instances place 47,760 triangles before LOD. Original meter-scale coat grain is
in `animal_coat.gdshader`; glTF material swatches retain sRGB-to-linear conversion.

Units are meters, +Y up, +Z forward. Anatomical cross-sections form bodies and
heads; tapered two-part legs, hooves/paws/toes, ears, horns, beards, udders,
feathers and tails distinguish the five species. Shared-vertex normals smooth
organic surfaces while horns, hooves and beaks keep defined edges. These are
articulated node models, not skinned imports: `Body`, `Head`, `Tail`, `LegN` and
`ShinN` are the runtime contract. There are no embedded animation clips.

`village_animal.gd` supplies the walk, rest, forage and yield states. Walk phase
follows actual traveled distance; two-joint foot placement follows terrain, with
stance/swing phases, bounded hip correction and body pitch. Head bends and nods
supply grazing/rooting/sniffing/pecking; cows/goats only forage on grass. Tails
move at different rates. This is a modest ambient behavior simulation, not
animal husbandry or a biomechanical research model.

`population.json` controls counts, stable species identity, speed, stride, pause
range, clearance class, roaming range and preferred outdoor home. Defaults are
2 pigs, 4 chickens, 2 dogs, 2 goats and 2 cows. Spawning searches for a clear
reachable cell and warns rather than forcing a crowded spawn. Per-instance RNG
streams vary behavior; `--animal-seed=<integer>` supplies repeatable trials.
`--no-animals` disables the location's animals/navigation for comparison.

Physical bodies sweep against buildings and actors while terrain height provides
vertical support. Navigation independently verifies actual ground collision and
exterior support before movement; avoiding repeated wide-body sweeps against the
dense ground mesh prevents their contact cost from dominating physics. Resting
bodies retain collision but skip unnecessary movement sweeps.

Navigation obtains the authoritative travel polygon and terrain height callback
from `village_landscape.gd` and physical ground RIDs from the constructed scene.
It rebuilds an exterior clearance graph from actual collision, filtering roofs,
interiors, unsupported land, slopes and narrow routes. The graph uses three
conservative footprint radii (0.32, 0.9 and 1.4m), with one bounded planning
opportunity per physics tick and local avoidance. Changes to the map rebuild
navigation; habitat/population changes remain explicit data edits. No land
expansion, automatic population growth, scene streaming or restart persistence
is introduced by P22-T14.
