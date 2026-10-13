# Elsewhere architecture transition

Project 22 separates desktop services from physical locations incrementally;
see [Decision 08](decisions/08-elsewhere-village-world.md). P22-T01 introduces
`world/scripts/desktop_runtime.gd`, a scene-owned Node that composes the existing
terminal/session owner, application mode, launcher, HUD, application objects and
transition. It owns window-close shutdown; its terminal child still owns the
native session, pump and launched application processes. No compositor or input
policy rewrite is involved.

P22-T02 replaced the study with an outdoor scene; P22-T03 adds its authored
landscape and circulation. `main.tscn` uses the same DesktopRuntime and controller.
`outdoor.gd` supplies its ready player, selected
preview/status nodes and a world-space placement-bounds callable. The selected
preview mesh is hidden by its parent: it retains the terminal's existing texture
and local visibility contract, while independent live panels provide the visible
world presentation. The startup/error status label remains visible when needed.
No study or hallway geometry is loaded by the default scene.
The outdoor DesktopRuntime sets `auto_start_terminal = false`: its compositor
and desktop services start normally, while initial client launch is optional.
The retained study keeps autostart enabled. `--terminal` / `--terminal-demo`
explicitly request a startup client; `--no-terminal` retains the geometry-only
path without a compositor.

P22-T07 adds a location-owned `pavilion_workspace.gd` child beneath the existing
pavilion model. Two fixed tables have physical placement pads and local
`WorkAnchor` markers; two stools reuse `pushable_furniture.gd`. Panels are placed
manually and supported through existing collision/gravity. No anchor registry,
automatic binding, compositor ownership, input policy or persistence layer is
introduced. The desktop services continue to receive only the location's player,
presentation nodes and placement-bounds callable.

The prior main scene is retained unchanged as `study.tscn`; `study.gd` still
supplies its physical monitor and hallway bounds when explicitly loaded.
Desktop services do not resolve physical room paths. Both locations expose
read-only service accessors for the existing tests. Application entity IDs and
runtime bindings remain unchanged and separate.

This is an initialization/lifetime boundary, not scene streaming or restart
persistence. The location still owns its geometry, collision, lighting, monitor
presentation nodes and capture viewpoints. The controller exports spawn
position/yaw/pitch, keeping its study defaults for the retained scene and using
the outdoor scene's authored values for startup and Home. The owner's jump
behavior remains unchanged. The supplied presentation/player must remain alive for the
desktop lifetime. The terminal retains its existing fixed monitor aperture and
Filmic-compensated shader contract. A future location must provide compatible
presentation and bounds deliberately.

`village_landscape.gd` owns only the site: a fixed height lattice, graded square,
four authored path centerlines, and a convex ten-section boundary bank. The
rendered ground mesh supplies the collision triangles. The paving shader marks
routes on that same surface, so no overlay collision or curb changes movement.
The location's placement callable insets the convex boundary by the whole panel
footprint and raises placement above sampled terrain; existing collision queries
still reject overlaps. The desktop services know nothing about the lattice,
paths or bank. No scene streaming, terrain engine, new dependency, or application
identity change is introduced.

P22-T04 adds a sibling `Architecture` node. `village_architecture.gd` places five
original imported GLB models at fixed sites, grounds their foundations using the
landscape height function, and creates static mesh collision on the existing
world collision layer. Terrain-fitted entrance steps and the pavilion ramp are
local geometry. The three buildings are sealed exteriors; the pavilion is open.
No controller, desktop service, application identity, placement policy or native
compositor change is required. Models and reproducible authoring source are
recorded in [the asset provenance](../world/art/village/README.md).

The owner's 2026-10-11 courtyard revision retains those five structures and adds a
sixth architectural model: a decorative timber link above the north approach.
`village_materials.gd` applies shared finish rules to imported mesh surfaces;
`village_surface.gdshader` supplies original meter-scale grain and joints.
A sibling `Garden` node, owned by `village_garden.gd`, places eight fixed trees
on the existing terrain. Only tree trunks have cylinder collision; leaves and
branches are decorative. Architecture and trunk bodies share the existing
terrain-test exclusion group; normal walking and placement still see their
collisions. The paving change is visual on the same ground mesh. No new
runtime service, identity, input or persistence boundary is introduced.

Reference 2 (owner comparison request, 2026-10-11) removes the active timber
link and adds a `MountainBackdrop` sibling. Its script applies one original
height/slope material to the distant imported mesh; it has no collision or
runtime ownership. The sky shader supplies fixed cloud cover. Surface shaders
add weathering and decorative water ripples; exposure and client shaders stay
unchanged. Boundary UV/material changes preserve its exact mesh/collision.
All scene selection remains the existing `main.tscn` path; Git snapshots and
separate captures preserve comparison without a new runtime theme system.
See [handoff 44](handoffs/44-village-reference-2.md).

P22-T05 keeps that scene boundary. The shared finish mapper binds three curated
Poly Haven texture sets; the ground shader samples the paving set on its existing
meter UVs. Beam UVs follow the grain; access surfaces reuse the carved-stone
shader without changing collision geometry. Leaf geometry/shading, world fill
and directional shadow settings are local art changes. Application shaders,
Filmic exposure and desktop/runtime ownership remain unchanged. See
[handoff 45](handoffs/45-village-materials.md).

P22-T08 keeps the existing `MountainBackdrop` and adds a `Surrounds` child using
`village_surrounds.gd`. It constructs a small foothill ring from the existing
landscape boundary/crest data and one deterministic MultiMesh of distant firs.
Two painted path glimpses and local mountain haze imply terrain beyond the
square. These nodes have no collision, world entities, application bindings,
input handlers, shadow passes or per-frame script work. The playable boundary,
controller, desktop services and client lighting remain unchanged. This stays
within the location-owned presentation boundary; there is no terrain service,
new destination or global atmosphere affecting application content. See
[handoff 51](handoffs/51-village-atmosphere.md).

---

# Architecture: current prototype and target boundaries

## Current target: Decision 06

Project 21 replaces the custom visible renderer with a Godot world frontend,
while retaining the C++ libwayland-server core and headless protocol harness.
Godot owns the nested host window and scene; a GDExtension pumps the compositor
on its owning thread and provides owned CPU frame snapshots plus explicit seat
and configure commands. See [GODOT-INTEGRATION.md](GODOT-INTEGRATION.md).
The older snapshot choice in P4-T15 is superseded by P21-T11/T12. Subsequent
sections describe still-useful ownership boundaries, not an alternate work order.
Current recovery (2026-10-03): the Godot study renders imported furniture and
has a collision-based controller. The extracted C++ core now passes real fixture
socket/surface lifecycle, initial xdg-shell handshake and seat protocol checks
through Godot. Shared `seat.cpp` and `xdg-shell.cpp` are independent of legacy
input policy and rendering. Owned shm snapshots now pass byte-level Godot tests.
The study now pumps that runtime and presents changing real Weston terminal
output via ImageTexture (T41). T42 adds keyboard focus/delivery through that
runtime's seat and explicit world/application modes in Godot. T43 adds logical
pointer mapping, focused button/axis delivery and lifetime-tracked drag grabs.
T44 adds bounded xdg resize suggestions, committed geometry/size limits and
actual terminal reflow on host resize. Popup presentation remains open.
T48 adds a Godot application wheel/search overlay and a separate Python helper
for freedesktop metadata, installed icons and argument-vector execution. The
frontend still owns the compositor session and its launched child processes.
Only desktop-entry IDs persist in recents; PID/window associations are temporary.
This does not add a KDE service dependency or general application compatibility.
T65/T66 add a runtime-local logical output and a CPU surface-tree boundary in
`surface-tree.cpp`. Raw, synchronized cached and visible state stay compositor-
owned; Godot receives immutable composed toplevel snapshots with canvas origins.
Subsurface stacking and input regions route pointer events to the child while
world identities and keyboard focus remain associated with the root. The launch
helper supplies an isolated native-Wayland/software-rendering recipe for Chrome.
See [the graphical application handoff](handoffs/37-graphical-applications.md).
The Firefox repair adds an isolated persistent Firefox profile, Wayland forcing
and launcher reuse of its associated live window. `data-device.cpp` is owned by
the shared seat, providing GTK's required data-device global and focused
clipboard FD transfer. Shell launch policy remains in Godot/Python; protocol
ownership and source/offer lifetimes remain in C++. No host clipboard or D-Bus
access. See [handoff 52](handoffs/52-firefox-launch.md).
Godot maps physical US keys; the seat owns XKB and held-key state, filters events
to the focused client, and clears focus on destruction.
The original addon is isolated
because registration crashes. A separate standard-binding regression establishes
the binding boundary, reused by the study's `elsewhere_runtime` addon. See STATUS.md
for current evidence.

## Supplied prototype

Status: target design for incremental changes, not a claim of implementation.
Current legacy source uses C++20, Meson, libwayland-server, a nested Wayland
host window presented by PBuffer readback/shm, EGL/GLES2, and a headless test path.
The owner confirmed narrow navigation/orientation fixes on 2026-10-02; broader
terminal usability remains unverified (see handoffs/04-host-window.md). `src/display.cpp` currently combines host
setup, GPU resources, camera/panel presentation, and room rendering. Separate
these through bounded tasks; retain working behavior throughout.

## Responsibilities

| Subsystem | Owns | Must not own |
| --- | --- | --- |
| Compositor | Protocol objects, pending/current surface state, buffer lifetime, configure sequence, seat delivery | Persistent placements, reminder semantics, furniture |
| Runtime presentation | Live-window handles, surface-tree view, logical size, scale/transform, damage, GPU imports/textures | Persistent identity or automatic process-to-artifact guesses |
| World model | Stable entity IDs, room IDs, parent-relative transforms, slots, movable furniture, door state | Wayland resource pointers, GL IDs, process lifetime |
| Desktop shell | Resources/artifacts, launch recipes, associations, focus policy, search, navigation, reminders | Wire protocol implementations or direct GL calls |
| Renderer | Mesh/material instances, application presentation, picking, lighting, render scheduling | Destruction of client protocol objects or database writes |
| Host backend | Nested window/output, EGL context lifecycle, host input/focus/resize, headless output | Artifact identity and client-launch policy |
| Persistence | Versioned schema, transactions, migrations, durable references | Restoration of Wayland connections or arbitrary application memory |

These are boundaries within one executable, not a requirement for services,
threads, an ECS framework, or speculative plugin interfaces. Map existing code
to them, introduce the smallest adapter required by the next interaction, and
document the owner of every new handle.

## Identity and lifetime

- A **resource** references a normal file/URI or an explicit launch recipe.
- An **artifact** is a durable spatial representation of a resource, with a
  stable UUID, room/parent IDs, transform or slot, and presentation metadata.
- A **world entity** represents a desk, shelf, door, monitor, or other object.
  Stable IDs belong to data; mesh filenames and furniture labels are not IDs.
- A **live window** is an ephemeral binding to a connected application surface
  tree. Use an opaque runtime handle with invalidation/generation semantics.
  Internal compositor callbacks may use resource pointers with tracked lifetime;
  persistence and world code must not store those pointers.
- A **render snapshot/lease** exposes renderable content with explicit lifetime,
  dimensions, scale, transform, damage, and coordinate mapping. Choose its
  representation during P4-T15 rather than inventing an API in this document.

A client exit invalidates its runtime binding and focus, releases imports and
textures safely, and leaves the durable artifact in an inactive state. Reopening
can create a new binding; app ID, title, and PID are hints, not proof of instance
identity. Let the user assign ambiguous windows. A client process may own many
windows, and closing one window must not terminate all of them.

Screenshot tests may retain an explicit bounded snapshot. They must not keep
dead Wayland resources alive or grow an unbounded orphan list. An inactive
artifact is not evidence of a still-running application.

## Presentation and input

World mode uses camera movement, targeting, and object selection. Application
mode shows the chosen surface tree at a readable size inside the host window;
it does not inherently require scanout or client-requested fullscreen.
Keep application pixels unlit and protect text from scene post-processing.

For an in-world hit, map the ray intersection to panel UVs, then to logical
surface coordinates, accounting for content aspect ratio, window geometry,
buffer scale/transform, and any letterboxing. Use the same tested mapping for
full-size input. Deliver focus/enter/leave and release held keys/buttons during
mode/focus changes. The compositor sends protocol events; the shell chooses
the target. Related popups/subsurfaces follow their parent and remain usable.

## Graphics and assets

This paragraph describes the legacy renderer only; Decision 06/Godot is the
current visual implementation target. For legacy maintenance, continue with
EGL/OpenGL ES. GLES2 remains the baseline until a measured GLES3
experiment and decision justifies change. Blender exports glTF/GLB; implement a
documented subset first, with named limits for meshes, materials, textures, and
lights. Start with ambient/directional lighting. PBR, shadows, skeletal
animation, physics, and navigation libraries are later capability choices,
not immediate dependency requirements. Record asset provenance and licenses.

## Navigation and reminders

Search resolves an artifact's current room/world transform. A navigation graph
or navmesh supplies a route; emissive geometry presents it. Door state changes
route availability. Search and teleport remain available without walking.

Reminder data owns due time, timezone, recurrence, acknowledgement, and snooze.
The notification/list and optional creature are presentations of that data.
Creatures may navigate toward the player in world mode; they must not capture
application input, hide unsaved-work dialogs, or make deadlines inaccessible in
application mode. Persist deadline state independently of animation state.

## Decisions and non-goals for recovery

Decision 02 remains the implemented stack; Decision 05 reopens its suitability
assessment. A small wlroots experiment compares host backend, buffer import,
surface trees, and input integration while preserving the custom spatial shell.
Neither a successful experiment nor this document authorizes a wholesale rewrite.

Native session support, Xwayland client support, portals, multiple displays,
locking, and broad compatibility retain their later roadmap gates. No protocol
version may be advertised solely because generated headers support it; expose
only behavior that has been implemented and tested for that version.
