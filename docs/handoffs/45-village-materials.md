# P22-T05 — selected version 2 materials, foliage and daylight

2026-10-11, based on `82dd2a2` (`art-reference-2`). The owner explicitly chose
version 2 and requested **P22-T05 only**. This establishes the selected art
direction; it does not pre-approve these subsequent refinements or authorize
P22-T06. Decision 08 and the updated AGENTS.md govern this bounded pass.

## Implementation

Three curated [Poly Haven sets](../../world/art/village/textures/README.md)
replace uniform procedural paving, noisy plaster and generic timber grain.
Nine original 1K diffuse/OpenGL-normal/roughness JPEGs are tracked, with explicit
mipmapped import settings and source URLs, author, CC0 license, bytes and hashes
in the existing JSON manifest. Selection used live metadata and inspected maps;
downloads reused the existing atomic fetch helper, now identifying Elsewhere.
The new offline verifier is part of project validation and has missing/corrupt/
incomplete-manifest negative tests. No new dependency or runtime network call.

The same shader/scene boundary remains. Carved stone bowls and access surfaces
have fine pores rather than wall mortar courses. Existing beam UVs follow their
length; positions/normals and counts of all six non-tree active models match
`82dd2a2` byte-for-byte. Tree leaves have a wider range of angles, slightly
smaller size, fuller clusters and a more varied olive palette/backlighting;
trunk colliders and fixed sites are unchanged. Terrain, routes, buildings,
mountains, desktop runtime, controller, client materials and native code are
unchanged. Ramp UVs/material change, but its collision vertices do not.

Daylight keeps the selected sky, sun angle and color. Ambient fill is 0.42
(previously 0.32), sun energy 0.9 (0.95), directional shadow range 90m with
blended splits, bias 0.1 and normal bias 2.0. Close stone/post contact and
covered timber were inspected in rendered views; no SSAO or baked-GI claim.
Exposure stays 1 and Filmic tone mapping stays unchanged deliberately, preserving
the client color compensation contract. Ground/finish brightness is tuned locally.

## Actual render review

Observer: Codex agent, Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4,
Steam Deck AMD Custom GPU 0405, private Weston, 1280 × 800. These are actual
engine captures, not source-reference images or concept renders. The nine
existing cameras retain their positions/targets; three close views were added
to the architecture trial without weakening its collision/access assertions.

| Observed defect | Correction and rendered check |
| --- | --- |
| Baseline paving repeats identical rounded procedural blocks. | Scanned 20–30cm setts at a 2m repeat add chipped edges, varied color and joint detail. Arrival/east/north views establish consistent scale. |
| Baseline plaster is mottled and timber reads as regular stripes. | Fine scanned plaster and cracked wood; grain follows posts/braces. Lodge and close facade reveal the finish in sun and shadow. |
| First texture pass becomes glaring with distant texture aliasing. | Reduced material gain, explicit mipmaps and anisotropic sampling; raised minimum paving roughness. Final north-facing paving retains individual stones without the earlier white glare. |
| Fountain bowls carry wall-sized brick joints; plain access steps clash with stonework. | Separate carved-stone finish on bowls/caps, entrance steps and ramp. Close fountain and pavilion views show material/contact continuity. |
| Flat leaf layers lose canopy volume. | More varied leaf angles, fuller clusters and olive/light/dark variation with restrained backlighting. Arrival and leaf close view show leafy silhouettes and shadows. |
| Dark covered timber loses grain; reduced shadow bias introduces fine stripes on terrain and stone. | Increased world fill, reduced sun slightly; restore the original bias values after close-view review. Covered/south views check grain, ground gradients and contact. |

[All final views and matching baseline links](../evidence/p22-t05/README.md)
include [arrival](../evidence/p22-t05/arrival.png),
[covered pavilion](../evidence/p22-t05/pavilion-covered.png),
[facade detail](../evidence/p22-t05/plaster-timber.png),
[carved fountain/paving](../evidence/p22-t05/paving-fountain.png) and
[leaf detail](../evidence/p22-t05/foliage.png). The rejected
[first texture pass](../evidence/p22-t05/first-pass-arrival.png) is labeled
separately. The original arrival/covered renders were compared directly with
these, and all twelve final views were inspected.

The low-bias experiment was rejected after fine striping appeared on the lawn
and stonework. A first partial restoration and lawn dithering did not resolve
it. Querying the pinned engine showed its normal-bias default is **2.0**;
restoring that removed the stripes. The original lawn palette/noise is retained;
the experimental dithering is removed. This is a corrected rendering defect,
not a passed intermediate candidate.

## Verification actually run

All checks below passed in this session. Full local logs are under
`.tools/p22-t05/`; durable result excerpts are in
[verification.txt](../evidence/p22-t05/verification.txt).

```sh
export GODOT_BINARY="$PWD/.tools/rename/godot-check.sh"
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
# Each existing graphical trial, sequentially, with an isolated launcher state:
# screen_color terminal_input terminal_pointer terminal_resize
# app_launcher application_objects application_transition
timeout -k 2s 90s "$GODOT_BINARY" --path "$PWD/world" --audio-driver Dummy \
  --max-fps 60 --script res://tests/terminal_input.gd
tools/check-chrome-application.sh
python3 world/tools/verify_village_materials.py
python3 tests/test_village_materials.py
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
node --test .opencode/tests/auto-continue.test.js
python3 world/tools/build_village_models.py
sha256sum -c .tools/p22-t05/model-hashes.txt
git diff --check
```

The existing private-Weston wrapper passes headless commands directly to the
pinned engine, runs GPU trials on the Deck, and supplies 1600 × 1000 for the
resize trial. Other architectural/terminal views are 1280 × 800; Chrome's
world-return image is 1000 × 700. It changes no host desktop service.
Final graphical `village_architecture`, `outdoor_startup`, `screen_color` and
real Chrome trials were rerun after restoring shadow bias and the lawn finish;
see `final-visual.log` / `final-*.log`. Import/default startup also passed on
this final state through the Chrome helper. Headless architecture/landscape/
outdoor passes and the remaining interaction trials precede those last purely
visual parameter corrections; their geometry/input assertions are unchanged.

Results: both architecture modes pass sealed facades/fountain contact, pavilion
walking/cover and Home. Both landscape modes pass 24,178 samples, 337.8m walked,
14.39° maximum sampled grade and <6mm floor gap. Outdoor verifies empty startup,
real terminal launch, movement/Home, bounds, panel drag/rotation/cancel,
application/world return, terrain placement and cleanup. The seven dedicated
trials report zero failures. Real Chrome verifies trusted input/save, scrolling,
resize/reflow, world return, independent window identity and close. Eleven
Python tests (7 catalog + 1 launcher + 3 integrity) and 62 Node tests pass.
Asset hashes/bytes match provider metadata; rebuild hashes are identical.
Relative documentation links, Project 22 task parsing and diff checks pass.

Actual [terminal output](../evidence/p22-t05/application.png),
[terrain-supported panel](../evidence/p22-t05/slope-panel.png),
[browser input](../evidence/p22-t05/browser-input.png) and
[browser world return](../evidence/p22-t05/browser-in-room.png) were inspected.
These are real client frames, not replay or synthetic app mockups. Optional
libdecor/xdg-activation/icon-theme/cursor warnings remain environment warnings;
there were no script/shader errors, crash or leak markers. The integration
helpers built/staged the existing GDExtension; native source was untouched,
so no fresh full Meson suite is claimed.

## Limits and owner checkpoint

This is a coherent material/foliage/daylight pass within the selected version 2
architecture. It does not claim photorealism or exact reference matching: the
square still has sparse frontage, simple lawn and boundary masonry, broad
faceted distant ridges, stylized large leaf shapes and decorative water jets.
Scanned texture repetition remains visible across large uninterrupted paving.
No performance benchmark, human movement comfort or final owner art approval
is claimed. Tree source geometry is 29,040 triangles; eight instances bring
placed model triangles to 313,690 before LOD, plus terrain/access geometry.
Tracked texture JPEGs total 5,244,021 bytes; this is not GPU memory measurement.

The old source references, comparison page, both evidence sets and tags remain
unchanged. [The original comparison](../art-direction/compare.html) still shows
the two pre-T05 checkpoints. **Stop here. P22-T06 remains unchecked and requires
owner art review and explicit authorization.** No later task was begun.
