# Decision 09 — Godot 4.8 prerelease migration (2026-11-01)

The owner authorizes upgrading Elsewhere to the available 4.8 prerelease and
adopting features useful to the existing project, with a later stable update.
This bounded engine migration supersedes Decision 06's stable-engine pin and
the prior stop instruction for this work only. It does not authorize another
village milestone, native-session installation or human acceptance claims.

Pin **4.8 beta 2**, official commit `cafc17a19`, using the upstream release
archive SHA-256 and separately recorded extracted executable SHA-256 in
`tools/godot-toolchain.json`. All launch/check defaults use `tools/godot`.
`GODOT_BINARY` remains an explicit comparison override. Bootstrap uses only
repository-local tools/cache, rejects checksum failures, supports offline reuse
and preserves existing binding checkouts. Never follow a floating beta/latest URL.

Keep godot-cpp revision `507ed9d840c01a3c5b2a39af8bb4000bfac30bf5` and its 4.7
extension API: the compositor uses no new native API. Validate this existing ABI
against the beta with full binding/lifecycle tests. GDScript may use 4.8 APIs;
the active project therefore requires 4.8. The owner additionally requests
**Forward+ as the default**, targeting capable desktop hardware. Preserve desktop
ownership boundaries, headless/nested paths and Elsewhere identifiers. Revalidate
application color compensation and world rendering under Vulkan/Forward+.
Disable automatic OpenGL fallback rather than silently lose streamed textures
and lighting. Headless operation remains available without a graphical GPU.

Adopt reusable typed physics query results in outdoor navigation and panel
placement/picking, preserving masks, exclusions and query limits. Results can
retain old data after misses: branch on query success before reading them and
test alternating hits/misses. Add fuzzy name matching to launcher search after
existing exact name/description/keyword matches, retaining desktop IDs and
unavailable-entry behavior. Use bounded font fitting for recent-app titles.

Use 4.8 contact shadows on the village sun and multi-bounce occlusion with
restrained SSAO. Import the nine world maps as high-quality BPTC streamed
textures with a 256 MiB budget; retain full-resolution live client ImageTextures.
Keep the existing Filmic exposure/white contract, adapting its inverse lookup
for Forward+'s linear albedo. Repair the sky's Vulkan noise/color discontinuities.
No feature flag alone establishes a benefit: inspect rendered comparisons and
retain a feature only when applicable and verified. Retain the
existing import/shutdown and SDL workarounds unless repeated checks establish
that they are no longer needed.

For the stable update, change the engine identity/URL/hashes in the lock after
checking the official release; repeat bootstrap, import, native/binding, query,
navigation, launcher, live desktop and render checks. Update godot-cpp only if
required by a native API change or a demonstrated compatibility problem.
Record evidence and limitations in the migration handoff before completion.

Sources: [beta 2 release](https://godotengine.org/article/dev-snapshot-godot-4-8-beta-2/),
[4.8 features](https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/),
[official release assets](https://github.com/godotengine/godot-builds/releases/tag/4.8-beta2).
