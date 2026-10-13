# P22-T08 — atmosphere and visual boundaries

2026-10-13, base `e063fba`. P22-T07 is the verified prerequisite. Owner scope is
P22-T08 only, under current AGENTS.md and Decision 08. Do not start P22-T09 or
another task. Preserve the unrelated untracked owner art image.

## Implementation boundary

The existing `village_backdrop.gd` constructs one local `Surrounds` child after
applying the mountain material to the imported backdrop. `village_surrounds.gd`
reuses the authored landscape boundary/crest data for an exterior foothill ring;
there is no duplicate playable terrain or new terrain service. Four authored
rises blend from the bank's outer shoulder and descend beneath the old distant
mesh. The original shader adds meadow/rock patches and two partly screened
track stretches. Mountain-local color haze softens the distance without changing
global exposure, fog, sunlight or application pixels.

One deterministic original GLB fir is instanced 144 times with varied scale/yaw.
Its 3,327 triangles form a trunk, separate drooping boughs, needle sprays and
narrow crown. Foothills add 1,680 triangles. Three opaque tree surfaces and one
terrain surface add four measured draw calls. No shadow passes, physics bodies,
per-frame scripts, runtime services, application identities or new destinations.
The compositor, bridge, desktop/input modes, launcher, scene entry point,
playable geometry and pavilion furniture remain unchanged.

Source and reproducible hash are in [asset provenance](../../world/art/village/README.md).
No dependency was added. Existing original GLBs and historical comparison
checkpoints remain unchanged. The first fir's coarse skirts were replaced after
actual render inspection; its capture is retained as superseded evidence.

## Verification and limitations

[The evidence index](../evidence/p22-t08/README.md) records seven reviewed final
GPU renders, four matched baseline images, raw counters, commands, host details,
initial test failure and its correction. The new helper checks headless budgets
and collision absence, then actual graphical instance positions and views.
MultiMesh transform readback is verified graphically because the headless dummy
renderer returns zeroed transforms. The existing assertions remain intact.

The bounded before/after sample adds four draw calls in every view, with median
frame times around 16.7ms and final p95 at most 17.251ms on an RTX 3080/60 Hz
Weston GL output. This is vsync-bound host evidence only, not sustained or target
hardware performance. It does not complete P22-T09 or human P22-T10.

Fresh final checks pass: import/startup/bridge build; headless/GPU atmosphere,
architecture, landscape and outdoor; pavilion placement/stool manipulation/shell
continuity; two-client Terminal/Vim continuity; six default-world graphical
interaction regressions; four headless transform/map/runtime checks; 11 Python
and 62 Node tests. Byte-identical model regeneration, shell/Python syntax,
documentation links/task parsing and diff checks pass. Seven final landscape
renders plus reactivated terminal/editor renders were inspected. Exact success
markers and outputs are retained in the evidence index.

The retained-study source cache and Google Chrome remain unavailable on this
host. Those broader fixtures are not claimed as fresh passes. No packages or
host-service changes; no new full native/Meson result or restart persistence.

Next task: **stop after P22-T08**. P22-T09 requires a separate owner request.
