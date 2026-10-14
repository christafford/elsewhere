# Enterable village buildings — bounded owner request

2026-10-14, based on `228a550`. The owner requested entering the existing
buildings and enlarging them for useful interiors. Decision 08's dated amendment
permits these three ground floors. This advances no numbered P22 task and does
not authorize P22-T09, P22-T10 or another destination.

## Implementation

The Lodge, Guildhall and Workshop have real open door apertures, thick walls
with inside faces, wood floors, ceilings/beams, wall trim and pendant lights.
The original model generator extends their rear halves by 65% (32.5% greater
total depth), preserving the front planes and square-facing routes. Approximate
inner wall rectangles are 9.4 × 9.2m, 7.2 × 7.9m and 7.4 × 7.9m respectively,
before furniture/trim and the workshop chimney. Doorways are 2.44m wide and
about 2.59m high; ceiling beams leave about 2.95m.

`village_architecture.gd` samples the enlarged rotated footprints for foundation
height. Visible stone ramps and level threshold landings replace the exterior
steps, so the unchanged controller walks in/out without jumping or a door key.
Collision still comes from the rendered meshes. Each location instantiates the
existing pavilion workspace: two fixed worktables, physical teal pads and two
movable stools. The workshop's east stool is offset to clear its chimney.
One warm local light per room illuminates the architecture.

No compositor, runtime ownership, launcher, panel identity, input policy,
placement service, application shader, controller, terrain or scene-entry-point
change. No dependency, downloaded asset, native-session or host-service change.
Models/provenance are in [the asset record](../../world/art/village/README.md).
Upper floors, turret, exterior windows and lean-to remain decorative. There is
no new door animation, sitting interaction or persistence across restarts.

## Verification and iteration

Checks and actual renders are agent-run/agent-observed on Godot 4.7.2,
Compatibility/OpenGL 3.3, NVIDIA RTX 3080/615.78.08, private Weston 15.0.1 GL/
fake-seat at 1280×800 (1600×1000 for the existing resize fixture).

The new `tools/check-godot-interiors.sh` exercises actual controller walking
through every doorway, along each room's full depth and back outside. It checks
floor samples, side/rear/ceiling enclosure, both desk clearances and Home. Its
GPU trial launches a real terminal in each room, records PID/variable, places
the live panel by mouse drag/wheel, walks away and returns, verifies entity and
transform continuity, types into the same shell, closes it and shuts down owned
clients. Captures show each room, placed application, open entry and revisited
shell. Input is agent-injected; it is not human comfort acceptance.

The first five-meter workshop ramp overlapped the guildhall approach and blocked
exit. Shorter three-meter ramps remove that intersection; level landings avoid
the capsule catching the floor edge on the steeper lodge approach. The fixture
initially aimed only its camera in the rotated workshop; matching normal player
yaw/camera pitch fixes that test setup. Desk clearance probes likewise use the
building's basis. No runtime input behavior or collision assertion was weakened.
An initial missing test preload was corrected before verification.
The startup fixture previously allowed only the two pavilion stools; its exact
expected set now includes the six authorized interior stools, still rejecting
legacy/unexpected furnishings. Final exterior inspection found a small foundation
gap at a low lodge corner; deeper buried foundations remove it.

Final interior, architecture, landscape and outdoor headless/GPU checks pass.
Both landscape modes walk 337.8m. The pavilion retains its shell and moved stool
with 48 background revisions; the Terminal/Vim trial preserves its shell and
unsaved buffer with 22 revisions. Firefox typing/clipboard/click/reuse/multiwindow/
confirmed close/relaunch and all six default graphical interaction regressions
pass, including exact gray/RGB swatches. Import/default startup/bridge build,
14 Python and 62 Node/parser checks, deterministic model regeneration, syntax,
links/task-reference and diff validation pass. Final renders were inspected.
See the [evidence index](../evidence/village-interiors/README.md) for logs and captures.

## Owner trial and limits

Restart Elsewhere, walk up the open front entrances, and explore the rooms.
Tab launches an app; Ctrl+Alt+Escape returns to the world. Drag a panel above a
teal desk pad, release, leave and return, then double-click it to resume work.
The pavilion and existing square routes remain available. Human visual approval,
physical-input comfort and Steam Deck/sustained performance are not observed.
Chrome and retained-study source assets remain unavailable. No fresh full native
suite is claimed for this scene-only revision.

Next: stop after this owner request. P22-T09 and human P22-T10 stay unchecked;
no autonomous continuation is authorized.
