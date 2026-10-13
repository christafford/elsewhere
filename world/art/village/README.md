# Village architecture — selected reference 2, P22-T05 finishes

Original models authored for Elsewhere on 2026-10-10 and refined on
2026-10-11 by the Codex agent. The active set follows the owner's second
reference: weathered timber/stone, ivy, a pointed turret and tiered fountain.
Models/shaders remain original repository sources. P22-T05 binds nine tracked
Poly Haven CC0 material maps, documented in [texture provenance](textures/README.md);
no external model, font or new code dependency is introduced. Both owner JPEGs
remain visual references only; their
artists/source/licenses were not supplied. See
[source notes](../../../docs/art-direction/README.md).

Reference 1 is preserved at commit `340ca97` and local tag `art-reference-1`.
The old `courtyard_link.glb` remains tracked but is not loaded or rebuilt in
version 2. The seven active models below are regenerated. P22-T05 reuses
the Poly Haven fetch helper and extends the shared manifest with its curated
texture subset; study asset entries and files remain unchanged.

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
and roughness, with curated photographs for plaster/wood and the ground.
Post/brace UVs follow their length; only their UVs changed in P22-T05.
Dark slate roofs combine individually thick modeled shingles with
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
| `courtyard_tree.glb` | Original trunk/branches and twelve leaf clusters, at eight fixed sites | 29,040 |
| `mountain_backdrop.glb` | Fixed 560m-wide distant ridge mesh outside the playable boundary; no collision | 24,366 |

Active asset triangles: 110,410. Eight tree instances bring placed-model
triangles to 313,690 before Godot LOD, plus ground, boundary, steps and ramp.
These are geometry counts, not a performance benchmark. The former link's
2,160 triangles are inactive.

Buildings remain sealed exteriors. The hall's turret is decorative, not a new
accessible room. Water jets/ripples are visual effects, not fluid simulation.
The pavilion remains walkable and covered; P22-T07 adds the furniture below.
Architecture uses static mesh collision, trees only trunk cylinders, and the
mountains have no collision. Application materials are unchanged.

SHA-256 of the verified byte-identical rebuild:

```text
1b6f4b8643ebc93aca323fcc6e3a171e1d2389a6b22bd6eff60334eb35f23622  alpine_lodge.glb
46adeb2831a41c593d3186605952bf613af931a9e312858580c45b05d87d6da4  courtyard_link.glb
14f47f8cb58d313e4fef8543f05f2faf0bab719056f9b76969301991c42f6bd3  courtyard_tree.glb
43e33533e3079515605e84bab44d55e88c7201a63e696b3990778fd8f5a001d9  guildhall.glb
665ed2e3b1cd2ed0da2751d64258f84b488f7d86538a9fa0a943a4ad4804d5a7  mountain_backdrop.glb
854434b2ec13f56f178bba011fe92221f9cb08e1f67a0663fd74440a19bd7204  square_fountain.glb
60fd0e3bc9c8f4d88b4eba87c1b8012a53507f545f4502e0d93f8f451458d038  stone_workshop.glb
3e99118fd451303bd0d92c7e9843c208a7f1de4bd6037035462a6ab23bd44a53  work_pavilion.glb
```

See [handoff 45](../../../docs/handoffs/45-village-materials.md) for P22-T05
renders and verification. [Handoff 44](../../../docs/handoffs/44-village-reference-2.md)
and the [original comparison](../../../docs/art-direction/compare.html) preserve
the earlier checkpoints and safe switching instructions. The link hash above
belongs to the unchanged dormant reference-1 asset. Owner review/authorization
for P22-T06 was subsequently supplied; see handoff 46.


## P22-T07 pavilion furniture (2026-10-13)

Two original meshes authored by the Codex agent for Elsewhere, using the same
standard-library `Model` writer as the architecture. These are original
repository assets; no third-party models were incorporated.
No external model or new dependency. Reuses the recorded CC0 rough-wood maps
and existing timber/teal/metal material mapping. Rebuild independently:

```sh
python3 world/tools/build_pavilion_furniture.py
```

| Model | Form | Triangles | Instances |
| --- | --- | ---: | ---: |
| `pavilion_worktable.glb` | 2.52 × 1.04m framed plank top, trestle legs/braces, stretchers, brass pegs and a raised teal placement pad | 420 | 2 |
| `pavilion_stool.glb` | 0.70m round beveled seat, four legs and stretchers; 0.58m high | 320 | 2 |

Adds 1,480 placed triangles before LOD. Both GLBs and default Godot import
settings are tracked. Coordinates remain meters/Y-up; the table pad is at
0.98m above the pavilion floor. Geometry is deterministic and launches offline.

`pavilion_workspace.gd` owns the fixed tables, fitted convex collision,
`WorkAnchor` markers at the pad tops, and two existing `pushable_furniture.gd`
assemblies. Anchors are physical, manually chosen support locations, with no
snapping, window assignment or persistent identity service. The central 1.48m
passage stays clear. Stools use ordinary carry, wheel rotation, cancel and push;
they are movable props, with no sitting mechanic. Tables stay fixed.

Verified byte-identical rebuild hashes:

```text
c044679e1d9f793cf8b2e53cd6116c1ebd340d3af58b098115941cd751489d8f  pavilion_worktable.glb
312ccf698f83571c2cc28b8ab798fc9962bc3d48e788ea080008d54e25e87a8c  pavilion_stool.glb
```

See [P22-T07 evidence](../../../docs/evidence/p22-t07/README.md) for actual
renders, live shell continuity and verification limits.

## P22-T08 distant landscape (2026-10-13)

Original repository-authored fir model and procedural foothills by the Codex
agent; no downloaded model, texture or new dependency. Rebuild the fir alone:

```sh
python3 world/tools/build_village_surrounds.py
```

`distant_fir.glb` has 3,327 triangles, three opaque material surfaces, a tapered
trunk, nine tiers of separate boughs/needle sprays and a narrow crown. It is
321,932 bytes; default Godot import/LOD settings are tracked. Byte-identical
regeneration SHA-256:

```text
e36562a4c251f5a5efa458b7691dc8d51b1881f5ed0d02af172e0bb44570c1a3
```

`village_surrounds.gd` creates 144 deterministic instances in one MultiMesh,
varied in yaw/scale, outside the playable bank. The 1,680-triangle foothill ring
starts at the existing bank's outer shoulder and extends beneath the distant
mountains. Original analytic meadow/rock color variation and two narrow track
stretches need no texture assets. Trees/foothills have no collision or shadow
passes and no per-frame scripts. Maximum placed geometry before LOD is 480,768
triangles; the renderer's primitive monitor counts the instanced tree mesh once,
so that counter must not be mistaken for placed triangle cost. Four additional
draw calls were measured. Distant mountain color receives local haze; existing
mountain geometry, cloud cover, global exposure and client materials are intact.

See [P22-T08 evidence](../../../docs/evidence/p22-t08/README.md) for seven actual
renders, matched before/after counters and precise host-performance limits.


## Sunlit palette and flower borders (owner revision, 2026-10-13)

The owner's `docs/art-direction/art-direction-1.jpg` guides a warm clay-roof,
cream-plaster/oak palette; it is reference only, not a runtime asset. Existing
architectural GLBs and texture bytes are unchanged. `village_materials.gd`
overrides their named material roles, including the five existing roof-course
roles. The historical `blue` flower role now renders orange in this palette.
Procedural ground, sky, stone bank and distant terrain use matching colors.

`courtyard_flowers.glb` is original deterministic repository geometry by the
Codex agent, reusing the existing standard-library `Model` flower/lathe/merge
functions. It has 3,264 triangles, 319,648 bytes, and eight material surfaces.
Four fixed .8-scale decorative instances add 13,056 placed triangles before LOD;
there is no collision, processing loop or desktop ownership. Soil discs ground
three pink/amber/orange clumps beside existing facades, clear of doorways.
No downloaded asset or dependency was added. Rebuild:

```sh
python3 world/tools/build_village_flowers.py
```

Verified byte-identical SHA-256:

```text
69156443da8f7fce044e551764f71b1cceeedc8f5a2d0720694af5bc5c4332bf
```

See [visual evidence](../../../docs/evidence/sunlit-village/README.md) and
[handoff 53](../../../docs/handoffs/53-sunlit-village-palette.md).
