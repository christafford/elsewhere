# Godot 4.8 beta 2 and Forward+ (2026-11-01)

Owner request: upgrade to the 4.8 prerelease and adopt useful features, then
explicitly switch the desktop target to Forward+. Base revision `f516db5`,
clean working tree. No numbered village task or human gate advances.
[Decision 09](../decisions/09-godot-48-prerelease.md) records the authority.

## Implementation

The official `4.8.beta2.official.cafc17a19` engine is pinned by release URL,
archive SHA-256 and executable SHA-256. `tools/prepare-godot.py` verifies local
acquisition, offline reuse and recovery; it preserves existing binding checkouts.
`tools/godot` resolves one lockfile for all launch/check defaults. The extension
uses its unchanged godot-cpp revision and 4.7 ABI, verified against this engine.
The historical Meson adapter now includes the supported build's generated C
interface instead of depending on a separate 4.7 engine source checkout.

The active project selects Forward+/Vulkan and disables automatic OpenGL
fallback. Headless operation remains available. The village sun permits 4.8
screen-space contact shadows; multi-bounce occlusion accompanies restrained
SSAO (0.6m radius, 0.7 intensity, power 1). The existing Filmic exposure/white
settings remain fixed. Nine material maps import as high-quality BPTC
`StreamedTexture2D`s with a 256 MiB residency budget. Source bytes, hashes, UIDs
and channel conventions are preserved. Client frames and launcher icons remain
full-resolution ImageTextures.

Forward+'s linear albedo initially broke the application screen's inverse-Filmic
lookup: the old shader rendered client gray 192 as 229. The shader now converts
the LUT's sRGB albedo before Forward+ tonemapping. The sampled grayscale and
RGB colors reproduce their client values exactly in the targeted GPU check.
The Compatibility branch remains for explicit historical comparisons.

The old large-multiplier sine hash produced angular cloud discontinuities and
patchy terrain under Vulkan. Active village shaders now share bounded noise;
the sky's color constants use source-color uniforms. Actual renders are the
acceptance evidence for these renderer-specific repairs.

All runtime direct-space queries in animal navigation and application placement
/picking reuse typed 4.8 result objects. Masks, exclusion lists, shape limits
and clearance thresholds remain unchanged. Callers branch on query success
before reading potentially stale results. Per-owner result objects are used
synchronously and never held across an await.

Launcher exact name/description/keyword matches stay first; 4.8 fuzzy name
matches follow in score order, retaining desktop IDs and disabled entries.
Long recent-app names fit within 12–15px and two lines, with ellipsis at the
limit. The underlying application selection/launch policy remains unchanged.

## Feature audit

| 4.8 area | Application to Elsewhere |
| --- | --- |
| Reusable physics query results | Adopted at every active navigation and panel direct-space query call site. |
| FuzzySearch | Adopted for approximate application names after exact keyword matches. |
| Label font fitting | Adopted for constrained recent-app wheel titles. |
| Contact shadows / multi-bounce AO | Enabled and compared under the owner-selected Forward+ renderer. |
| Texture mip streaming | Nine world maps stream with bounded residency; live desktop pixels remain resident. |
| Core property access, node removal and editor improvements | Supplied by the new engine; no duplicate project implementation. |
| Directional lightmap specular | No LightmapGI/baked directional lighting exists in the active scene; current lights are dynamic. |
| Alpha-coverage mipmaps | Active foliage uses opaque modeled leaves, not alpha-scissored texture cards. |
| Decals / animated decals | Current continuous path shader and mesh signage already serve the scene; no decal content to migrate. |
| Trail3D / VisualShader groups | Fountain water uses authored meshes/procedural shaders; no trail or visual-shader graph to replace. |
| Touch, UI sounds, sticky Tree items, TabBar sizing, SpinBox formatting | No corresponding active controls/content requiring migration; native application widgets belong to their real clients. |
| C# / mobile / XR features | No such target or language in the project. |

This is an audit of applicable features, not a claim that every engine feature
should be enabled. Sources: [4.8 overview](https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/),
[beta 2](https://godotengine.org/article/dev-snapshot-godot-4-8-beta-2/),
[rendering settings](https://docs.godotengine.org/en/latest/classes/class_projectsettings.html),
[reusable queries](https://docs.godotengine.org/en/latest/classes/class_physicsdirectspacestate3d.html),
[streamed importer](https://docs.godotengine.org/en/latest/classes/class_resourceimporterstreamedtexture.html).
API names were checked against the actual beta: Label uses `resize_font_to_fit`,
`minimum_font_size`, and `maximum_font_size`, rather than the earlier names in
the announcement. Generated API JSON alone omitted some inherited light
properties; runtime property inspection established their actual availability.

## Verification

Agent-run on 2026-11-01 against `f516db5` plus this migration. GPU trials use
private Weston/Wayland, NVIDIA GeForce RTX 3080, Vulkan 1.4.351, 1280×800
(1600×1000 for resize). Host desktop/services were not modified.

- Native build and **36/36** tests pass; full binding checks pass: 300 probe
  calls, 33 protocol trials, 16 frame/client trials and keyboard/pointer/resize.
- Engine import/startup and offline source-asset checks pass. Bootstrap has
  **6/6** unit tests, actual checksum-verified download, cached offline reuse
  and a fresh repository-local archive extraction trial. Launcher shell test
  **1/1**, desktop catalog tests **10/10**, continuation parser tests **62/62**.
- Reused query hit/miss/exclusion cases **4/4**, screen transforms **8/8**,
  keyboard cases **27/27**, pointer cases **302/302**, two-session runtime and
  headless/graphical outdoor boundaries **10/10** pass.
- Graphical client-color, fuzzy/duplicate/unavailable launcher entries, real
  Terminal/Vim interaction, transition, typing, pointer, four-size resize,
  Ghostty/Alacritty compatibility, help, village placement/travel/revisit/close
  and pavilion interaction checks pass. Animals remain active during typing.
- Head bob enabled/disabled/headless/graphical checks pass; normal/Shift speeds
  remain 4 m/s, Ctrl/M 1 m/s. Animal navigation passes four real-physics rebuilds
  in both modes, including new land/building, clearance and blocked-map cases.
  Twelve-animal behavior/crowding checks pass headless and Forward+ at seed 2214;
  maximum foot solver error is 0.001003 m, maximum step 0.01590 m.
- All **six** upstairs routes pass headlessly and graphically, including stair
  support/headroom, real-client placement, descent/ascent, the same shell and
  entity on revisit, resumed typing and normal close. Lodge landing and returned
  live-shell renders were inspected. No runtime assertion was relaxed.

Primary local logs: `.tools/godot-4.8-audit/upgrade-suite-complete.log` and
`upgrade-suite-remainder.log`; individual desktop logs are in
`/tmp/elsewhere-upgrade-check.m7p7LJ`. The aggregate runner initially hit a
non-executable existing head-bob script; it now invokes that script via Bash,
and the remaining stages were resumed explicitly. No test result was waived.
Native and parser logs are `native-tests.log` and `node-tests.log` in the audit
directory; animal and upstairs logs are `.tools/p22-t14/` and `.tools/p22-t12/`.

Actual final renders inspected: arrival/fountain/pavilion/lodge, long recent-app
titles, focused terminal, two live world applications and all five animal
species. The Vulkan cloud discontinuities are gone; world texture detail is
present at near and distant viewpoints. Matched lighting-off/on lodge images
show restrained contact shading while keeping the interior legible. The
comparison toggles SSAO and sun contact shadows together, not each feature in
isolation; this is not evidence of a separate multi-bounce speed/quality gain.

Matched captures/metrics live in `.tools/godot48-render/{baseline,final}/`;
`render-baseline-final.log` and `render-final-final.log` record the final pair.
Each view warms up 120 frames then samples 120 frames with a 60 FPS cap and
animals disabled; a headless stair test ran concurrently, with no other GPU
trial. The scene is unchanged between these two runs except the lighting toggle.

| Final sample | Median ms | p95 ms | Streamed bytes |
| --- | ---: | ---: | ---: |
| Arrival | 16.664 | 17.164 | 1,376,496 |
| Fountain | 16.674 | 17.144 | 2,162,928 |
| Pavilion | 16.665 | 17.080 | 5,308,656 |
| Lodge | 16.656 | 17.097 | 5,505,264 |

Lighting-off medians are 16.663–16.673 ms and p95 17.047–17.140 ms. Final total
texture allocations are 154.6–158.7 MB versus 147.4–151.5 MB with lighting off.
These short capped samples establish rendering/residency operation, **not** a
sustained performance comparison. All nine maps are actual StreamedTexture2D
resources and residency responds to viewpoint. Human comfort and target-device
performance remain unobserved; no human gate or village milestone advances.

Initial investigation exposed two test-environment/fixture issues:

- Retired `study_smoke`, `application_objects` and `application_gravity` fixtures
  load study art that is absent from this checkout's original source cache.
  Their attempts report missing assets; these are **not verified**. The migration
  runner keeps them behind `--include-study`, which prepares/verifies the cache
  before running. Active village placement, gravity and desktop tests remain
  required. No legacy test was weakened or historical art acquisition resumed.
- The stair waypoint helper pressed W before updating yaw. After a capture
  facing down the stairs, the first frame could step off the intended landing
  route at the newer walking speed. It now aims before sending W. Movement,
  collision, waypoint tolerance and live-shell assertions remain unchanged.

## Later stable update

Use the [toolchain procedure](../TOOLCHAIN.md) to update the engine identity and
hashes in the lock, prepare it, run native/binding/migration checks and inspect
renders. Do not change godot-cpp merely to match the engine's minor number when
no new native API is used. A rollback requires the prior source revision and
fresh import because new GDScript APIs and streamed textures require 4.8.
No background update service, host configuration change or remote push is added.
