# P22-T07 — functional pavilion workspace

2026-10-13, based on `3478f0d`. The owner requested **P22-T07 only**, under
updated AGENTS.md and Decision 08. P22-T06 evidence satisfies its prerequisite.
The untracked owner file `docs/art-direction/art-direction-1.jpg` is preserved
and excluded from the task commit.

## Implementation

The existing pavilion owns a small `pavilion_workspace.gd` child: two fixed
weathered timber worktables face the square, with a clear 1.48m central passage
from the ramp. Raised teal pads with brass corner marks provide manually chosen
application support locations. Each pad has a local `WorkAnchor` marker; these
are physical locations, not application identities or automatic assignments.

Two round timber stools reuse the existing pushable furniture assembly and
fitted convex shapes. They can be dragged, rotated, cancelled and pushed with
the existing controls; no sitting mechanic. The worktables remain fixed.
Two original deterministic GLB models reuse the existing material pipeline,
adding 1,480 placed triangles before LOD. Source, imports and provenance are
recorded in [the asset notes](../../world/art/village/README.md).

This requires no compositor, native bridge, DesktopRuntime, launcher, input,
application entity, gravity or client-shader change. The architecture node
constructs the workspace after its fixed model collision, preventing generated
triangle colliders from being added to dynamic stools. Fitted table colliders
support panels; the existing panel support probe retains within-session placement.
The landscape test now excludes intentional furniture when sampling the terrain
beneath it, just as it already excludes architectural meshes. All navigation
assertions remain; architecture tests additionally verify both pads' collision,
full-panel clearance and roof coverage in headless and graphical modes.

## Real-client acceptance

`tools/check-godot-pavilion.sh` validates imports/startup and runs the bounded
`world/tests/pavilion_workspace.gd` trial against the default world and real
Weston Terminal. It walks from spawn up the ramp using the existing controller,
launches from Applications search, creates a shell variable, then drags the live
panel to the west pad through pointer and wheel events. It checks actual physics
support and pad contact. Another stool moves and rotates, settles on the floor,
and survives a subsequent cancelled drag without moving the application.

The player walks back down the ramp into the square and returns, with no player
or application position assignment/teleport during the trial. The fixture sets
heading to route waypoints; movement uses injected W/Shift through the ordinary
controller. The same panel object, random entity ID, runtime handle, transform,
shell PID and variable survive. Live client pixels/revisions advance while away.
Double-click reactivates the same shell; `exit` closes it and shutdown reaps
owned children. The tables and stools contain no application process identity.

See [the evidence index](../evidence/p22-t07/README.md) for final shell outputs,
render inspection, commands, verification and environment limits.

## Defects found during implementation

The first test invocation found an inferred GDScript type error in the new test;
the target Vector3 now has an explicit type. The first complete trial passed,
but actual renders showed thin, widely spaced raised planks obscuring the pad:
the beam writer's width and depth axes were reversed. Corrected dimensions now
match the tabletop collision. That first layout faced the outer boundary;
tables were moved to the north side so the working view overlooks the square.
The full real-client trial was rerun on final geometry. The existing outdoor
startup test then rejected any pushable furniture as legacy study geometry. Its
intended behavior now includes the two new stools: the test requires exactly
those named pavilion children while preserving the old-script/door exclusions.
Earlier render evidence is retained and labeled separately; it is not final
acceptance.

The existing two-client trial failed twice on the shared X11 display, first at
Vim reactivation, then earlier during typing/search. The unchanged trial passes
on the repository's documented private Weston headless GL/fake-seat path. Both
failed logs and the failed activation render are retained. Temporary diagnostics
were removed; no runtime focus policy change or general focus repair is claimed.
The exact source of shared-host interference was not established. This task uses
the isolated path for remaining graphical interaction checks.

The full retained-study regression suite cannot load legacy models/textures:
this checkout's untracked asset cache contains only `.gdignore`, and the existing
staging helper fails on the first missing glTF. The four earlier headless checks
pass; later retained-study trials remain unverified, not skipped passes.
See the evidence index for exact errors and restoration/rerun commands. The
available default-world interaction trials are run separately without changing
their assertions. No study repair or asset acquisition project was started.

## Final verification

P22-T07 acceptance passes: final shell `43110:at-my-desk`, unchanged entity and
placement, 50 background revisions, committed/cancelled stool operations and
client-owned close. Eight final actual pavilion renders were inspected.
Import/startup/bridge build; headless/GPU architecture, landscape and outdoor;
unchanged isolated Terminal/Vim trial; six default-world graphical interaction
checks; four headless transform/map/runtime checks; 11 Python and 62 Node tests
pass. Model rebuilds, syntax, documentation links, task parsing and diff checks
pass. No new native source, dependency or host service change.

The Chrome test also fails explicitly on its missing installed desktop entry;
this machine has no Google Chrome executable. Browser and full retained-study
coverage remain unavailable and are not claimed as passes. Exact commands,
outputs, images and all limitations are in the evidence index.

## Limits and boundary

Evidence is agent-injected input and agent-observed actual Godot renders,
not human comfort, latency, owner art approval or a performance benchmark.
This machine is not a Steam Deck. Small world previews remain thumbnails;
the native application view is the readable text endpoint. Existing client,
keyboard, shared-memory and restart-persistence limits remain in effect.

**Stop after P22-T07. P22-T08 and all later tasks remain unstarted.**
