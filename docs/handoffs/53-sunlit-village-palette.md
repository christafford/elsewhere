# Sunlit village palette — owner art revision

2026-10-13, based on `a597286`. The owner reported drab colors and requested
alignment with [art-direction-1.jpg](../art-direction/art-direction-1.jpg).
This authorizes this bounded art revision under Decision 08; it advances no
P22 task and does not authorize P22-T09 or human P22-T10.

## Interpretation and implementation

Warm terracotta courses replace dark slate; plaster becomes cream, exposed
joinery honey-brown and carved stone sandy limestone. Meadow/ivy/tree colors
become fresher greens, balanced by a clearer blue sky and cool blue mountain
haze. Local weathering is restrained, while the existing licensed scan grain,
normal maps and roughness remain. Four small pink/amber/orange flower borders
sit beside the facades. Sunlight warms slightly, with restrained sky fill.
Exposure/tonemapping and application materials are unchanged.

The existing `village_materials.gd` mapping owns architectural colors. Named
material roles, existing GLBs and all nine curated texture maps remain intact;
no import-time rewrite or new palette service. Ground, foothill, mountain and
sky shaders change colors only. Boundary-bank/access-step finishes follow the
same stone palette. No terrain/route/collision/placement math changes.

The sole new model is an original 3,264-triangle flower border, built by
`build_village_flowers.py` using the existing deterministic standard-library
model writer. Four .8-scale instances add 13,056 placed triangles before LOD.
They have no collision, processing loop or service ownership. Tiny flower
shadows are disabled to avoid disproportionate directional-light passes; dark
soil patches provide visual contact. See [provenance](../../world/art/village/README.md).
No external dependency or asset download. The owner image is retained unchanged
as a reference, not used as texture or passed off as an application render.

The compositor, Firefox recipe, launcher, input, desktop modes, entity IDs,
pavilion furniture, collision and scene entry points are unchanged. All work is
in location-owned finishes, garden decoration and the art/evidence documents.
The previous look remains reproducible at `a597286`; do not reset history or
revert intervening desktop fixes to compare appearances.

## Visual iteration

Fresh baseline and final views use the exact cameras in
`village_atmosphere.gd`, at 1280×800. The initial palette-only pass made leaves
and cream highlights too bright; lower material values, reduced leaf backlight
and slightly lower sun energy restored texture/shaded detail. Close architectural
renders exposed the need to match formerly gray access steps and stone banks.
The flower recipe was refined into distinct pink/amber/orange clumps. An initial
cost sample showed 96 extra draw calls in square-facing views; disabling their
microscopic shadows reduces this without changing the useful geometry.

This follows the reference's color relationships within the existing scene; it
does not claim its photographic foliage density, building enclosure or exact
roof silhouette. Low-detail distant trees and the large existing stone bank
remain visible. No global color filter touches live application pixels.


## Verification and limits

All checks were run by the agent on 2026-10-13. Godot 4.7.2, Compatibility/
OpenGL3.3, NVIDIA RTX 3080/615.78.08, private Weston 15.0.1 headless GL/fake-seat
output at 1280×800 (1600×1000 for the existing resize fixture). Firefox 157.0.1,
Weston terminal 15.0.1 and Vim 9.2. The host Firefox remained running.

- Import/script/default startup and native extension build pass; nine existing
  curated texture hashes verify offline. No C++ or bridge behavior changed.
- `tools/check-godot-architecture.sh`: headless and graphical model/collision,
  pavilion access/work-pad clearance and Home checks pass. The final refinement
  only changes the decorative flower colors/shadows; its import, atmosphere
  and architecture capture-only runs also pass.
- `tools/check-godot-atmosphere.sh`: baseline and final headless/graphical runs
  pass geometry budgets, unchanged empty startup and exterior-only surroundings.
  Seven matched final renders plus material/foliage/pavilion close views were
  inspected. No new obvious clipping or lost routes in these samples.
- Six existing default graphical checks pass: screen color, keyboard/repeat,
  pointer/scroll, resize, launcher and transitions. Exact gray/RGB screen colors
  are retained; lighting does not tint client pixels.
- `tools/check-godot-village-applications.sh`: real Terminal/Vim continuity,
  walking/manipulation/focus/close pass; 22 background frame revisions and the
  same shell/unsaved buffer survive the visit.
- `tools/check-godot-pavilion.sh`: real terminal placement, stool move/rotate/
  cancel and same-shell revisit pass with 50 background revisions. The final
  workspace and application renders remain readable.
- `tools/check-firefox-application.sh`: real Firefox typing, clipboard, click,
  world return, launcher reuse, additional windows, confirmed close and profile
  relaunch pass. The fresh relaunch render was inspected.
- Python suite: 14 tests; Node/plugin/parser suite: 62. Flower generation is
  byte-identical; Python syntax, changed-document links, unchanged roadmap
  checkboxes and diff validation pass. No new assertion mirrors palette values.

[Evidence](../evidence/sunlit-village/README.md) includes before/after pictures,
initial iterations, commands and logs. The final flowers add 24–32 draw calls in
square-facing views, rather than 96 with their shadows. Other sampled counts
are unchanged. Final median frame times range 16.644–16.684ms; p95 is at most
17.187ms. These 120-frame-per-view samples are vsync-bound host checks, not
sustained load, Steam Deck evidence or completion of P22-T09.

The scene-only scope did not require a fresh full Meson/native suite. Chrome and
the retained study's source asset cache remain unavailable, so no fresh passes
for those broader fixtures. No owner visual approval or human comfort claim.
The updated brief records the requested direction; the owner judges the result.

Next: stop after this art revision. Restart Elsewhere to load the new scene;
P22-T09 and P22-T10 remain unchecked.
