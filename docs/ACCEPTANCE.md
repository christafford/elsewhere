# Real-client and visual acceptance

Status: procedures unless explicitly recorded as evidence. Synthetic tests and
screenshots are supporting evidence, not usability acceptance. Human tasks in TASKS.md remain unchecked until a person records them.

## 2026-10-15 P22-T11 furnished village

Agent-run/agent-observed from `5e5c416` plus P22-T11: ten additional buildings
bring the village to thirteen. Two taverns, two inns and six business/cultural
buildings have connected cobbled lanes, open ground floors, appropriate fixed
artifacts and usable worktables. No people; upper stories remain decorative.
Actual street, entry, interior, artifact and live-application renders inspected.
See [evidence](evidence/p22-t11/README.md) and [handoff 56](handoffs/56-furnished-village.md).

Headless/GPU trials walk all ten lanes both ways and every room, check floors,
enclosure, boundary separation, worktable clearance and Home return. Graphical
trials place real terminals through ordinary pointer/wheel input in every new
building, walk away/return, verify panel and shell PID/variable continuity,
resume typing and close. Import/bridge build, retained world and original-room
checks, pavilion manipulation, Terminal/Vim, Firefox and six default graphical
interaction checks pass. Fourteen Python and 62 Node/parser tests pass;
models regenerate byte-identically. No fresh complete native suite is claimed.

Owner procedure: restart Elsewhere, follow the north/west/east/south lanes,
walk through open entrances, launch with Tab, return with Ctrl+Alt+Escape and
place a panel above a teal worktable pad. Leave and revisit, double-click to
resume, then close. Compare the original pavilion and three original rooms.
Human appearance/comfort acceptance is **not observed**. Named-host rendering
costs increase with the denser village; short RTX 3080/Weston samples are not
Steam Deck/sustained performance acceptance. P22-T09/P22-T10 and restart
restoration remain unverified. Only P22-T11 is completed by this work.

## 2026-10-14 owner-requested building interiors

Agent-run/agent-observed from `228a550`: the Lodge, Guildhall and Workshop now
have enlarged, enterable ground floors, continuous ramp/threshold access and
two worktables plus movable stools per room. Existing warm finishes continue
inside. Upper floors, windows and turret remain decorative; no door key or new
input mode is introduced.

The new headless and GPU trials walk every entrance and full room depth, probe
floors/enclosure, and check both work pads. The graphical trial places a real
terminal on a desk in each building, walks outside and returns, verifies the
same panel entity/transform and shell PID/variable, resumes typing and closes
the client. Actual room/entry/workspace/application renders were inspected.
See [evidence](evidence/village-interiors/README.md) and
[handoff 54](handoffs/54-building-interiors.md) for commands and iteration.

Retained architecture/landscape/outdoor, pavilion manipulation and shell
continuity, Terminal/Vim continuity, Firefox input/clipboard/reuse/close/relaunch
and all six default graphical interaction checks pass. Exact gray/RGB swatches
remain unchanged. Fourteen Python and 62 Node/parser tests pass; model rebuild
is byte-identical. No fresh full native-suite result is claimed.

Owner procedure: restart Elsewhere, walk up each front ramp, explore the room,
launch an app with Tab, return with Ctrl+Alt+Escape, drag it above a teal desk
pad and release. Leave and revisit it, double-click to resume typing, then close
it normally. Try moving a stool and using the original pavilion as well.
Human appearance/comfort acceptance is **not observed**. Private Weston GL/RTX
3080 checks are not Steam Deck or sustained performance acceptance. This request
advances no P22 gate or restart-persistence claim.

## 2026-10-13 owner-requested sunlit art revision

Agent-run/agent-observed, based on `a597286`: the active village follows the
new owner reference's warm terracotta/cream/oak palette, fresh greens and blue
mountain/sky counterpoint. Four original small flower borders supply pink,
amber and orange accents. Existing routes, collisions and desktop services
are unchanged. Actual matched before/after and close material/pavilion renders
were inspected; over-bright initial material values and tiny flower shadow costs
were corrected. This is a palette/mood interpretation, not a claim of matching
the reference's geometry or photographic detail.

Import/startup/bridge build, headless/GPU architecture/atmosphere, all six default
interaction regressions, real Terminal/Vim continuity, pavilion manipulation/
shell revisit and real Firefox launch/input/clipboard/reuse/close/relaunch pass.
Exact screen-color swatches are unchanged. Live application renders were also
inspected; 14 Python and 62 Node checks plus deterministic flower rebuild pass.

[Before/after evidence](evidence/sunlit-village/README.md) and
[handoff 53](handoffs/53-sunlit-village-palette.md) record settings, raw counters,
commands and limits. Private Weston GL, Godot 4.7.2 and RTX 3080 host samples
are not Steam Deck or sustained performance acceptance. No human approval or
P22 gate advanced. Chrome and retained-study assets remain unavailable.

## 2026-10-13 agent-run Firefox launch repair

Based on `4235435`: Firefox 157.0.1 launches through the real desktop catalog
using a separate persistent profile while the owner's existing Firefox process
remains running. The real-client test passes trusted typing, clipboard copy/paste,
click/save, world return, launcher reuse preserving entity/PID, Ctrl+N,
independent close, prevention of another profile owner, confirmed quit and fresh
typing after relaunch. It uses local HTML as test content, not a mock browser.
Test-only homepage prefs bypass onboarding; production prefs are untouched.

Agent inspected actual [input](evidence/firefox-launch-fix/firefox-input.png),
[click](evidence/firefox-launch-fix/firefox-pointer.png),
[world panel](evidence/firefox-launch-fix/firefox-in-world.png) and
[relaunch](evidence/firefox-launch-fix/firefox-relaunched.png) captures, plus
retained terminal/editor/pavilion renders. Native 36/36, focused clipboard
protocol + ASan/UBSan, binding, six default graphical interaction trials,
Terminal/Vim continuity, pavilion and Python/Node checks pass. Environment:
Godot 4.7.2, private Weston 15.0.1 GL/fake-seat output, 1280×800, RTX 3080 and
NVIDIA 615.78.08. The retained resize trial uses 1600×1000.

See [handoff 52](handoffs/52-firefox-launch.md) and
[evidence](evidence/firefox-launch-fix/README.md) for reproduction, failed trials
and precise limits. No human acceptance, general menus/dialogs/downloads,
accelerated-browser, host clipboard, drag/drop or Firefox resize/scroll claim.
Chrome is absent and legacy-study assets remain missing. No P22 gate advanced.

## 2026-10-13 P22-T08 atmosphere and boundaries

Agent-run and agent-observed, based on `e063fba`: original wooded foothills and
144 instanced firs fill the middle distance beyond the existing bank, with two
partly visible tracks and mountain-local haze. Seven actual final views were
inspected for composition, voids and clipping; none obvious in the sampled views.
The initial coarse firs were refined after render inspection. Playable geometry,
application pixels and runtime/input ownership remain unchanged.

Matched 1280×800 host samples add four draw calls with median frame times around
16.7ms (final p95 at most 17.251ms), on a vsync-bound RTX 3080/private Weston GL
output. This is a bounded regression sample, not P22-T09/Steam Deck acceptance.
Headless/GPU atmosphere/architecture/landscape/outdoor checks, live pavilion and
Terminal/Vim continuity, six default interaction regressions, four headless
map/transform/runtime checks, 11 Python and 62 Node tests pass. Reactivated terminal
and editor renders were also inspected. Legacy source assets and Chrome remain
unavailable, so those broader fixtures are not fresh passes. No human approval,
comfort/latency, sustained target performance or restart-persistence claim.
See [images, counters, commands and results](evidence/p22-t08/README.md) and
[handoff 51](handoffs/51-village-atmosphere.md). P22-T08 only is complete.

## 2026-10-13 P22-T07 pavilion workspace

Agent-run and agent-observed, based on `3478f0d`: two timber worktables with
physical placement pads and two movable stools furnish the existing covered
pavilion. An actual Weston Terminal is manually dragged onto the west pad and
supported by existing physics. The east stool moves/rotates, settles and retains
its committed pose after another cancelled drag. A walk down the ramp into the
square and back preserves the original panel entity/transform and shell state
`43110:at-my-desk`; 50 background revisions advance. Double-click reactivation,
client-owned close and runtime shutdown pass. Eight final actual renders reviewed.

Headless/GPU scene checks, six default-world interaction regressions, isolated
Terminal/Vim, four headless transform/map/runtime checks, 11 Python and 62 Node
tests pass. Two shared-host multi-client failures are retained; the unchanged
trial passes on a private Weston GL output with fake seat. The full retained-study
suite is blocked by missing cached models/textures, and Chrome is not installed;
neither is a fresh pass. No native suite, human comfort, general focus repair,
restart persistence or performance claim. See
[commands, images, exact outputs and limits](evidence/p22-t07/README.md) and
[handoff 50](handoffs/50-pavilion-workspace.md). P22-T07 only is complete.

## 2026-10-12 P22-T06 outdoor live-application integration

The owner explicitly authorized P22-T06 with the selected version 2 village.
The Codex agent ran a new continuous real-client trial through the existing
Applications search: Weston Terminal 15.0.1 and Vim 9.2 (patches 1–1046),
independent panels, pointer drag/depth/rotation, ground settling, a 12.291m walk
down the south approach and back using S/W, and double-click reactivation.
The same shell PID/session variable and unsaved Vim buffer survive; live terminal
pixels and 24 frame revisions advance while away. Entity objects/IDs, window
bindings and placement/rotation stay intact. Each application closes itself;
the other remains until its own close. Shutdown reaps owned launch children.

Godot import/default startup/bridge build, headless/GPU outdoor tests, seven
existing graphical interaction regressions, eight Python and 62 Node tests pass.
The existing retained-study object test is separate from this new outdoor
scenario. Google Chrome 154.0.8037.57 initially lost its first typed character
twice. Temporary tracing exposed a false-ready state: element autofocus without
document focus. The local test page now requires both and reports actual focus
on an animation frame. No retry, discarded key, fixed delay, weakened assertion
or production input change. Two subsequent complete Chrome trials pass trusted
typing/click, both scroll directions, real resize/reflow, world return,
independent second window identity and client-owned close.

The agent inspected eight final Terminal/Vim/world renders and three final
Chrome renders; the failed browser render and logs remain labeled separately.
Readable native application views and smaller world previews are distinguished.
See [actual captures, outputs and diagnosis](evidence/p22-t06/README.md) and
[handoff 46](handoffs/46-village-applications.md). These are real applications
with injected input; the browser HTML is test content. No human comfort,
latency/performance benchmark, general application compatibility or restart
persistence claim. The village art/runtime architecture are unchanged.
P22-T06 only is complete; no P22-T07 or later work was begun.

## 2026-10-11 P22-T05 materials, foliage and lighting

The owner selected version 2 and requested this single task. The Codex agent
inspected twelve final real Godot captures: the nine preserved architectural
viewpoints plus close views of facade finishes, fountain/paving and foliage.
Comparisons show curated cobbles/plaster/timber, grain alignment, carved stone,
fuller canopies and readable shaded timber. First-pass glare/aliasing and a
shadow-bias experiment were corrected through actual rendered review. See
[the before/after evidence](evidence/p22-t05/README.md) and
[handoff 45](handoffs/45-village-materials.md).

Headless/GPU architecture, landscape and outdoor checks pass. Landscape evidence
is 24,178 samples and 337.8m walked per mode, maximum grade 14.39° and floor gap
below 6mm. Existing collision/access and application assertions are unchanged.
Seven graphical interaction trials pass, including client color, terminal
input/repeat/pointer/resize, launcher, independent objects and transitions.
Real Chrome passes trusted typing, click/save, both scroll directions,
resize/reflow, world return, separate window identity and close. Terminal output
and browser text were inspected in actual captures; application shading and
exposure remain unchanged. Final graphical architecture/outdoor/color/Chrome
trials were repeated after the last shadow/ground correction.

Eleven Python and 62 Node tests pass. Nine tracked material maps pass offline
size/SHA-256 verification; missing/corrupt/incomplete manifest tests reject the
bad inputs. Original model rebuilds match their recorded hashes; non-tree model
positions/normals/counts remain identical to `82dd2a2`. No native source or
runtime/controller change, new dependency, host service change or new destination.

Owner selection of version 2 is recorded; final owner approval of this refined
art, movement comfort and performance are not claimed. These are preservation
regressions for P22-T05, not completion of P22-T06 or a later task. Stop at the
owner art-review checkpoint.

## 2026-10-11 agent-run reference 2 comparison

From `340ca97`, the active candidate follows the owner's second reference:
weathered timber/stone, ivy, pointed turret, broad tiered fountain, darker cobbles
and distant mountain/cloud backdrop. Nine actual Godot eye-level captures were
inspected after correcting faceted bright mountains, ringed slate, gridded ivy
and hard snow patches. Use the [matched-view comparison](art-direction/compare.html)
to compare these with reference 1's preserved renders. Both source JPEGs are
separately labeled; neither is presented as an Elsewhere render or runtime asset.

The headless/GPU architecture trial passes unchanged collision/access checks;
only the expected model count drops with removal of the bridge. Both full
landscape trials pass: 24,178 samples, 337.8m walked per mode, maximum grade
14.39° and floor gap below 6mm. The page's nine paired images, links, selector,
buttons and slider were exercised in real headless Chrome, and its render
inspected. Eight Python tests and 62 Node tests pass.

The unchanged outdoor trial, seven dedicated graphical interaction tests and
real Chrome trial also pass: launch, typing/repeat, pointer input, resize,
independent instances, manipulation, transitions, browser scroll/reflow and close.
Fresh [terminal](evidence/village-reference-2/application.png),
[terrain panel](evidence/village-reference-2/slope-panel.png),
[browser input](evidence/village-reference-2/browser-input.png) and
[browser world return](evidence/village-reference-2/browser-in-room.png) renders
were inspected. Runtime/controller/native code is unchanged.

Reference 1 remains at `340ca97` / `art-reference-1`; reference 2 has its own
commit/tag and separate evidence. Full commands, application regression results,
remaining visual limits and safe switching are in
[handoff 44](handoffs/44-village-reference-2.md). No owner selection/art approval,
comfort measurement, performance benchmark or later task acceptance is claimed.

## 2026-10-11 agent-run owner reference alignment

From `e32c9dc`, the owner-supplied courtyard image now guides the existing
square: closer timber/plaster exteriors, curved blue slate roofs/dormers,
lattice windows, flower boxes, canvas awning, planted fountain, fixed trees,
pale paving and an arched timber link. Nine actual final Godot eye-level renders
were inspected by the Codex agent. Compare
[previous arrival](evidence/p22-t04/arrival.png) and
[current arrival](evidence/village-reference/arrival.png); see also
[workshop detail](evidence/village-reference/workshop.png) and
[the covered pavilion](evidence/village-reference/pavilion-covered.png).

Headless and GPU architecture checks pass: exterior/fountain collision,
pavilion ramp/covered floor, safe Home spawn and empty working desktop startup.
The unchanged full landscape trial passes in both modes: 24,178 ground samples,
337.8m walked per mode (including the northern route below the link), maximum
sampled grade 14.39°, floor gap below 6mm. No route assertion was weakened.
The fountain contact range follows its deliberately larger planted surround;
close-up captures follow the buildings' new positions.

The unchanged outdoor trial, seven dedicated graphical interaction tests and
real Chrome trial also pass. These cover launch, keyboard/repeat, pointer input,
client resize, panel drag/rotation/cancel, independent live instances, mode
transitions, browser typing/click/scroll/reflow and close. Inspected
[terminal output](evidence/village-reference/application.png),
[terrain-supported panel](evidence/village-reference/slope-panel.png),
[browser input](evidence/village-reference/browser-input.png) and
[browser world return](evidence/village-reference/browser-in-room.png).
Eight Python and 62 Node tests pass. No native or input code was changed.

The wider lawn/bank, regular paving and simple trees remain visible limits.
This revision is not human art approval, a comfort/performance measurement,
or completion of P22-T05 or later gates. The source JPEG is reference only,
not an implementation screenshot. Full commands, real-client regression
results and remaining limits are in
[handoff 43](handoffs/43-village-reference-alignment.md).

## 2026-10-10 agent-run village architecture (P22-T04)

From `e81c88c`, the default square contains an original modeled compass
fountain, three differentiated exteriors and an open covered timber pavilion.
Nine actual human-eye-height Godot views were inspected by the Codex agent,
including [arrival](evidence/p22-t04/arrival.png),
[southern approach](evidence/p22-t04/south-approach.png),
[northern return](evidence/p22-t04/north-return.png) and
[under the pavilion](evidence/p22-t04/pavilion-covered.png).
Pitched/stepped/hipped roofs, balcony joinery, windows and door surrounds give
the buildings recognizable silhouettes. Initial bare plinth/side elevations
and lean-to alignment were corrected and rendered again. The source models,
import settings, provenance and deterministic rebuild hashes are tracked.

Headless and graphical architecture trials pass actual facade/fountain
collision, pavilion ramp traversal, floor support/roof cover and Home return.
Both landscape modes retain 24,178 ground samples and 337.8m of route walking;
all outdoor boundary and real-terminal assertions pass unchanged. Seven
existing Godot regressions and the real Chrome trial pass focus/typing,
pointer/scroll, resize, launcher/relaunch, manipulation, identity, transitions,
world return and close. Agent-inspected [terminal](evidence/p22-t04/application.png)
and [browser](evidence/p22-t04/browser-input.png) images preserve readable
native application content.

Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4, AMD Custom GPU 0405, private
Weston 15.0.1, 1280 × 800 (browser world-return capture 1000 × 700).
No human art/comfort approval or final performance acceptance is claimed.
The three building interiors are out of scope; the pavilion has no work
furniture/anchors. Materials, foliage and lighting remain P22-T05. See
[handoff 42](handoffs/42-village-architecture.md) for complete evidence and limits.

## 2026-10-10 agent-run village landscape and circulation (P22-T03)

From `eca98ab`, the default outdoor scene has an approximately 84m authored
boundary, gently varied terrain, a level paved square and four approach paths.
Headless and graphical trials each pass 24,178 ground queries and approximately
337.8m of actual controller walking, uphill/downhill on every approach and
across the square apron. Maximum sampled slope is 14.39°; floor gap is under
6mm. No missing ground or unexpected navigation obstacle was found in the
sampled interior. Walking/jumping into all ten bank sections and a corner
remains contained, and Home returns safely to the level spawn.

The outdoor real-terminal trial passes launch, drag/rotation/cancel, typing,
return and shutdown. The same terminal lands on the raised western terrain,
accepts further shell input and retains its identity. Seven existing affected
Godot trials preserve native colors, keyboard/pointer/scroll, actual resize,
launcher/Vim/relaunch, independent instances, manipulation and transitions.
The unchanged real Chrome trial passes typing/click/scroll, resize/reflow, world
return, second-window identity and client close in the landscape scene.

Agent-inspected actual renders: [arrival](evidence/p22-t03/arrival.png),
[south](evidence/p22-t03/south-approach.png),
[west](evidence/p22-t03/west-rise.png),
[north](evidence/p22-t03/north-saddle.png),
[east](evidence/p22-t03/east-shelf.png),
[terrain-supported panel](evidence/p22-t03/slope-panel.png), and
[terminal](evidence/p22-t03/application.png). Godot 4.7.2 Compatibility/OpenGL,
Mesa 26.2.4, AMD Custom GPU 0405, private Weston 15.0.1, 1280×800. Injected input
and agent observation do not establish human comfort or finished village art.
The bank/materials are provisional; P22-T04 is unstarted. See
[handoff 41](handoffs/41-village-landscape.md) for commands and limitations.

## 2026-10-10 agent-run empty-startup revalidation (P22-T02)

From `86db629`, revalidated the existing outdoor scene after separating the
owner's no-startup-terminal preference from desktop service initialization.
Headless and GPU outdoor trials pass, including an idle wait beyond the
initial-terminal watchdog, Tab/launcher startup of a real terminal, all prior
navigation/collision/panel/input checks and owned-client cleanup. All 21 existing
Godot regressions pass, including retained study behavior and terminal
input/pointer/resize, launcher/relaunch, independent instances and transitions.
The isolated real Chrome trial passes from empty startup, including correct
first-window labeling. A concurrent attempt lost its first typed character;
that intermittent failure remains uncorrected, and is retained in the handoff.
Fresh agent-inspected captures show [empty arrival](evidence/p22-t02/recheck/empty-arrival.png),
[real terminal input/output](evidence/p22-t02/recheck/application.png), and
[world return](evidence/p22-t02/recheck/ground-and-boundary.png).
Same Godot/Mesa/AMD/private-Weston platform as below; injected input, 1280×800.
See [handoff 40](handoffs/40-outdoor-startup.md) for failure/repair evidence and
verification results. This is bounded startup acceptance, not human observation
or the P22-T06 application integration gate.

## Original 2026-10-10 agent-run minimal outdoor startup (P22-T02)

From `7d74847` plus P22-T02, the default starts on flat outdoor ground with
visible collision boundaries, sky and sunlight. The new headless/graphical
trial verifies safe spawn, walking/release, jump/landing, all four boundaries,
corner containment, Home, real terminal mapping, panel drag/rotation/cancel,
typing, world return with the same identity/placement and clean shutdown.
All 21 existing Godot trials pass: retained study geometry checks use its explicit
scene; general input, pointer, resize, launcher and transition checks use outdoors.
The separate real Chrome trial passes its trusted input, scroll, resize,
world-return and separate-window lifecycle assertions. An initial first-character
failure led to an additional fixture load/focus readiness check; no application
input behavior or existing expected results were changed.

Agent-inspected actual GPU renders: [arrival](evidence/p22-t02/arrival.png),
[ground/boundary](evidence/p22-t02/ground-and-boundary.png),
[terminal](evidence/p22-t02/application.png),
[Chrome input](evidence/p22-t02/browser-input.png) and
[Chrome world return](evidence/p22-t02/browser-in-room.png). Application content
is upright and readable in the reviewed application views. Platform: Godot 4.7.2
Compatibility/OpenGL, Mesa 26.2.4, AMD Custom GPU 0405, private Weston 15.0.1;
1280×800, with Chrome's return view resized to 1000×700. Clients: Weston terminal
15.0.1, Vim 9.2 and Google Chrome 154.0.8037.57. See
[handoff 40](handoffs/40-outdoor-startup.md) for exact commands and limitations.
This accepts the plain startup fixture only, not polished village art or the
P22-T06 integration gate. No human physical-input/comfort, restart persistence,
popup/clipboard or general application-compatibility gate is claimed.

## 2026-10-09 agent-run desktop extraction regression (P22-T01)

From `fd36f01` plus P22-T01, the complete 21-trial Godot suite and separate
Chrome trial passed in a private GPU Weston output. Real Weston terminal 15.0.1,
Vim 9.2 and Chrome 154.0.8037.57 retain launch, focus, typing/pointer, resizing,
world return and their existing panel behavior. Injected events also verify
movement, carrying/rotation, support/gravity and mode transitions. The added
headless test maps real clients and verifies desktop cleanup without constructing
the study. This is a runtime extraction; the study remains the active world.

Agent-inspected actual renders include
[before](evidence/p22-t01/before-rotation.png) /
[after](evidence/p22-t01/after-rotation.png) live-panel rotation,
[terminal typing](evidence/p22-t01/after-typing.png),
[selection](evidence/p22-t01/after-selection.png) and
[Chrome input](evidence/p22-t01/after-browser.png). Application content remains
upright and legible in the reviewed views; the before/after selection PNGs are
byte-identical. Platform: Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4,
AMD Custom GPU 0405; captures above are 1280×800. See
[handoff 39](handoffs/39-desktop-runtime-extraction.md) for commands, full scope
and limitations. No new human physical-input/comfort, outdoor-world, restart
persistence or general application-compatibility gate is claimed.

## 2026-10-09 agent-run Chrome and subsurfaces (P21-T65/T66)

From `2cdfd15` plus T65/T66, the installed Google Chrome 154.0.8037.57 was
launched from the actual application catalog on a private Elsewhere Wayland socket.
Agent-injected Godot keys/pointer events typed an address and a note, clicked the
page button, scrolled both ways, resized the actual page and returned to the room.
A localhost fixture recorded browser-trusted input events and DOM dimensions.
A second catalog launch made a separate live application panel; Chrome's own
Ctrl+Shift+W closed that window while the first remained. This is real Chrome
rendering/interaction, not a synthetic browser or screenshot replay.

Agent-inspected Godot GPU captures: [address-bar child](evidence/t65/address-bar.png),
[typed and clicked page](evidence/t65/browser-input.png),
[resized page](evidence/t65/browser-resized.png), and
[browser in the room](evidence/t65/browser-in-room.png). Chrome's child content is
visible with its parent; application text is upright and readable in these views.
The renderer was Godot Compatibility/OpenGL, Mesa 26.2.4, AMD Custom GPU 0405,
private GPU Weston 1280×800, then 1000×700. Native protocol fixtures prove their
own synchronization, stacking, input-region, transform/alpha and lifecycle
assertions separately. See [full evidence and commands](handoffs/37-graphical-applications.md).

`xdg_popup` menus, clipboard, IME, GPU client buffers and general toolkit support
remain unfinished. A popup request can still disconnect the browser. No human
physical-input, latency, general browsing or comfort gate is marked passed.

## 2026-10-02 audit boundary

The owner confirmed legacy room navigation and the upside-down export fix in
this conversation after `99fcedb` / `3dfaa26`. This is not a terminal, Godot or
furnished-room acceptance trial. No human task is ticked from that feedback.
The audit ran isolated Godot CLI import/runtime checks and inspected source/cache
contents, not a Godot visual or live-client trial. See
[the audit handoff](handoffs/11-godot-reality-audit.md) for exact scope/results.
P21-T00/T01/T02/T03/T10 are reopened. A `.so` build, cache size, or legacy test
pass cannot satisfy their revised explicit checks in [TASKS.md](TASKS.md).

## 2026-10-05 agent-run application rotation (P21-T52)

Based on `cabde04` plus T52, Codex verified both-buttons + wheel yaw through
injected events on a real Weston Terminal, alongside Vim. Camera, panel center,
depth and the other client stay unchanged. Both directions/fractional steps,
return to depth adjustment, orientation retained after drop/application return,
full-transform cancellation and rejected obstructed rotations pass. The full
study suite passes with the host input seat and isolated GPU resize.
[Rendered rotation](evidence/application-rotation/rotating-terminal.png) inspected
at 1280×800, Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4, AMD Custom GPU 0405:
terminal visibly angled, Vim unchanged, and contextual rotation hint visible.
See [handoff 29](handoffs/29-godot-application-rotation.md) for commands and logs.
Physical feel is not observed; no human gate is ticked.

## 2026-10-05 agent-run navigation and carrying (P21-T51)

Based on `c789f37` plus T51, Codex verified the new controls with rendered Godot
input tests and real Weston Terminal/Vim clients: WASD always strafes/walks,
mouse-look remains where aimed after release, Shift speeds up, Ctrl/M slows,
and walking/turning continues while holding a live application. Dropping does
not stop held movement; wheel up pushes away and down pulls closer. Existing
collision, cancellation, typing, selection, scrolling and resize checks pass.
The full study suite passes with host input and isolated GPU-rendered resize;
see [commands and limitations](handoffs/28-godot-natural-navigation.md).

[Rendered controls and live panels](evidence/natural-navigation/controls-and-panels.png)
were inspected by Codex at 1280×800, Godot 4.7.2 Compatibility/OpenGL,
Mesa 26.2.4, AMD Custom GPU 0405. This image shows the new control hints and
real Terminal/Vim panels after placement; movement claims come from the event
trials, not this still image. Physical keyboard/mouse feel is not observed.
Human tasks remain unchecked. The owner trial is described in handoff 28.

## 2026-10-05 agent-run application objects (P21-T49)

Based on `88f9938` plus T49 and pre-existing uncommitted work, Codex exercised
real Weston Terminal and Vim simultaneously using injected Godot input. Separate
live previews keep updating; dragging one preserves the other's placement;
double-clicking the terminal then typing writes the expected `TARGET` file.
Room return preserves identity/placement, and real client exit during drag clears
only that client's object. Cancellation, occlusion, bounds and owned shutdown
also pass. [Rendered host captures](evidence/application-objects/) show both
applications in the furnished room before/after movement. Observer: Codex agent,
Godot 4.7.2 Compatibility/OpenGL, Mesa 26.2.4, AMD Custom GPU 0405, 800×800 window
on the current portrait host. No physical-input or human comfort trial is claimed.

Use `tools/run-godot.sh --audio-driver Dummy`, launch an application from Tab,
then Ctrl+Alt+Escape to return. Double-click its panel to resume; left-drag to
move, wheel during drag for distance, Escape to cancel. Place Terminal and Vim,
move each, resume each and confirm ordinary typing/selection. Restart placement
restoration and general application compatibility are not implemented by T49.
See [handoff 26](handoffs/26-application-objects.md) for fresh regression results,
the pre-existing navigation failure and isolated four-size resize evidence.

## Current Project 21 acceptance

Use Decision 06, ART-DIRECTION.md and GODOT-INTEGRATION.md for the new frontend.
The commands below describe the supplied legacy executable and are historical
procedures for it, not Godot launch commands. P21-T00/T01/T11 must document the
new actual commands in TOOLCHAIN.md and this file after implementing them.

P21-T48 launcher acceptance (Codex agent, 2026-10-04, based on `7316f78`): real
installed Vim launched from the radial menu's search dialog, received typing
inside Weston, and returned to the existing terminal through a recent-app click.
The original terminal exited and relaunched; a shell-written file confirmed
typing in the replacement. The graphical test verifies modal/camera isolation,
ordinary application Tab, eight-slot layout, persistence and cleanup. See
[labeled rendered captures](evidence/application-launcher/) and
[handoff 25](handoffs/25-application-launcher.md). Eight populated history slots
are a layout fixture, not eight app-compatibility passes. General graphical-app
support, client close requests, physical input and human comfort remain open.

For P21-T09/P21-T19/P21-T28, keep fixed rendered world/application views with
revision, camera, renderer, resolution, machine and observed defects. Inspect
the images; never infer visual quality from a successful headless import.
For P21-T18/T19, run a real native software terminal on the private socket and
record typing/output, modifiers, pointer/scroll, resize, repeated mode switches,
host-focus loss, close/relaunch and responsive world movement. Record moving
content and input results, not just a static screenshot. Include exact client
and environment; fixture and CPU-copy proofs do not establish GPU compatibility.

P21-T33 audits the implemented workspace and prepares the owner trial. P21-T34
requires a person. Agent GUI observation may satisfy an explicitly agent-observed
task but never ticks that human task. Performance on another machine is provisional
until measured on the target Steam Deck. Missing GUI or target hardware is a
blocker for its dependent acceptance, not permission to invent results; complete
other independent eligible tasks first.

Record: task IDs, revision/date, command, environment, expected/actual result,
evidence path, observer, pass/fail and limitations. Track material/lighting,
interaction, real-client compatibility and performance separately. A correct
test suite does not erase a failed visual criterion.

## 2026-10-03 agent-observed Godot live output (P21-T41)

Codex inspected the real Weston terminal 15.0.1 output in the Godot study:
upright text, changing clock/counter, preserved aspect ratio and clearing on
disconnect. [Room and close-up captures](evidence/live-terminal/) were rendered
at 1280×800 using Godot 4.7.2 Compatibility, Mesa 26.2.4, AMD Custom GPU 0405.
Source: T41 implementation committed with [handoff 20](handoffs/20-godot-live-terminal.md),
based on `3a8843f`. Reproduce with `tools/check-godot-study.sh`.

The real terminal check exercises two sessions and asserts owned process/socket
cleanup. Separate synthetic GPU color patches and injected controller events
pass. `client-frame.png` is a source frame, not a rendered screenshot. No actual
terminal typing, pointer interaction, application mode or physical-input trial
is claimed. Human acceptance remains **not observed**; T42–T45 implement the
remaining interaction before the broader terminal usability procedure.

## 2026-10-03 agent-run Godot keyboard interaction (P21-T42)

Codex injected Godot keyboard events through the production application-mode
path into the real Weston 15.0.1 terminal and `/bin/sh`. Shell-written output
files verify mixed-case/punctuation typing and Backspace; additional commands
verify repeat and Ctrl+C interruption. Enter activates the same live window,
Ctrl+Alt+Escape returns to world, movement resumes, host-focus-loss notification
clears focus, and typing `exit` while Shift is held restores world mode.

[Application and post-exit captures](evidence/terminal-input/) were inspected at
1280×800 using Godot 4.7.2 Compatibility, Mesa 26.2.4, AMD Custom GPU 0405.
The flat view preserves native pixel size and 7,571 sampled client pixels.
Revision: T42 implementation committed with [handoff 21](handoffs/21-godot-terminal-keyboard.md),
based on `d7a590c`. Reproduce with `tools/check-godot-study.sh`.

This passes the bounded keyboard gate with a physical US mapping. The events
were injected; physical host input, IME/layout selection, pointer/scroll, resize,
compositor close/relaunch, latency and human usability remain **not observed or
unimplemented**, as applicable. No human task is ticked.

## 2026-10-03 agent-run Godot pointer interaction (P21-T43)

Codex injected Godot mouse events into real Weston 15.0.1: a left drag highlights
the printed output line, release stops the selection, and a second drag releases
outside the image. Three wheel-up events reveal rows 47–71 after `seq 1 100`;
wheel-down restores rows 77–100 and the prompt. Mode exit during a drag releases
input; room movement resumes/stops and the camera stays released. Host-focus-loss
notification and abrupt owned-client disconnect while held clear pointer state.

[GPU captures](evidence/terminal-pointer/) were inspected using Godot 4.7.2
Compatibility, Mesa 26.2.4, AMD Custom GPU 0405, 1280×800. Revision: T43 changes
committed with [handoff 22](handoffs/22-godot-terminal-pointer.md), based on
`ddd489c`. Reproduce with `tools/check-godot-study.sh`. Native protocol and mapping
tests separately cover client isolation, coordinates, button/axis codes and
scale/transform/letterboxing; they do not substitute for this real-client trial.

This passes selection/scroll, not clipboard transfer. Client cursor images and
popup menus remain unsupported (a popup request can disconnect a client).
Physical mouse/touchpad input, latency, actual client resize, compositor close/
relaunch and human usability are not accepted by this evidence. No human task
is ticked.

## 2026-10-04 agent-run Godot client resize (P21-T44)

Codex changed the real host window size four times after terminal activation:
1000×700 → 1200×780 → 900×620 → 1280×800. Weston committed new buffers and its
shell reported 77×22 → 95×25 → 68×18 → 103×26 columns/rows. Typing and selection
worked at every size. 8,573 sampled opaque pixels matched native-size GPU views;
return to world showed the updated live monitor. This proves client reflow in
the tested sizes, not merely scaling an old texture.

[Five GPU captures](evidence/terminal-resize/) were inspected with Godot 4.7.2
Compatibility, Mesa 26.2.4, AMD Custom GPU 0405, at the listed viewport sizes.
Client: installed Weston 15.0.1-3, monospace 16, `/bin/sh` (Bash). Revision: T44
changes committed with [handoff 23](handoffs/23-godot-terminal-resize.md), based on
`2e304a9`. Reproduce with `tools/check-godot-study.sh`. Native fixture/sanitizer
checks separately cover delayed/declined choices, pending/committed metadata,
limits, serials, retained frames, bounded queues and destruction while pending.

Input and host-size changes were injected by the agent. Physical mouse-driven
host resize, HiDPI host behavior, very small windows, latency and human comfort
remain unobserved. Compositor close/relaunch, clipboard, client cursors and popup
menus remain unfinished. No human task is ticked.

## Legacy baseline and procedures

Run from the repository root in the normal development container/session:

```sh
./check-deps.sh
meson setup build --buildtype=debug  # first time only
meson compile -C build
meson test -C build --print-errorlogs
./build/elsewhere --help
git rev-parse HEAD
```

Run sanitizer checks separately as documented in TASKS.md. Record versions of
Meson, Wayland/protocols, Mesa/driver, GPU and the chosen terminal. Install missing
packages personally using GETTING_STARTED.md; an autonomous session records the
blocker. Do not change host services, global input permissions, or login sessions.

## Terminal trial: P1-T10, P4-T04 and recovery P4-T17

Current source presents through a nested Wayland client window and needs the
host WAYLAND_DISPLAY plus weston-terminal. The owner confirmed basic world
navigation and upright output on 2026-10-02, but this terminal/input trial has
not been observed. These remain legacy procedures, not the Project 21 work order.

```sh
./build/elsewhere --flat --launch weston-terminal
./build/elsewhere --room-camera --launch weston-terminal
```

Perform the flat trial first, then the room trial. Elsewhere prints its private
ELSEWHERE_SOCKET. Ensure the terminal connects there rather than appearing as an
ordinary host window. Do not override the host WAYLAND_DISPLAY globally; the
launcher sets child environment. If launching by hand, use its private display
name with the same XDG_RUNTIME_DIR and explicit native toolkit backend.

1. Confirm terminal content appears and updates; record a screenshot including
   the Elsewhere window. Type a short command and confirm visible output.
2. In room mode, walk or use the documented T teleport, target the monitor and
   Enter to application mode. Confirm the full-size terminal is readable.
3. Type lowercase/uppercase, punctuation and modifier combinations; select text
   with the pointer and scroll output. Test corners/center and any letterboxing.
4. Resize the host window smaller and larger. Verify updated text/pointer mapping
   and repeated configure behavior. Record clipping or scaling issues.
5. Use F12 (default reserved world key) to return to the world and re-enter at
   least five times. Confirm the same application/session/output persists.
6. Hold a key or pointer button while changing modes/focus, then release it;
   verify no stuck input. Switch to another host app and type; no Elsewhere client
   should receive that input. Record any host shortcuts Elsewhere cannot capture.
7. Close the terminal from its UI and confirm Elsewhere stays responsive in world
   mode. Restart with a fresh launch and repeat; client close must not leave stale
   focus/content masquerading as a live window.
8. Quit Elsewhere using its host close control. Confirm the host desktop remains
   usable and launcher-owned child shutdown behavior matches documentation.

Record observed pass/fail per step. If flat and room evidence covers the earlier
human tasks in full, a person may mark P1-T10/P4-T04 and P4-T17 from the same
record; partial evidence does not pass the combined procedure.

## Furnished-room trial: P4-T27

After P4-T20–P4-T26, record the exact scene/asset revision and repeat the room
terminal trial. Inspect textures, furniture scale and lighting. The application
must stay unlit/readable in world and application modes. Target and move the
supported object between slots; open/close the door and cross the doorway without
being trapped. Test reduced-motion and keyboard access. Record frame-time/copy
metrics with a fixed workload and personally describe comfort/legibility; pixel
checks cannot supply those observations. Restart persistence is a later P6 check.

## Multi-application trial: P5-T10

P5-T08 must supply real native terminal/browser/editor versions and launch
commands using disposable test profiles/data. Launch all three; switch by the
documented keyboard and object controls, type/click/scroll in each, open menus
and a dialog, and verify related surfaces stay attached to the correct parent.
Request close with an unsaved document and decline it; the app must remain usable.
Close one of two windows in one application process, then another application;
remaining windows continue working. Assign an ambiguous window manually.
Record exact unsupported protocols/buffer paths; no universal compatibility claim.

## Evidence record template

Copy one record per trial into the applicable handoff; summarize/link it from
STATUS. Keep screenshots/logs at named repository-relative evidence paths only
when suitable to commit; avoid personal terminal history or private app data.

```text
Task/gate:
Observer and type (human / agent GUI / automated):
Date, timezone, source revision, dirty-tree differences:
Host OS/session, container, backend, GPU/driver, EGL/GLES versions:
Application/version, scene/assets, configuration:
Exact build/run/check commands:
Step-by-step expected and observed results (pass/fail/not observed):
Screenshots and diagnostic log paths:
Normal/sanitizer results and measured workload/performance:
Known limitations, blocker and smallest next action:
Gate outcome and exact next scope authorized:
```

An agent may collect separately labeled GUI evidence where its tools permit;
tasks explicitly marked (human) still require a person's observation. Leave
unperformed steps "not observed" and product gates pending. A test exit code or
successful mapping log does not prove text readability or interactive comfort.

## Owner-requested room details and physical placement: T53–T55

2026-10-05–06 automated and agent-rendered evidence is recorded in
[handoff 30](handoffs/30-study-details-and-physics.md). This does not tick a human
gate. Personal comfort/appearance observation for these changes: **not observed**.

Run `tools/run-godot.sh --audio-driver Dummy`. Look up at both twin-tube fittings,
inspect the soft brightness variation and moving shadows below them, then view
the botanical prints, clock and noticeboard. Walk into the chair from the back
and side; it should yield and stop against furniture/walls without tipping.
Drag the live terminal over the floor, desk, chair seat and bookcase top; release
it and check that its bottom stops at the first surface it meets. Lift it again,
rotate with both mouse buttons plus wheel, and cancel with Escape. Move the chair
out from underneath a supported panel. Confirm the panel falls again, stays
live and still accepts typing after double-click activation. Record comfort,
readability, visual defects and measured performance separately from automated
collision/input evidence. Session placements are not restored after restarting.

## Owner-requested furnishings and application transitions: T56–T59

2026-10-06 agent-run evidence, commands and rendered captures are recorded in
[handoff 31](handoffs/31-furnishings-and-transitions.md), starting from `e618487`.
Human comfort/physical input observation remains **not observed**.

In the visible study, left-drag the chair, plant and bookcase, carry them with
WASD, change distance with the wheel and rotate with both buttons plus wheel.
Release to drop them; Escape restores the original placement. Walk into each
and inspect floor/wall/furniture contact. Check walnut grain and panel joints
around the window and decorations. Launch Terminal twice through the wheel;
type different commands, return to the room, reopen each panel and close one.
The other should retain its shell state. Double-click a room panel to see its
live surface approach the camera; Ctrl+Alt+Escape sends it back. Try reversing
quickly, resizing, losing host focus and closing the client. Confirm comfortable
motion and readable native text separately from the agent's geometry, pixel
and input assertions. Session placements still reset when Elsewhere restarts.

## Owner-requested hallway: T60

2026-10-08 agent-rendered and injected-controller evidence from `139214d` plus
T60 is in [handoff 32](handoffs/32-oil-lit-hallway.md). Human physical-input,
lighting preference and motion comfort observation remains **not observed**.

In the study, turn away from the desk and walk through the open framed doorway.
Count three closed doors on the left, two on the right and one at the far end.
Inspect the burgundy carpet, oil reservoirs/chimneys/flames and warm wall light.
Walk the full hall and return; closed leaves and walls should stop you. Carry
a live application through the doorway, drop it on the hallway floor, activate
it and return to the same position. Movable furnishings use the same placement
volumes. Doors have no opening interaction in this request.

## Owner-requested exploration rooms: T61

T61 supersedes the closed-door behavior in the historical T60 procedure above.
2026-10-08 agent-rendered/injected-input checks from `e1deea6` plus T61 are in
[handoff 33](handoffs/33-exploration-rooms.md), including performance samples and
the launcher test's 45-second timeout / successful 46-second standalone run.
Human physical-input and comfort observation: **not observed**.

Walk down the gallery and approach each door. It should swing into its room and
stay open. Explore the library, atlas room, winter garden, cabinet gallery,
inventor's room and observatory; read their plaques and inspect their different
landmarks/materials. Carry a live application through each doorway with the
existing left-drag/WASD/right-look controls, then place it on a table or floor.
Double-click to work, type, and use Ctrl+Alt+Escape to return. Leave an instance
in one room, walk elsewhere and launch another from Tab; return and verify the
first is still in place and usable. Check door clearance, ordinary input,
readability, useful arrangement space, appearance and comfort personally.
Placements last for this session only; restart restoration remains unimplemented.

## Longer rooms and movable furnishings: T62

Agent-run checks and rendered evidence are recorded in
[handoff 34](handoffs/34-long-rooms-movable-library.md). Human physical-input,
appearance preference and comfort observation: **not observed**.

Explore the extended library, atlas room, garden and gallery, carrying a live
application past the old halfway point to a far work area. Inspect the black
antique bookcase frames, warm plank interiors, iron rods and reading table.
Pull an individual bookcase into the aisle; its books and ornaments should
follow. Move a plant, chair, map cabinet, instrument, sculpture stand and parts
bin with left-drag, wheel depth and both-buttons/wheel rotation, including while
walking. Escape should restore the starting placement. Walk into these pieces
and verify they yield and settle upright. Move a table after putting an
application on it: the unsupported application should fall and remain usable.
Room 05 and the observatory retain their original dimensions but share the new
furniture behavior. Fixed architecture and mounted decorations stay fixed;
all moved placements remain session-local.

## Merged exploration wings: T63

See [handoff 35](handoffs/35-merged-exploration-wings.md) for agent-run/rendered
evidence. Human physical-input observation: **not observed**. Facing away from
the study, verify the former first left and second right entrances are sealed.
Enter the library/garden through the second left doorway and the atlas/gallery
through the first right doorway. Walk and carry an application across each
former dividing wall near the front, middle and back, in both directions.
Check continuous floors, no invisible partition or detached wall decoration,
and movable furniture. The inventor's room remains independent.

## Grand foyer and spiral stair: T64

The former observatory is replaced by the foyer. See
[handoff 36](handoffs/36-grand-foyer.md) for agent-rendered/injected evidence.
Human physical-input and comfort observation: **not observed**.

Approach the end door and enter the tall stone foyer. Inspect the vaulted roof,
central spiral, chandelier, rose window and gallery from both levels. Start the
stair at its low front end, then follow it around to the upper landing and bridge.
Walk against both stair rails and the gallery rail; they should stop you. Return
down the same stair. Carry a live application while ascending, drop it on the
upper gallery, double-click to type, and return with Ctrl+Alt+Escape. Leave that
instance there while working at a ground-floor table. Check ordinary movement,
clearance, text readability, appearance and comfort personally. Tables and plants
remain movable. There are no further rooms beyond the foyer yet, and placements
still last only for the current session.
