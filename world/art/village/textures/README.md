# P22-T05 village finishes — Poly Haven

Selected and downloaded 2026-10-11 by the Codex agent, after inspecting the
live texture catalog, provider metadata and the actual diffuse maps. All three
sets are by **Rob Tuytel**, provided by [Poly Haven](https://polyhaven.com/).
Assets are [CC0](https://polyhaven.com/license), under
[CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).
Owner reference JPEGs are not material sources.

| Set / source | Runtime use and scale | Selection reason |
| --- | --- | --- |
| [Cobblestone Floor 08](https://polyhaven.com/a/cobblestone_floor_08) | Square and existing routes; 2m × 2m repeat | Worn, irregular gray/beige setts and mossy joints replace uniform procedural courses. |
| [Grey Plaster](https://polyhaven.com/a/grey_plaster) | Lodge/hall plaster; 1m × 1m repeat | Fine matte pores and discoloration fit the selected weathered reference. |
| [Rough Wood](https://polyhaven.com/a/rough_wood) | Timber/planks; 0.5m × 0.5m repeat | Outdoor cracks/grain fit aged structural timber better than the study's walnut veneer. |

The authoritative [shared manifest](../../../assets/manifest.json) has entries
with `usage: P22-T05 village`: source/metadata URLs, author/license, dimensions,
exact CDN URLs, provider bytes/MD5, locked SHA-256, cache and runtime paths.
Original 1024 × 1024 JPEGs are tracked here, byte-identical to the downloads;
there is no resizing, conversion tool or new dependency. Nine files total
5,244,021 bytes. Ignored originals live in `world/assets/cache/village/`.

Diffuse is sampled as sRGB (`source_color`); OpenGL +Y normal and red-channel
roughness are linear data. No DirectX normal inversion, height-as-normal, AO
packing or displacement. Import is lossless with mipmaps; shaders request
anisotropic mip filtering. Data stays at 1K. Disk size is not GPU memory usage
or a performance measurement. Shader palette/roughness adjustments are explicit:
paving is darkened and roughness clamped to 0.85–1; plaster/wood luminance
modulates the selected palette, with normal strengths 0.35/0.55. Ground normal
strength is 0.65. Beam UVs run along each post/brace. Fountain, masonry, roofs,
foliage and grass retain original repository shaders/geometry.

No network is needed for import or runtime. From the repository root:

```sh
python3 world/tools/verify_village_materials.py
python3 tests/test_village_materials.py
tools/validate-godot-project.sh
```

Missing/corrupt files fail verification with the path and recovery instruction;
there is no accepted fallback. Restore the named tracked file from the current
revision, or download its manifest URL using the existing
`world/tools/fetch_assets.py:atomic_download` helper into a temporary/cache path,
check provider size/MD5 and locked SHA-256, then copy it here and verify again.
Do not refresh hashes to bless a changed remote file. The fetch helper uses
finite retries and atomic writes. API requests during selection used an
Elsewhere User-Agent and sequential cached metadata; the helper now also
identifies itself as Elsewhere. The official
[API](https://api.polyhaven.com/) and
[service terms](https://github.com/Poly-Haven/Public-API/blob/master/ToS.md)
were reviewed on the acquisition date. Attribution is visible here; no live API
browser/service was added to the application.

See [handoff 45](../../../../docs/handoffs/45-village-materials.md) for actual
in-world multi-angle renders, observed defects/fixes and verification. These
maps do not alter the separate historical study assets or close their gates.
