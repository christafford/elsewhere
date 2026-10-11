# Original study details

`fern.svg` and `ginkgo.svg` are original vector illustrations authored for
Elsewhere on 2026-10-05. No external source, download, font or runtime
dependency is required. The small source SVGs are tracked; Godot generates its
own ignored texture cache. `study_details.gd` constructs the original twin-tube
fixtures, wood frames, noticeboard and clock from measured geometry in meters.
The clock records local time when the room opens. Imported furniture remains
under the existing Poly Haven manifest; these additions do not change its
provenance or complete the broader asset-pipeline gate.

The 2026-10-08 hallway uses original joinery and revolved oil-lamp profiles in
`hallway.gd`: paneled leaves, architraves, brass knobs/hinges, oval wall plates,
reservoirs, open glass chimneys, burners and flames. `hall_carpet.gdshader`
authors burgundy wool variation in world meters without a downloaded bitmap.
Walnut and plaster reuse the existing verified Poly Haven photos; their source
provenance and hashes are unchanged. No new asset or tool dependency.

The 2026-10-08 exploration rooms add four original vector prints: `atlas.svg`
(an invented expedition map), `mechanism.svg` (a mechanical study), `stars.svg`
(an invented constellation chart), and `geometry.svg` (an abstract composition).
They are decorative artwork, not scientific/navigation references. No external
images or fonts are embedded. `elsewhere_rooms.gd` authors the fitted architecture,
turned worktables, map drawers, fountain, instrument pedestals, armillary rings,
sculptures, parts bins, tools and pendant fittings in meters. The star ceiling
is painted-ceiling-style geometry; `elsewhere_stone.gdshader` supplies floor tile,
grain and grout. Existing CC0 bookshelf, encyclopedia, chair, plant and desk-lamp
packages and walnut/plaster photos are instanced from the verified local cache;
no source downloads, new tools or dependencies were added. SVG sources/import
settings and procedural sources are small tracked assets; generated caches and
original large model packages remain Git-ignored.

T62's library bookcases and banker lamp are original authored geometry in
`antique_library.gd`, reusing those existing CC0 walnut and book assets.
Design reference: the owner's [Emma Mason Bordeaux black bookcase set](https://emmamason.com/emma-mason-essentials-bordeaux-4pc-bookcase-set-in-black.html),
whose cached retailer description specifies distressed black framing, honey-tone
wood interiors, vertical plank backs and metal pipe supports. Direct access
returned HTTP 403 on 2026-10-08; the description was available in search results.
A [Martin Toulouse bookcase photograph](https://www.myfurnituremarket.com/martin-furniture-bookcase/imte4094-662/iteminformation.aspx)
was inspected as a visually similar reference, not asserted to be the same item.
Neither retailer photograph is embedded, redistributed or used as a texture.
The eight movable bays use original dimensions, mouldings and arrangements;
this is an interpretation of the antique style, not a product replica.

The T64 grand foyer replaces the observatory. Its vault, columns, curved stair,
balustrades, compass inlay, rose window, chandelier and banners are original
procedural geometry in `world/scripts/grand_foyer.gd`; its ashlar/marble variation
is the original `foyer_stone.gdshader`. Walnut and potted plants reuse the existing
recorded assets. No new external asset or image-generation source was used.

P22-T04 introduces five original village GLB meshes, with reproducible Python
standard-library authoring source and tracked Godot import settings. See
[village model provenance](village/README.md) for dimensions, topology, checksums,
material/coordinate conventions and scope. No external assets or dependencies
were added; the retained study and its asset cache are unchanged.

The owner's 2026-10-11 courtyard revision adds original trees, flowers, curved
slate roofs, lattice windows and a timber link to the village set. All seven
models are reproducible from the included Python standard-library source;
`village_surface.gdshader` and the revised ground shader generate original
surface detail without downloaded textures. The owner-provided JPEG is a
visual reference only, with no pixels embedded in the runtime. See
[village provenance](village/README.md) and
[reference notes](../../docs/art-direction/README.md).


The second owner reference on 2026-10-11 establishes a reversible comparison
candidate: weathered timber/stone, original ivy geometry, a pointed turret,
tiered fountain with decorative water, and an original distant ridge/cloud sky.
`village_mountain.gdshader` blends rock/snow by height/slope; no photographic
pixels or new downloaded sources are used. Reference 1's source/art remains at
`340ca97` / local tag `art-reference-1`, and its evidence is unchanged. See
[comparison/provenance](../../docs/handoffs/44-village-reference-2.md).
