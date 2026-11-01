# Commands and techniques overlay (2026-11-01)

The owner requested removal of permanent explanatory text in the world and
application view, then explicitly chose **F1 everywhere**, superseding the
initial question-mark binding. `?` remains normal input. This bounded revision
advances no numbered P22 task or human gate; existing P22-T13 edits stay separate.

DesktopRuntime now owns `help_overlay.gd`: a dimmed modal reference with four
sections for movement, launching/using apps, pushing/carrying/placing objects,
and desktop/application controls. At ordinary widths it uses two columns; at
small widths it stacks and scrolls, retaining the title and Close button.
F1 toggles it; Escape or Close dismisses it. The persistent movement/footer,
object hints, application header and launcher instructional notices are gone.
Applications remains an actionable button, and errors/status messages remain.
Application content is centered with equal margins and can occupy the freed
header area; pointer mapping and transition endpoints use the same view rect.

The overlay is behind DesktopWindow in input dispatch, so F11 and Alt+F4
remain available. Entry cancels a world grab, releases movement/look and
client keyboard/pointer state, and suspends underlying input. Clients continue
running and rendering. Dismissal restores the current client focus or previous
launcher search focus without replaying held keys. Focus loss dismisses help;
a client closing beneath help retains modal ownership until dismissal.

## Verification

Base `082e8d4` plus the pre-existing P22-T13 working tree. Godot 4.7.2,
Compatibility/OpenGL, NVIDIA RTX 3080, X11. Agent-injected and agent-observed
evidence only; no human physical-input, Wayland-host or target-device claim.

Import/default startup/native bridge build and the existing two-session
headless desktop lifecycle check pass. The focused graphical trial covers
grab cancellation, stopped walking, F1 repeat/release, normal question-mark
typing, launcher query/focus retention, modal keyboard/pointer isolation,
restored real-terminal typing, a close-button click, focus loss, fullscreen
toggle and client exit beneath help. It inspects 1280×800 and 640×480 layouts
and scroll reachability. Actual captures live in `.tools/help-overlay-test/`.

Final focused result: `HELP_OVERLAY_OK failures=0` in
`/tmp/elsewhere-help-check.xg9j6I`. Existing real-terminal four-size resize and
application transition trials pass (`/tmp/elsewhere-help-terminal_resize.log`,
`/tmp/elsewhere-help-application_transition.log`). The headless lifecycle result
is `DESKTOP_RUNTIME_OK sessions=2 failures=0`; 62 Node tests pass. Shell syntax,
document links/task parsing and final diffs also pass.

Agent inspected clean world/application views, the two-column command list,
and the narrow list at its top and bottom. The new text is readable, contained
inside the panel and reachable by scrolling; the main/application views have
no permanent instructions. The actionable Applications button remains.

Initial test input accidentally activated the focused Close button with Space
and Enter; the isolation test now uses non-activation keys. A real layout issue
retained old column minimum widths on shrink; layout now updates those widths
before applying the smaller panel size. No test assertion was weakened to hide
that failure.

Next task: stop after this owner request. Do not resume P22-T13 or another
roadmap task automatically. Restart Elsewhere to load the F1 overlay.
