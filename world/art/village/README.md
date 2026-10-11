# Original village architecture — P22-T04

Five original models authored for Elsewhere on 2026-10-10 by the Codex agent.
No external model, image, font or downloaded texture is embedded. These are
original repository sources and assets, with no additional third-party licenses
or dependencies. This set does not replace or modify the Poly Haven manifest,
source cache or material-curation workflow.

Rebuild from the repository root with Python 3's standard library:

```sh
python3 world/tools/build_village_models.py
```

The authoring source is `world/tools/build_village_models.py`; all five compact
GLBs and their Godot import settings are tracked. No Blender installation,
network access or build-time generation is needed to run a fresh checkout.
Godot imports the included GLBs using the existing pinned engine.

Coordinates use meters, +Y up, front +Z, floor at Y=0. The lodge/guildhall plinths
extend below that floor; placement samples the existing terrain to bury them.
The placement script supplies foundation/entry steps and the pavilion ramp.
Faces have outward normals, counterclockwise glTF winding and projected UVs in
meters. Geometry is batched by named material into one mesh per model; Godot's
import creates the runtime mesh and LOD/shadow data. Static collision uses these
meshes. No moving furniture or application attachment behavior is added.

| Model | Modeled form | Triangles |
| --- | --- | ---: |
| `alpine_lodge.glb` | 10 × 7.5m body, deep pitched eaves, timber frame, balcony and brackets, shuttered windows on all elevations, capped chimney | 4,324 |
| `guildhall.glb` | 7.8 × 6.5m body, tall stepped gable, arched door, quoins, cornices, windows and fixed decorative clock | 3,496 |
| `stone_workshop.glb` | 8 × 6.5m body, hip roof, projecting side lean-to, twin chimney pots, arched entry and divided windows | 2,076 |
| `square_fountain.glb` | 4.1m-wide twelve-sided basin, turned column, four spouts and compass crown; 4.5m high | 744 |
| `work_pavilion.glb` | 9 × 7m floor, six posts, knee braces, king-post trusses, purlins and hipped roof; ridge at 5.5m | 880 |

Total: 11,520 model triangles, plus scene-authored steps/ramp/foundation. The
buildings are sealed exteriors. Doors do not open, the clock is decorative, and
the fountain is a static basin, not a water simulation. The pavilion has an open
covered floor; work surfaces/anchors remain P22-T07. Plain named base materials
separate architectural parts. Texture/foliage/daylight curation is P22-T05.

SHA-256 of the verified deterministic rebuild:

```text
3d13555aee544eb4cb488ed76b83f5f36ae5c886b690fc287cfe4bf567bd6e63  alpine_lodge.glb
48fc3dc3d5f31a085bafef19ff30fa8ca5f68a76e9cf7be686380a1315eacc89  guildhall.glb
ba3ec3690db62ab705b39bdff6d254730d8a83f7a8826454f76840b8e6a2289c  square_fountain.glb
de483e73b20d6f63ecbab226d9da0399145b8bbdd60113d40fce97641a0f35ee  stone_workshop.glb
6df87365b853cf6a7c4baf78ba1fca8e2196c4ce8b3e235ddd757011bc066d90  work_pavilion.glb
```

Actual Godot renders, iteration notes, collision and application regression
results are recorded in [handoff 42](../../../docs/handoffs/42-village-architecture.md).
