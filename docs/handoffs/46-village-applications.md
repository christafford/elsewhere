# P22-T06 — live applications in the village

2026-10-12, based on `a13b671`. The owner's explicit request to implement
**P22-T06 only** authorizes proceeding past the P22-T05 checkpoint with the
selected version 2 art. It does not supply personal comfort observations or
final Project 22 acceptance. Decision 08 and the updated AGENTS.md govern scope.

## Implementation boundary

The extracted DesktopRuntime already supplies the real launcher, compositor,
independent panels and application/world modes to the default outdoor scene.
No runtime fix or architectural change was necessary. World art, geometry,
controller, native source, client shaders and application lifetimes are unchanged.

`world/tests/village_applications.gd` adds the missing continuous outdoor
multi-application scenario. It inherits existing input, capture and real-client
helpers. `tools/check-godot-village-applications.sh` builds/stages the existing
bridge, validates imports/default startup, runs the bounded graphical trial with
isolated launcher history, and rejects errors, crashes, leaks or a failing marker.
Missing installed applications/display are failures, not substitute mock passes.

The trial opens Tab → search and types through injected GUI events, selects
the matching installed Terminal/Vim catalog row, then presses Enter. A real
shell writes its PID/session variable, then prints
changing timestamps while real Vim holds unsaved text. It commits pointer drag,
wheel depth and both-buttons/wheel rotation of the terminal, lets it settle on
the square, and checks the editor's transform is unaffected. It walks backward
down the south approach with S and forward with W, without setting player or
panel transforms or using Home/teleportation. It checks live revision/pixel
updates while away, unchanged entity objects/IDs and placements, double-click
focus after return, the same shell PID/variable and the same Vim buffer. Each
client closes itself; the other panel remains until its own close. Runtime
shutdown must reap launcher-owned children.

The first trial failed because the test typed Enter after the second Vim line,
creating a third blank line while expecting a two-line file. The saved file and
actual render showed both intended lines intact. The extra injected Enter was
removed; the exact two-line assertion is retained. This was a test authoring
error, not a lost-buffer defect or a relaxed acceptance assertion.

The existing Chrome regression reproduced its historical missing-initial-`E`
failure twice in sequential trials. Temporary DOM tracing found the old
`ready=true` report could have `document.hasFocus() == false`, despite element
autofocus and active Godot/compositor keyboard focus. The local browser fixture
now requires document focus too, and reports readiness on an animation frame
once that condition holds. The original exact text, trusted-event, pointer,
scroll, resize and lifecycle assertions are unchanged; no character is retried
or discarded, and no fixed delay or production input workaround was added.
Tracing was removed. [Failure and diagnosis evidence](../evidence/p22-t06/focus-diagnosis.txt)
records the readiness gap; this does not establish the cause of every historical
browser failure or general browser compatibility.

## Verification and evidence

The new trial passes with two real clients, a 12.291m outward walk and return,
24 background frame revisions, unchanged shell state `689740:still-here`, and
the exact preserved two-line Vim buffer. Both panels close and owned children
are reaped. Eight captures from this passing run were inspected: search,
two panels, committed placement, distant approach, revisit, terminal, editor
and the empty square after close.

Godot import/default startup and existing bridge build pass. Headless/GPU
outdoor checks and all seven dedicated graphical regressions pass: screen
color, terminal input, pointer, resize, launcher, retained-study application
objects and transitions. Eight Python and 62 Node tests pass. After the fixture
readiness correction, two complete Chrome runs pass exact trusted typing,
click/save, both scroll directions, resize/reflow, world return, a second
independent window and client-owned close. Three final browser renders were
inspected; the first failed render is preserved separately. Native source is
unchanged, so no fresh full Meson-suite result is claimed.

See [the evidence index](../evidence/p22-t06/README.md) for current outputs,
actual captures, environment, commands and verification results.

## Limits and stop boundary

This is agent-injected input to actual Wayland clients and agent inspection of
actual Godot renders. It is not a human interaction, latency or comfort trial,
owner visual approval, comprehensive application compatibility or a performance
benchmark. The browser's local HTML is labeled test content served to real
Chrome; it is not simulated browser rendering. World thumbnails have reduced
text detail; the native application view is the working text endpoint.

Existing limits remain: physical US keyboard mapping, incomplete popup/cursor/
clipboard/IME behavior, CPU/shared-memory presentation rather than general GPU
client buffers, and placement/identity persistence only within the session.
No restart restoration, new dependency, host service change or native install.
The retained study object regression is identified separately from the new
outdoor scenario. The existing empty/headless startup path remains supported.

**Stop after P22-T06. P22-T07 and all later tasks remain unchecked and unstarted.**
No pavilion furniture, anchors or new workspace behavior is included.
