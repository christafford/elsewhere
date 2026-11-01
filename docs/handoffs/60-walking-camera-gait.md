# Walking camera gait (2026-11-01)

Owner requested slight up/down camera movement to simulate walking. This is a
bounded navigation revision outside the numbered village roadmap; no P22 task
or human gate advances. Existing uncommitted P22-T13 files were present at the
start and are preserved separately.

`game_world.gd` adds a camera-only sine offset, at most ±0.02m, advancing one
cycle per 1.4m of resolved horizontal travel while grounded. Amplitude eases
in/out and scales down at slow speeds. Collision, yaw/pitch, jump and movement
speeds are unchanged. Stopping or pushing into a wall settles the camera;
jumping fades the gait. Input release, application/launcher entry, focus loss
and Home restore eye height and reset the phase. `--no-head-bob` or exported
`head_bob_amplitude = 0` disables it without reserving an application key.

## Verification

Base HEAD: `00d6076`, plus the pre-existing P22-T13 working tree. Godot 4.7.2,
Compatibility/OpenGL, NVIDIA RTX 3080, 1280×800. Agent-injected tests, not a
physical-input, human-comfort or target-hardware acceptance trial.

- `env XDG_CONFIG_HOME=/tmp/elsewhere-head-bob-config tools/validate-godot-project.sh`:
  bridge build, asset verification, import and default startup pass.
- `bash tools/check-godot-head-bob.sh`: headless, disabled and graphical trials
  pass. All four directions oscillate within ±0.02m; disabled motion is exactly
  zero. Tests verify ground contact, unchanged pitch, settling, wall collision,
  airborne fade, application suspension, focus loss and Home.
  Logs: `/tmp/elsewhere-head-bob-check.cfUyMi/`.
- Agent inspected actual `idle.png`, `walking-high.png` and `walking-low.png`
  captures in `.tools/head-bob-test/`: stable upright village view and HUD, no
  visible camera clipping. High/low captures also include forward travel, so
  their image difference is not a measurement of bob amplitude. Numeric
  assertions establish its bound; these stills do not prove motion comfort.
- `tools/check-godot-village-applications.sh` with the same temporary config and
  `SDL_JOYSTICK_LINUX_CLASSIC=1`: real Terminal/Vim launch, panel manipulation,
  12.29m walk away and back, live instance/shell/editor continuity, resumed
  input and close pass (`VILLAGE_APPLICATIONS_OK clients=2 failures=0`).
  Agent inspected the revisited terminal and editor captures in
  `.tools/village-applications-test/`; their application views remain upright
  and readable in the captures. Log: `/tmp/elsewhere-head-bob-applications.log`.
- Node task/parser test file, shell syntax, local documentation links and
  task-checkbox preservation pass. No C++ source changed; native bridge build
  passes, but no fresh full native or retained-study suite is claimed.

Initial sandbox validation could not open sockets/save editor settings. Rerun
outside the sandbox with temporary editor settings passed. The first focused
test needed an explicit scene type annotation; its initial body-height check
incorrectly assumed flat ground. It now checks against actual terrain height.
Production bob code needed no workaround for either test issue.

Human comfort remains unobserved. Restart Elsewhere to load the controller.
Next task: stop after this requested gait change; do not resume P22-T13 or any
other roadmap work automatically.
