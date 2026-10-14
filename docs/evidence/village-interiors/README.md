# Enterable village ground floors — runtime evidence

2026-10-14, Codex agent-run/agent-observed, based on `228a550` plus this bounded
owner request. These are actual Godot renders with real Wayland terminals,
not mockups or screenshot replay. See [handoff 54](../../handoffs/54-building-interiors.md)
and [Decision 08 amendment](../../decisions/08-elsewhere-village-world.md).

| Building | Interior | Live application on desk | Open entry | Same shell after returning |
| --- | --- | --- | --- | --- |
| Lodge | [Room](lodge-interior.png) | [Desk](lodge-workspace.png) | [Doorway](lodge-entry.png) | [Terminal](lodge-same-shell.png) |
| Guildhall | [Room](guildhall-interior.png) | [Desk](guildhall-workspace.png) | [Doorway](guildhall-entry.png) | [Terminal](guildhall-same-shell.png) |
| Workshop | [Room](workshop-interior.png) | [Desk](workshop-workspace.png) | [Doorway](workshop-entry.png) | [Terminal](workshop-same-shell.png) |

Exterior views: [square](arrival-exterior.png), [lodge](lodge-exterior.png),
[guildhall](guildhall-exterior.png), [workshop](workshop-exterior.png). Open
entrances are visible from the square and the ramps stay separate.

The rooms have solid floor/ceiling/wall faces, clear central circulation and
warm material detail. The workshop keeps its masonry chimney and stone walls;
the lodge and hall use cream plaster. Upper floors/windows remain decorative.
Panels remain visibly live; application mode preserves readable real-client
text and pixels. Human aesthetic/physical-input acceptance is not claimed.

The new fixture walks through every entry and along the full room depth, checks
floor samples/enclosure and both desks' clearance, then places a terminal with
mouse/wheel input. Leaving/re-entering retains entity, transform, PID and shell
variable. Revisited typing, client close, owned-client shutdown and Home pass.
Headless and graphical logs: [headless](headless.txt), [graphical](graphical.txt),
[import/build/helper](check.txt).

## Retained checks

- [Architecture](architecture.txt): headless/GPU facade collision, pavilion access,
  work-pad clearance and Home pass; final square/building renders inspected.
- [Landscape](landscape.txt): both modes traverse 337.8m across all four routes;
  24,178 ground samples pass, maximum floor gap about 5.6mm.
- [Outdoor](outdoor.txt): both modes pass empty startup, real launcher/client,
  movement/jump, all ten boundaries, Home and the applicable panel/input checks.
- [Pavilion](pavilion.txt): existing desk placement, stool move/rotate/cancel and
  same-shell return pass; 48 background revisions advance. [Render](pavilion-revisited.png).
- [Village applications](village-applications.txt): real terminal and unsaved Vim
  buffer survive walking/manipulation/revisit; 22 background revisions advance.
  [Terminal](terminal-revisited.png), [editor](editor-revisited.png).
- [Firefox](firefox.txt): real typing/clipboard/click, world return/reuse, extra
  windows, confirmed close and profile relaunch pass. [Render](firefox-relaunched.png).
- All six default graphical checks pass: [screen colors](screen_color.txt),
  [keyboard](terminal_input.txt), [pointer/scroll](terminal_pointer.txt),
  [resize](terminal_resize.txt), [launcher](app_launcher.txt) and
  [transitions](application_transition.txt). Exact gray/RGB swatches survive.
  [Complete regression run](regressions.txt).

## Reproduction

From repository root with an available graphical display:

```sh
tools/check-godot-interiors.sh
tools/check-godot-architecture.sh
tools/check-godot-landscape.sh
tools/check-godot-outdoor.sh
tools/check-godot-pavilion.sh
tools/check-godot-village-applications.sh
tools/check-firefox-application.sh
python3 -m unittest discover -s tests -p 'test_*.py'
node --test .opencode/tests/*.test.js
```

This session set `GODOT_BINARY="$PWD/.tools/interiors/godot-check.sh"` to a local
wrapper using the private Weston setup documented in
[the Firefox evidence](../firefox-launch-fix/README.md). Headless calls invoke the
pinned Godot directly. Graphical calls run Weston with
`--backend=headless --fake-seat --renderer=gl --width=1280 --height=800`, a unique
socket, `--idle-time=0 --no-config`, then Godot with `--display-driver wayland`.
The resize fixture uses 1600×1000. Godot 4.7.2, Compatibility/OpenGL 3.3,
NVIDIA RTX 3080/615.78.08, Weston 15.0.1. No host session/service changes.

The six existing default graphical fixtures run with isolated launcher state,
`--path world --audio-driver Dummy --max-fps 60 --script res://tests/<name>.gd`:
`screen_color`, `terminal_input`, `terminal_pointer`, `terminal_resize`,
`app_launcher`, and `application_transition`.

## Iterations and limits

An initial long workshop approach crossed the guildhall ramp. Shorter ramps
separate them, and level landings remove the lodge floor-edge snag seen in
[the superseded threshold trial](initial-threshold.txt). The rotated workshop
fixture initially aimed its camera independently of the player's launch heading;
[that superseded trial](initial-camera-heading.txt) failed placement. Final
input setup matches ordinary player yaw/camera pitch, and clearance probes
use the building basis. No production controls or assertions were bypassed.
The startup furnishing assertion now requires exactly the eight stools across
the four workspaces, replacing its [old pavilion-only expectation](initial-furnishings.txt)
while keeping the ban on unexpected/legacy furniture.
A small front-corner foundation gap discovered during final exterior inspection
was removed by extending the foundations farther below the terrain.

The original building model pipeline has a byte-identical rebuild:
[SHA-256](models.sha256). Fourteen [Python](python.txt) and 62 [Node/parser](node.txt)
tests pass. [Document validation](documentation.txt), Python/Bash syntax and
diff checks pass; roadmap checkboxes stay unchanged. Nine existing material-map hashes verify offline. Logs trim trailing
whitespace only. Optional Weston decoration/activation/icon and cursor-theme
warnings are recorded; failed assertions are not treated as passes.

No fresh full C++/Meson result is claimed: native behavior is unchanged, while
the normal Godot validator builds the bridge. Chrome and retained-study source
assets remain unavailable. No restart persistence, target-device/sustained
performance, owner art approval or P22-T09/P22-T10 acceptance claim.
