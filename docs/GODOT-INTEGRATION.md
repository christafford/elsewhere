# Godot and the existing Wayland compositor

P22-T12 adds stairs inside the Lodge, Guildhall, Copper Kettle, Lantern Inn,
Library and Meadow Inn. Enter normally and follow the timber stair along the
right-hand wall to a usable second floor. Walk up/down without a jump or special
key. Guards surround the stair opening; Home still returns to the square.
Each upstairs room provides an ordinary teal-pad worktable. Existing application
launch, placement, world return, revisit and close controls are unchanged.
`tools/check-godot-upstairs.sh` runs headless and graphical stair/room/guard tests
and a real-terminal placement, downstairs/exit/revisit and same-shell trial in
all six upstairs rooms. Inspect actual captures in `.tools/p22-t12/upstairs`.
`world/tests/village_upstairs_views.gd` separately scans roof/canopy clearance
and captures final views; it does not establish walking/live-app behavior.
No human comfort or target-hardware acceptance follows from these fixtures alone.

P22-T11 adds ten furnished ground-floor destinations around the retained square.
Follow the cobbled lanes and walk through the open signed entries. Every new
destination has a fixed trestle worktable with the existing teal support pad;
launch, drag/release, leave/revisit and application controls are unchanged.
Trade artifacts are fixed decoration, not commerce/crafting interactions.
Upper stories are decorative and no people are present.
Run `tools/check-godot-expansion.sh` for headless/graphical lane and doorway
walking, support/enclosure checks and a real-terminal placement/revisit trial in
all ten rooms. `world/tests/village_streets.gd` captures fourteen eye-level street
views. Both require actual render inspection for visual acceptance; the test
prints no human-approval or target-hardware claim.

P22-T08 adds decorative wooded foothills, distant path glimpses and local mountain
haze outside the existing playable bank. Run `tools/check-godot-atmosphere.sh`
for headless geometry budgets, graphical instance-boundary checks and seven
matched 1280×800 views with rendering counters. Actual renders still require
inspection. See [evidence](evidence/p22-t08/README.md); the cost sample is a host
before/after comparison, not P22-T09 or Steam Deck acceptance.

Current startup: P22-T04 adds a landmark, three buildings and covered pavilion
to the authored square, terrain and approach paths
using the desktop runtime extracted in P22-T01. The selected-preview mesh remains
a hidden texture adapter;
live application panels provide the visible world presentation. Startup is empty
but the compositor and launcher are ready; Tab opens Applications.
`-- --terminal` or `-- --terminal-demo` explicitly starts an initial client.
The study is retained in `scenes/study.tscn` for explicit launch and geometry
regressions.
The owner's 2026-10-11 [courtyard revision](handoffs/43-village-reference-alignment.md)
refines the architecture, paving and planting through scene-local geometry and
materials; desktop ownership and input contracts are unchanged.
The [reference 2 revision](handoffs/44-village-reference-2.md) established the
current architecture and ridge/cloud backdrop. The owner's subsequent
[sunlit palette revision](handoffs/53-sunlit-village-palette.md) adds warm clay
roofs, cream plaster/oak, fresher vegetation and four decorative flower borders.
Its runtime/inputs are unchanged; the earlier reference 1 remains preserved
for comparison at `art-reference-1`.
See [the architecture handoff](handoffs/42-village-architecture.md),
[the landscape handoff](handoffs/41-village-landscape.md) and
[the outdoor startup handoff](handoffs/40-outdoor-startup.md).

P22-T06 adds a continuous real Terminal/Vim trial in the default village:
search launch, independent panels, committed drag/rotation, a walk down the
south approach and back, preserved running state, focus and client-owned close.
Run `tools/check-godot-village-applications.sh` with a graphical display and the
installed applications. It reuses the existing runtime/input paths; no new
compositor or lifecycle architecture is introduced. See
[handoff 46](handoffs/46-village-applications.md) for evidence and limits.

P22-T07 furnishes the pavilion with two fixed worktables and two movable stools.
Walk up its north ramp, stand behind a table looking toward the square, launch
an application with Tab, return with Ctrl+Alt+Escape, and drag the panel above
the teal pad. Release to let the existing panel gravity place it on the table.
Stools use the existing drag/wheel/both-buttons rotation controls. WorkAnchor
markers describe physical pad tops only; apps keep their session-local entities
and bindings. Run `tools/check-godot-pavilion.sh` for the real-terminal placement,
stool manipulation and walk-away/revisit trial. See
[handoff 50](handoffs/50-pavilion-workspace.md).

The owner's 2026-10-14 revision opens all three building ground floors. Walk
through the open front doorway via its stone ramp; no interaction key is needed.
The Lodge and Guildhall face the square; the Workshop entry faces west. Each
room has two fixed worktables and movable stools using the pavilion controls.
Launch with Tab, return with Ctrl+Alt+Escape, then drag an application above a
teal pad and release. Rooms and furniture retain the existing session behavior;
upper floors are decorative. `tools/check-godot-interiors.sh` checks headless
walking/enclosure and graphical real-shell placement, exit, revisit and close
in every building. Inspect its actual captures in `.tools/village-interiors-test`.
See [handoff 54](handoffs/54-building-interiors.md).

The following records the integration developed under Decision 06 / Project 21.
The Godot study now renders real furniture and supports movement (P21-T36).
The legacy `--room-camera` executable remains separate. The experimental
compositor addon is preserved but ignored because it crashes during registration.
The standard binding probe (P21-T37) is isolated under `tests/godot-binding/`.
The standard binding serves real wl_compositor/shm clients (T38), including
xdg-shell configure/ack/commit and seat v1/v4 keyboard setup (T39).
Owned frame transport now passes exact client-byte tests through Godot (T40).
The study now starts that server and displays real Weston terminal output (T41).
T42 adds real keyboard input and a flat application view; T43 adds text selection
and pointer/scroll routing. T44 adds real client resize through xdg configure.
T65/T66 add a logical output, real Chrome startup and software-rendered subsurface
composition with child hit testing. Runtime seat v5 pointer frames enable browser
scrolling; the legacy renderer retains v4. See the
[graphical application contract and evidence](handoffs/37-graphical-applications.md)
and [STATUS.md](STATUS.md).

## Build and ownership

Review item 1 (2026-10-12) retired the unused `elsewhere_bridge.h/cpp` C bridge.
Its enumeration reassigned 32-bit serials, but neither Meson nor the current
Godot binding built that implementation, and it had no callers. The supported
`ElsewhereCompositorSession` uses positive 64-bit surface handles assigned once
at creation; enumeration does not mutate them. Destroyed handles are invalid
and never reused within the server process, including session restarts.
They identify surfaces, not application instances or persistent artifacts.
The world's random `entity_id` remains a separate session-local identity;
recreated windows and restart restoration are not automatically associated.

`tools/build-elsewhere-extension.sh` now delegates to `build-godot-runtime.sh`
with no arguments; the old build-directory argument is explicitly rejected.
The historical standalone `src/godot` CMake configuration reports retirement
and directs callers to the supported build. Meson's separate experimental
adapter and ignored addon remain unchanged apart from removing an unused header
include. See [review evidence](handoffs/47-surface-identity-review.md).

Pin a stable Godot release and compatible godot-cpp revision. Start with the
least complicated renderer that passes the visual target on the Steam Deck;
compare Compatibility and Mobile using actual scenes, driver support and
measurements. Don't depend on a RenderingDevice in a renderer that lacks it.
Put the engine project in `world/`, core library in an appropriate C++ source
boundary, adapter in `src/godot/`, and bootstrap/check commands in `tools/`.
The tested `ElsewhereCompositorSession` owns the reusable server and protocol state;
`tools/check-godot-binding.sh` exercises it from a fresh isolated Godot project.
The shared `seat.cpp`/`xdg-shell.cpp` protocol library has no legacy display or
camera dependencies. Legacy input policy remains in `input.cpp`; its global
seat wrapper is separate from each runtime's seat. See
[protocol handoff](handoffs/18-godot-window-protocol.md) and
[frame contract](handoffs/19-godot-owned-frames.md) for ownership and limits.

`tools/build-godot-runtime.sh` stages the same tested library in the world's
`addons/elsewhere_runtime/`; the run/import helpers invoke it automatically.
`desktop_runtime.gd` composes the desktop services independently of room
construction and handles window-close shutdown. The location supplies a ready
player, screen mesh/status label and placement-bounds callable. Its child
`terminal_screen.gd` owns a session, its initial terminal and additional
launcher-owned child processes; its existing shutdown and forced-removal cleanup
remain the resource-lifetime authority. See the
[P22-T01 handoff](handoffs/39-desktop-runtime-extraction.md).
It chooses from `toplevel_handles()` and calls `snapshot(handle, after_revision)`
to avoid unchanged pixel copies. The monitor applies inverse buffer transforms,
fits the logical aspect ratio, and clears content on detach/destruction.
The unshaded screen shader compensates for the study's fixed Filmic tone curve;
this is tested for Compatibility at exposure/white 1, not a general renderer
color-management solution. See [live output handoff](handoffs/20-godot-live-terminal.md).

`app_launcher.gd` opens in world mode with Tab or the Applications button. It
suspends camera/application input while its modal wheel/search owns focus.
Eight radial slots use the vendored Advanced Radial Menu; a Python helper reads
GIO desktop entries and GTK icon themes asynchronously. Search text only filters
metadata; launch resolves a desktop ID again and execs argv with the private
display environment. `Terminal=true` uses Weston and an exec wrapper. The
launcher serializes pending launches and selects a newly mapped window; this
initial candidate association is not durable identity or complete multiwindow
matching. Launcher selections start fresh instances except native Firefox: it
uses a persistent repository-local profile and returns to its mapped window.
Ctrl+N inside Firefox creates additional windows. If only an unassociated
browser-created window remains, the launcher asks the user to select it in the
world instead of starting a competing profile owner. Live labels map window
handles to desktop IDs, while recents deduplicate by desktop ID.
Verified successful launches populate eight persistent desktop IDs.
See [Decision 07](decisions/07-application-launcher.md) for dependencies and limits.

`application_mode.gd` implements explicit shell policy: Enter activates the live
terminal, Ctrl+Alt+Escape returns to world, and host focus loss clears activation.
Its TextureRect shares the monitor's current texture, displays native pixels
when they fit, and bypasses the 3D world environment. `keyboard_map.gd` maps
physical US Godot keys to Linux evdev codes. `application_transition.gd` uses a
live shared-material 3D proxy for 220ms entry/return, then hands off to the flat
view. It changes presentation only: player/world transforms and compositor
ownership remain untouched. Keyboard focus starts immediately; pointer input
waits for the native endpoint. Cancellation restores the world's visual nodes.
The runtime resolves only live,
mapped toplevel handles for `focus_keyboard`, `keyboard_focus_handle` and
`keyboard_key`. `seat.cpp` owns XKB, held keys, focused-client routing, late
keyboard enter and a surface-destroy listener. Duplicate presses are suppressed;
the Wayland client repeats using the advertised rate/delay. See
[keyboard handoff](handoffs/21-godot-terminal-keyboard.md).

`pointer_map.gd` derives the actual drawn rectangle from the flat TextureRect and
maps it to committed logical dimensions. The image is already upright; scale
and rotation must not be applied a second time. `application_mode.gd` routes
motion, Linux button codes and scroll through that session, with no world or
margin clicks. The seat owns focused-client delivery, bounded held-button state,
implicit grab and destruction cleanup. Mode/focus exit releases buttons before
leave. See [pointer handoff](handoffs/22-godot-terminal-pointer.md) for exact APIs,
validation and limitations. Client cursors and popup menus remain unsupported.
The Firefox repair adds seat-owned `wl_data_device_manager` v1: focused clients
can exchange declared clipboard MIME types through FDs, and stale offers lose
read authorization after focus/selection changes. Source destruction clears the
selection; no host clipboard, persistent clipboard manager or drag/drop support
is claimed. This global also enables GTK to initialize its input seat. See
[Firefox evidence](handoffs/52-firefox-launch.md).

`request_resize(handle, width, height)` suggests a bounded window-geometry size
through xdg configure; the client chooses when/what to commit. `window_state`
exposes committed geometry/limits separately from sent/acked/committed serials.
Both frontends apply xdg metadata after surface state. The Godot viewport follows
the host size; application mode debounces resize, reserves UI/shadow space and
allows for client size increments. Old pixels and logical pointer mapping remain
valid until the client commits. No texture scaling is treated as a client resize.
See [resize handoff](handoffs/23-godot-terminal-resize.md) for API bounds,
configure backpressure, native-pixel evidence and unsupported cases.

Godot owns the visible host window and frame loop. GDExtension owns one compositor
instance with explicit start/pump/stop. Use a nonblocking pump on the owning
thread with a measured work budget to avoid starving rendering. Use one owner
for Wayland callbacks, client resources and shutdown; engine cleanup must not
invoke a callback after destruction. Keep the standalone headless executable
for existing tests. Avoid pulling the old host-window GL renderer into the
extension merely to reuse a texture: separate protocol/core and presentation.

## Minimum frame contract

Provide an opaque live-window ID with generation, logical size, buffer size,
format, stride, scale/transform, frame revision, damage and an owned pixel
snapshot. Expose no raw Wayland pointers to GDScript. Validate overflow, buffer
bounds and supported formats; normalize pixels into one documented engine
format. XRGB alpha is opaque; ARGB alpha handling and channel order are tested.
Respect wl_shm access brackets and buffer release; copied pixels remain valid
after commit replacement, client disconnect and buffer destruction.

Create ImageTexture when size/format changes; update it on valid new content.
Coalesce updates and eventually damage-aware copies without starving frame
callbacks. Record bytes copied/uploaded and CPU cost. A GLES texture handle or
Vulkan image cannot just be cast into a Godot RID. GPU sharing requires a later
separately verified synchronization/import design. Document shm-only compatibility
and test a real native software-rendered terminal first.

Render client content unlit inside the monitor aperture in world mode. In
application mode, show the same live content at a readable pixel scale with
defined letterboxing. The desk monitor and flat view share the selected-window
binding and coordinate mapping. T49 adds `application_objects.gd`, a world presentation/placement
manager. It uses the existing runtime handles and revision-filtered snapshots
for every mapped toplevel. Each `application_object.gd` has its own random entity
ID and transform; runtime bindings are session-only and never persisted. The
selected panel shares the monitor's uploaded texture, while other panels update
independent textures. The manager still requests a second owned snapshot for the
selected panel; this is not a zero-copy or performance acceptance claim.
T51 keeps world navigation enabled during panel dragging: WASD and right-mouse
look reach the player, while the manager follows the held panel's screen-space
grab in each physics update. Drop preserves held navigation; cancellation clears
it. T52 maps the wheel to panel yaw while mouse-look is captured during a drag;
otherwise it adjusts depth. Rotation validates the new bounds in place, and
cancellation restores the original full transform. Application/launcher modes
remain owned by their existing policy layers.
T54 makes the chair an upright rigid body with six fitted convex box shapes;
walking applies bounded horizontal impulses. Other imported furniture retains
static collision. T55 makes live panels upright CharacterBody3D objects with
collision sized to the rendered frame. New panels stay at their initial visible
placement until moved. Releasing a drag enables gravity; a swept whole-panel
motion stops at furniture/floor contact and keeps probing for removed support.
Grabbing pauses gravity, and cancellation restores transform and falling state.
Physics layers are room/furniture=1, player=2, panels=4. Drop queries ignore the
player, placement queries include it, and picking tests panel faces separately
from room occlusion. This is Godot world behavior; no compositor state changes.
Panels use the same unlit shader and inverse transforms. Nearest front-face
picking respects room geometry and opaque panel backs. Drag placement clamps
whole-panel bounds and rejects furniture/player/panel overlap; focus loss,
launcher entry, Escape and destruction cancel ownership cleanly. Closing a window
removes its session-only panel. Durable inactive artifacts/restoration remain
future work. Moving furniture moves the screen slot. Closing/remapping a client
invalidates focus and content immediately; an inactive artifact is visibly
inactive rather than displaying a stale screenshot as a live session.

## Input, configure and lifecycle

Build explicit physical-key mapping to evdev/XKB seat codes. Validate printable
keys, layout/modifiers, repeat, press/release and unsupported codes. Scope all
input to Godot's focused host window. World movement keys are consumed only in
world mode; application mode delivers ordinary text/shortcuts. Document one
reserved return key. Host-focus loss/mode changes synthesize appropriate releases
and clear ownership so no key/button sticks. Do not open global input devices.

Map Godot pointer coordinates through the displayed content rectangle, UVs,
orientation, buffer transform/scale and surface-local logical coordinates.
Test corners, center, aspect ratios, letterboxing and resized content. Send
configure sizes and obey acknowledge/commit ordering; do not stretch buffers
and claim the client resized. Audit existing stride/format/commit tests rather
than assuming historical task titles prove all cases.

Test create/map/unmap/remap/resize/destroy/relaunch, popup/subsurface trees and
per-window close behavior. Add deterministic bridge tests for ownership and
mapping, and a runtime extension load/unload test. Run relevant sanitizer
checks; `detect_leaks=0` is not leak verification. Real-client evidence uses
the compositor's private socket and explicit client backend, not a terminal
opened directly on the host or a prerecorded texture.

## Convergence

The visual scene can use a clearly labelled diagnostic screen while the bridge
is built. That diagnostic screen never satisfies live-terminal acceptance.
The integration gate requires the furnished room and real live terminal together:
typing, pointer/scroll, resizing, enter/leave application mode, host-focus loss,
close/relaunch and responsive world movement, with observed runtime evidence.
If rendering or GUI tools are missing, record a blocker and continue independent
eligible tests/assets/core work. Headless import alone cannot pass a visual gate.
