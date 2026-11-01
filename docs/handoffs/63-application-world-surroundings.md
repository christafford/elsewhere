# Application view in its world setting (2026-11-01)

Owner request: retain the existing application view size and replace its wasted
black surroundings with the world view from which the application was opened.
This bounded desktop revision advances no P22 task or human gate. Existing
P22-T13 changes remain separate.

Removed the opaque full-window ColorRect from `application_mode.gd`. The live
scene already renders behind the application CanvasLayer, and the existing
transition leaves the camera in place. Client sizing, native pixels, focus,
input routing and transitions remain unchanged. The surrounding scene is live,
not a captured image; visible margins still cannot initiate world/client input.

## Evidence

Base `437511e` plus the pre-existing P22-T13 working tree. Agent-injected and
agent-observed on Godot 4.7.2, Compatibility/OpenGL, NVIDIA RTX 3080/X11.

- Import/default startup and native bridge build pass:
  `/tmp/elsewhere-world-margin-validation.log`.
- Extended the existing live-terminal transition regression with outside-client
  pixel comparisons against the actual world at 1280×800 and 1000×700, and
  left/right margin-click isolation. Before the change, every sampled margin
  pixel failed (1864/1864 and 1632/1632); afterwards it passes with zero failures.
  Existing native client pixels, resize during flight, reversal, focus-loss and
  client-close assertions also pass: `/tmp/elsewhere-world-margin-transition.log`.
- Existing four-size real-terminal resize/selection test passes with 9,444 native
  pixel samples: `/tmp/elsewhere-world-margin-resize.log`.
- F1 help, punctuation typing, restored focus, modal lifecycle and responsive
  layout checks pass: `/tmp/elsewhere-world-margin-help.log`.
- All 62 Node tests (including task parsing), documentation links and diffs pass.

Agent inspected actual `world-before-application.png`, `application.png` and
`application-resized.png` in `.tools/application-transition-test/`: the village
remains visible at the same viewpoint around the readable client. These renders
and injected tests do not claim human physical-input, comfort, Wayland-host or
target-device acceptance.

Next task: stop after this request. Restart Elsewhere to load the change; open
an application and inspect its surroundings, then return with Ctrl+Alt+Escape.
Do not resume P22-T13 or another task automatically.
