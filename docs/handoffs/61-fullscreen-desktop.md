# Fullscreen startup and host shortcuts (2026-11-01)

Owner requested fullscreen startup, a standard toggle back to a window and a
standard quit shortcut. This bounded desktop revision advances no P22 task or
human gate. Existing uncommitted P22-T13 work remains separate.

The project defaults to ordinary fullscreen. F11 toggles to a resizable window
and back; Alt+F4 quits the whole Elsewhere runtime, including its owned clients.
These shortcuts are reserved even in application mode and launcher search.
Ctrl+Q and modified F11 are not reserved. The window starts at 1280×800 when
first restored and remembers a resized window's dimensions for later toggles.
Use `tools/run-godot.sh -- --windowed` to start in a development window.
No host session, display configuration, service or native installation changes.

`desktop_window.gd` is the last child created by DesktopRuntime, so reverse
scene-tree input dispatch reaches it before launcher/application forwarding.
It consumes the reserved key's press, repeats and matching release, including
when a modifier is released first. DesktopRuntime owns the idempotent quit
request shared by Alt+F4 and the host close notification. Existing terminal
shutdown still owns compositor stop and child cleanup. World/application help
now exposes both shortcuts; world help is anchored to the viewport bottom.

The pinned engine's native `--windowed` did not override fullscreen project mode
in the actual graphical trial. Its consumed engine flags also do not appear in
`OS.get_cmdline_args()`. The final implementation therefore uses an explicit
user argument after `--`, handled in DesktopWindow. The study regression wrapper
adds that argument while preserving its other fixture arguments. This keeps
its resize fixtures windowed without changing their assertions.

## Evidence

Base `580c302` plus the pre-existing P22-T13 working tree. Godot 4.7.2,
Compatibility/OpenGL on NVIDIA RTX 3080, host X11 backend. Evidence is
agent-injected/agent-observed; physical-keyboard and Wayland-host behavior,
human comfort and target-device performance remain unobserved.

Import/default startup, the native bridge build, and the existing two-session
headless desktop lifecycle test pass. The focused graphical trial exercises
default fullscreen and explicit windowed startup, F11 in world/search/client
modes, unchanged modified F11, repeat/release filtering, restored 1000×700
window size, same live terminal/entity after resize, shell-written output and
Alt+F4 from both application and launcher modes. Process-finalization assertions
check the compositor is stopped, its socket directory is gone and its terminal
PID is no longer running. Actual rendered captures are in
`.tools/desktop-window-test/` and require inspection with each fresh trial.

Final focused logs: `/tmp/elsewhere-window-check.GV2fJq/`, both
`DESKTOP_WINDOW_OK failures=0`, with explicitly different initial modes and
quit contexts. Fullscreen reported 2259×1271; windowed startup was 1280×800.
Agent inspected fullscreen world/application, restored 1000×700 and windowed
startup captures: readable, correctly positioned help and live content, with
no overlap from the new shortcut footer. These are application viewport
captures, not a physical desktop/window-decoration observation.

Existing `terminal_resize.gd -- --windowed` passes four sizes with cell grids
77×22, 95×25, 68×18 and 103×26, plus 8,573 exact client-pixel checks. Log:
`/tmp/elsewhere-window-resize.log`. Validation and headless logs:
`/tmp/elsewhere-fullscreen-validation.log`, `/tmp/elsewhere-window-headless.log`.
Launcher argv Python test, Node task/parser test file, shell syntax, local
documentation links, unchanged task checkboxes and diffs pass. No C++ source
changed; no fresh full native suite or asset-dependent study suite is claimed.

The initial script needed explicit boolean type annotations. The initial
windowed test inferred its expectation from consumed engine flags and therefore
did not test windowed startup; it was corrected to assert the explicit user
override. The typing marker is deleted before each trial to reject stale evidence.

Next task: stop after this owner request. Do not resume P22-T13 or another
roadmap task automatically. Restart Elsewhere to use the fullscreen default.
