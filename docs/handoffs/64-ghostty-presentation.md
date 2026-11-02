# Ghostty application sizing and world copy (2026-11-01)

Bounded owner-reported desktop repair from `7d661b7`, with pre-existing P22-T13
changes left separate. No numbered task or human gate advances.

## Reproduction and repair

The real fullscreen comparison at 2259×1271 reproduced Ghostty's 1280×800 view
while Alacritty reached approximately 2048×1207 (decorations affect the displayed
rectangle). Ghostty acknowledged/committed the larger configure but kept its
size within the compositor's fixed 1280×800 `wl_output`. The windowed 1280×800
trial did not reproduce the size discrepancy. Both trials exposed the restored
world panel while the foreground application was active.

`CompositorRuntime::set_output_size` now owns the workspace extent, defaulting
to 1280×800 for standalone/headless callers. The frontend supplies its viewport
before client dispatch. Changed dimensions broadcast mode events to existing
bindings; v2+ receive `done`, v1 does not, and new bindings get current dimensions.
Repeated sizes send nothing. Native and 64-bit Godot input bounds are checked
before narrowing; output dimensions stay within 1–4096. This changes only the
private output, not the host display. Existing 2048px application configure and
frame allocation limits remain unchanged.

The application transition now keeps its source presentation hidden after
entry finishes. Return, cancellation and focus loss restore it. The physical
entity, placement, collision and live texture remain in place. Other application
panels retain their existing presentation policy.

## Verification

Agent-injected and agent-observed: Godot 4.7.2 Compatibility/OpenGL, NVIDIA RTX
3080. Real installed desktop entries with existing user terminal configuration;
Ghostty reports 1.4.0-arch1.1. The comparison ran on X11 fullscreen; retained
regressions used isolated Weston GL/fake-seat with Godot's Wayland backend.

- Before logs: `/tmp/elsewhere-terminal-compatibility-before.log` (two duplicate
  failures), `/tmp/elsewhere-terminal-compatibility-fullscreen-before.log`
  (two size and two duplicate failures).
- After: `/tmp/elsewhere-terminal-compatibility-final.log`, zero failures.
  Ghostty reaches 2048×1207 fullscreen, 936×636 at 1000×700 and 1536×836 at
  1600×900. Alacritty follows the same suggestions with its decoration/shadow
  differences. Both retain shell state/entity/transform across return/revisit,
  accept typing, change terminal rows/columns and close with `exit`.
  Actual full application, world-return and resized renders inspected in
  `.tools/terminal-compatibility-test/`; world copy restored only on return.
- `meson compile -C build` and `meson test -C build --print-errorlogs`: 36/36.
  Logs: `/tmp/elsewhere-ghostty-build.log`, `/tmp/elsewhere-ghostty-tests.log`.
  Extended native lifecycle checks cover v1/v2/v3 output growth, shrink, late
  binding, invalid dimensions, stopped server and unchanged-size suppression.
- Full `tools/check-godot-binding.sh`: passes, including output binding bounds,
  33 protocol trials and retained frame/input/resize/surface-tree checks.
  `/tmp/elsewhere-ghostty-binding.log`. Expected negative-fixture protocol
  diagnostics are distinct from test failures.
- Import/default startup/bridge build: passes,
  `/tmp/elsewhere-ghostty-validation.log`. Initial sandboxed import failed on
  sockets/editor-settings writes; rerun used repository-local `XDG_CONFIG_HOME`
  outside the socket sandbox. A new fixture type-inference error was corrected
  before the successful real-terminal run.
- Retained `application_transition`, `terminal_resize`, `help_overlay`: pass;
  logs `/tmp/elsewhere-ghostty-<test>.log`. Transition checks include reversals,
  resize during flight, native pixels, world margins and focus/close cleanup.
  Four-size resize preserves selection and 9,444 sampled native client pixels.
- Node suite, shell syntax, documentation links/task references and diff checks
  pass. No unrelated source or village change included in this repair.

Reproduce the real-terminal check after building with
`bash tools/check-godot-terminal-compatibility.sh`; it requires installed
Alacritty and Ghostty and a graphical display. For retained checks, the private
Weston wrapper follows the procedure in the Firefox evidence directory with
1600×1000 output and `-- --windowed`.

Human physical-keyboard/mouse, comfort, target hardware and general application
compatibility remain unobserved. Alacritty's existing translucent background and
decoration scaling are unchanged. On very large displays, the existing 2048px
configure bound still limits application growth.

Next task: stop. Restart Elsewhere to load the rebuilt extension and scripts,
launch Ghostty, and return with Ctrl+Alt+Escape. Do not resume P22-T13 or another
task automatically.
