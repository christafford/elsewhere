# Faster normal travel (2026-11-01)

Owner requested normal movement as fast as the existing Shift movement.
`game_world.gd` raises normal walking from 2.4 to 4 m/s. Shift stays at 4 m/s;
Ctrl and the M slow-walk toggle retain 1 m/s. The help overlay removes the
obsolete faster-Shift instruction. No numbered roadmap or human gate advances.

Base revision: `3d08605`; working tree was clean. No native code changed.

## Verification

- `ELSEWHERE_ASSETS_OFFLINE=1 tools/validate-godot-project.sh` with isolated
  editor settings: asset preparation/verification, bridge build, import and
  startup pass. Logs: `/tmp/elsewhere-godot-check.MGtIeU`.
- `tools/check-godot-head-bob.sh`: headless, disabled-bob and graphical checks
  pass. New injected-input assertions verify normal/Shift 4 m/s, Ctrl/M 1 m/s,
  normalized diagonal speed and zero velocity in application mode. Existing
  checks cover four-direction travel, ground contact, wall collision, stopping,
  airborne fade, focus loss, Home and the 2cm bob bound.
  Logs: `/tmp/elsewhere-head-bob-check.XdYp8Y`.
- `tools/check-godot-help.sh`: live terminal typing before/after modal help,
  world-input isolation, launcher focus and small-window layout pass.
  Log: `/tmp/elsewhere-help-check.kJJa1z`.
- Agent inspected current walking-high/low renders in `.tools/head-bob-test`
  and `world-help.png` in `.tools/help-overlay-test`: upright village views
  without camera clipping and legible help without the obsolete Shift line.
  Captures remain ignored per the source-only policy.

Graphical checks used Godot 4.7.2 Compatibility/OpenGL on RTX 3080 at 1280×800
in private headless Weston outputs, using `.tools/p22-t14/godot-private.sh` as
`GODOT_BINARY`. Protocol/cursor and shader-cache fallback warnings were benign;
all check markers reported zero failures. These are agent-injected checks and
render inspection, not human motion-comfort acceptance. No full stairs or
native regression suite was rerun for this controller constant change.

Restart Elsewhere to load the new walking speed. Stop after this request.
