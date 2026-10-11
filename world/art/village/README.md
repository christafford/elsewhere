# Original village architecture — comparison candidate 2

Original models authored for Elsewhere on 2026-10-10, revised twice on
2026-10-11 by the Codex agent. The active set follows the owner's second
reference: weathered timber/stone, ivy, a pointed turret and tiered fountain.
No external model, image, font or downloaded texture is embedded. All runtime
models/shaders are original repository sources, with no new dependency or
third-party license. Both owner JPEGs remain visual references only; their
artists/source/licenses were not supplied. See
[source notes](../../../docs/art-direction/README.md).

Reference 1 is preserved at commit `340ca97` and local tag `art-reference-1`.
The old `courtyard_link.glb` remains tracked but is not loaded or rebuilt in
candidate 2. The seven active models below are regenerated. The existing
Poly Haven tooling/manifest and study assets are unchanged.

Rebuild from the repository root using Python 3's standard library:

```sh
python3 world/tools/build_village_models.py
```

The authoring source and all active GLBs/import settings are tracked. A fixed
local random seed gives reproducible leaf/ivy placement;
there is no runtime procedural layout. No Blender, network or generation step
is needed at launch. The pinned Godot imports the included files normally.

Coordinates use meters, +Y up, front +Z, floor at Y=0. Placement samples the
existing terrain for foundations, entrance steps and the pavilion ramp. Faces
have outward normals, counterclockwise glTF winding and projected UVs in meters.
Geometry is batched by named material into one mesh per model; Godot generates
LOD/shadow data. The scene applies `village_materials.gd` and the original
`village_surface.gdshader`: plaster grain, timber grain, masonry/slate joints
and roughness. Dark slate roofs combine individually thick modeled shingles with
shader detail on the hip faces/spire. Leaf geometry includes both sides explicitly.
The backdrop has smooth normals and an original height/slope-based snow and
rock shader. Fountain water has animated shader ripples on decorative geometry.

| Model | Modeled form | Triangles |
| --- | --- | ---: |
| `alpine_lodge.glb` | 10 × 7.5m body, steep slate roof, boarded gable, heavier braces, balcony, lattice windows and ivy | 16,176 |
| `guildhall.glb` | 7.8 × 6.5m body, three-story timber/plaster front, 12.2m ridge, attached slate turret and 16.4m pennant pole | 17,428 |
| `stone_workshop.glb` | 8 × 6.5m body, 7.05m hip roof, dormer, lean-to, masonry corners and ivy | 7,100 |
| `square_fountain.glb` | 6.3m stepped surround, 4.84m basin, three tiered bowls, decorative jets and 4.62m finial | 13,280 |
| `work_pavilion.glb` | 9 × 7m floor, six posts, braces/trusses and 5.5m hipped slate roof | 3,020 |
| `courtyard_tree.glb` | Original trunk/branches and twelve leaf clusters, at eight fixed sites | 22,320 |
| `mountain_backdrop.glb` | Fixed 560m-wide distant ridge mesh outside the playable boundary; no collision | 24,366 |

Active asset triangles: 103,690. Eight tree instances bring placed-model
triangles to 259,930 before Godot LOD, plus ground, boundary, steps and ramp.
These are geometry counts, not a performance benchmark. The former link's
2,160 triangles are inactive.

Buildings remain sealed exteriors. The hall's turret is decorative, not a new
accessible room. Water jets/ripples are visual effects, not fluid simulation.
The pavilion remains walkable and covered; work surfaces/anchors remain P22-T07.
Architecture uses static mesh collision, trees only trunk cylinders, and the
mountains have no collision. Application materials are unchanged.

SHA-256 of the verified byte-identical rebuild:

```text
b3243971a2bae810a91042eb69a9edc713765fde39c0f61d6e9bbff8f3e7a4af  alpine_lodge.glb
46adeb2831a41c593d3186605952bf613af931a9e312858580c45b05d87d6da4  courtyard_link.glb
f1d3982b72bbbe2e0cddf22c3af041d438b735d1ab1e1ab0efb2bd0d7baee860  courtyard_tree.glb
7de7ade1908f8faf26186ff3a545df0ae34f9f0dadd1b5b9861b1e63ba4c7a8b  guildhall.glb
665ed2e3b1cd2ed0da2751d64258f84b488f7d86538a9fa0a943a4ad4804d5a7  mountain_backdrop.glb
854434b2ec13f56f178bba011fe92221f9cb08e1f67a0663fd74440a19bd7204  square_fountain.glb
24bf134f137683c3ac244be6423042f0a4cb9dd853ad3465974c991b21bdae44  stone_workshop.glb
a735b38c65abd9dbd33d93e3d2210c9ac1232ba8dbe66d87b11618e48090a7ac  work_pavilion.glb
```

See [handoff 44](../../../docs/handoffs/44-village-reference-2.md) and the
[interactive comparison](../../../docs/art-direction/compare.html) for current
renders, verification and switching instructions. The link hash above belongs
to the unchanged dormant reference-1 asset. This experiment does not close the
P22-T05 owner art gate or advance any subsequent task.
