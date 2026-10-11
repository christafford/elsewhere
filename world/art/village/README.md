# Original village architecture and planting

Original models authored for Elsewhere on 2026-10-10 and revised by the Codex
agent on 2026-10-11 against the owner's courtyard reference. No external model,
image, font or downloaded texture is embedded. These are original repository
sources and assets, with no additional third-party licenses or dependencies.
The owner's JPEG is reference only; see [source notes](../../../docs/art-direction/README.md).
This set does not replace the existing Poly Haven tooling or manifest.

Rebuild from the repository root using Python 3's standard library:

```sh
python3 world/tools/build_village_models.py
```

The authoring source and all seven GLBs/import settings are tracked. A fixed
local random seed gives reproducible leaf/flower placement and roof variation;
there is no runtime procedural layout. No Blender, network or generation step
is needed at launch. The pinned Godot imports the included files normally.

Coordinates use meters, +Y up, front +Z, floor at Y=0. Placement samples the
existing terrain for foundations, entrance steps and the pavilion ramp. Faces
have outward normals, counterclockwise glTF winding and projected UVs in meters.
Geometry is batched by named material into one mesh per model; Godot generates
LOD/shadow data. The scene applies `village_materials.gd` and the original
`village_surface.gdshader`: plaster grain, timber grain, masonry/slate joints
and roughness. Blue roofs combine individually thick modeled shingles with
shader detail on the hip faces. Leaf geometry includes both sides explicitly.

| Model | Modeled form | Triangles |
| --- | --- | ---: |
| `alpine_lodge.glb` | 10 × 7.5m body, curved gable roof (9.3m ridge), dormers, balcony, timber frame, lattice windows and planted boxes | 33,648 |
| `guildhall.glb` | 7.8 × 6.5m body, curved roof (9.95m ridge), warm timber/plaster gable, clock, dormer, awning and flower boxes | 30,068 |
| `stone_workshop.glb` | 8 × 6.5m body, 7.05m hipped roof, dormer, lean-to, twin chimney pots and lattice windows | 5,176 |
| `square_fountain.glb` | Twelve-sided basin, spouts/compass crown (3.65m high), low 6.3m planted surround with 270 blooms | 29,160 |
| `work_pavilion.glb` | 9 × 7m floor, six posts, braces, king-post trusses, purlins and curved hipped roof (5.5m ridge) | 3,020 |
| `courtyard_tree.glb` | Original branching trunk with twelve dense leaf clusters, instanced at eight fixed sites | 22,320 |
| `courtyard_link.glb` | 13.2m exterior timber link, curved ribs, deck boards, posts and rails | 2,160 |

Total asset triangles: 125,552. Eight tree instances bring the placed-model
count to 281,792 before Godot LOD, plus terrain, foundations, steps and ramp.
This is an asset count, not a performance benchmark.

Buildings remain sealed exteriors. The link is decorative architecture above
the northern route, with no accessible interior or new destination. The clock
and fountain water are static. The pavilion remains walkable and covered;
work surfaces/anchors remain P22-T07. Architecture uses static mesh collision.
Trees have only trunk cylinders, leaving decorative leaves/branches out of
collision. All materials are scene-local; application shaders are unchanged.

SHA-256 of the verified byte-identical rebuild:

```text
0b53ed96f29ee8e9aada103b2b7685cc707a655c05aaf894f94b1ff2bef81732  alpine_lodge.glb
46adeb2831a41c593d3186605952bf613af931a9e312858580c45b05d87d6da4  courtyard_link.glb
80f18d8ff502fdad1fdbe3e056b7da65f5ffbfb5dc1a84088491fd167bc6cad5  courtyard_tree.glb
3fbe6074862afd999ad503ea02ab7221420d987de539175017405b1901e4334d  guildhall.glb
ca3e720ec1cc85ca0193ea79248a584739d83d25c023a82a6c77641cb54d51de  square_fountain.glb
6b8ce48460b06c76a2f6804ff480b0f73019091834af19b69d0ea9e09aeff116  stone_workshop.glb
abc07631d54a562e57cca11302301c271556f180c8f26106d5102c7ac0e2b10e  work_pavilion.glb
```

See [handoff 43](../../../docs/handoffs/43-village-reference-alignment.md) for
current rendered evidence and checks, and
[handoff 42](../../../docs/handoffs/42-village-architecture.md) for the original
P22-T04 checkpoint. This bounded revision does not close the P22-T05 art gate.
