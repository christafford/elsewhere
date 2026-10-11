# Godot world frontend

The default scene is **village reference 2**, the owner's weathered mountain
village direction, selected on 2026-10-11. Gray plaster/stone, aged timber, ivy,
a pointed hall turret,
a tiered stone fountain, dark cobbles and a cloud/mountain backdrop replace
the first reference's bright planted courtyard. Building footprints, the
approximately 84m playable terrain, four approach routes, spawn and pavilion
access remain unchanged. Mountains are decorative beyond the existing boundary;
buildings remain sealed exteriors. There are no new functional destinations.

Compare nine matching actual render viewpoints in
[the comparison page](../docs/art-direction/compare.html). Reference 1 is
preserved at `340ca97` / local tag `art-reference-1`; see
[safe switching and verification](../docs/handoffs/44-village-reference-2.md).
P22-T05 refines this selection with curated materials, foliage and daylight;
see [the render review](../docs/handoffs/45-village-materials.md). The comparison
page preserves the two earlier checkpoints.

The seven active original GLB models and import settings are included.
The former bridge remains tracked but inactive. Optional deterministic rebuild:
`python3 world/tools/build_village_models.py` (standard library only).
See [model provenance and dimensions](art/village/README.md) and
[tracked Poly Haven material maps](art/village/textures/README.md).
`python3 world/tools/verify_village_materials.py` verifies them offline;
project validation runs the same check. No material download is needed to launch.

The existing player controller and desktop runtime are reused. Startup opens
no application; use Tab / Applications to launch a terminal or another installed
application. Home returns to the level square. P22-T05 material/render
acceptance is agent-observed; owner art review and
explicit authorization remain required before the P22-T06 integration gate.

From the repository root, using the existing pinned tools:

```sh
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy
```

No study assets are needed by the default scene. The launcher builds and stages
`addons/elsewhere_runtime/` using the repository's godot-cpp checkout and C++
build dependencies. Godot uses Compatibility/OpenGL. `/usr/bin/weston-terminal`
runs on the private compositor socket when requested. `-- --terminal` starts
the initial `/bin/sh` with isolated configuration, prompt and repository-local
shell history; `-- --terminal-demo` starts the changing-output demo. A missing
requested terminal is an explicit error, with no simulated fallback.
Fresh-machine bootstrap remains unfinished.

`tools/run-godot.sh --editor` opens the editor. `build/elsewhere --room-camera`
remains a separate legacy renderer. For changing real terminal output:

```sh
tools/run-godot.sh --audio-driver Dummy -- --terminal-demo
```

Closing the Godot window stops its server and owned applications. Host desktop
settings stay unchanged. `-- --no-terminal` disables the compositor/terminal
adapter for isolated geometry checks (including when `--terminal` is also
supplied); the application-status label reports this in the world.

| Control | Action |
| --- | --- |
| W/A/S/D | Walk relative to heading; A/D strafe |
| Hold right mouse | Look; release frees the pointer |
| Shift | Walk faster |
| Ctrl / M | Hold / toggle slow walking |
| Space | Jump while grounded |
| Escape | Release pointer, cancel a grab and stop movement |
| Home | Return to this scene's safe arrival pose |
| Enter / double-click a panel | Activate the selected application |
| Ctrl+Alt+Escape | Return from application mode to the world |
| Tab / Applications button | Open the application launcher in world mode |
| Left-drag a panel | Move/carry it; WASD and mouse-look remain available |
| Wheel while dragging | Adjust distance |
| Both buttons + wheel | Rotate the held panel |

Application mode uses physical US keyboard positions. Ordinary application
keys, including Space, Escape, Tab, Home and WASD, belong to the client. Pointer
selection/scroll and actual client resize retain their existing paths. Host
focus loss returns to world mode and releases held input. Type `exit` to close
the shell and use Applications to relaunch. Clipboard, popup menus, IME and GPU
client-buffer support retain their documented limitations. Placements are
session-local; restart restoration is not implemented.

## Retained study and tests

The old physical world is preserved as `scenes/study.tscn`, with its scripts and
assets unchanged. It is loaded only explicitly, including by study-specific
regressions. To run it using the existing asset cache:

```sh
python3 world/tools/prepare_study_assets.py
tools/run-godot.sh --audio-driver Dummy res://scenes/study.tscn
# The study's historical capture command remains available explicitly.
tools/run-godot.sh --audio-driver Dummy res://scenes/study.tscn -- --capture=/tmp/elsewhere-study
```

Asset preparation verifies manifest SHA-256 values and stages complete glTF
packages; it does not fetch missing assets. Do not discard those sources/cache.

```sh
# Exterior collision, pavilion access, and eye-level architectural captures.
tools/check-godot-architecture.sh
# Ground coverage/grades, full route walks, and eye-level approach captures.
tools/check-godot-landscape.sh
# Headless and graphical default startup, boundary collision, live terminal.
tools/check-godot-outdoor.sh
# Retained study geometry plus general desktop checks on the current default.
tools/check-godot-study.sh
# Existing bounded real-Chrome compatibility regression on the current default.
tools/check-chrome-application.sh
```

Architecture captures are written to `.tools/village-architecture-test/`.
Landscape captures are written to `.tools/village-landscape-test/`; the outdoor
startup check writes `.tools/outdoor-startup-test/`.
Open them for visual review. Headless checks cannot supply visual acceptance;
injected input and screenshots do not establish human comfort or comprehensive
application compatibility. See [status](../docs/STATUS.md) and the
[P22-T04 handoff](../docs/handoffs/42-village-architecture.md) for exact evidence.

The old experimental bridge remains under `addons/elsewhere_godot/`, excluded
from discovery by `.gdignore`. The standard binding's protocol/owned-frame
regression command remains `tools/check-godot-binding.sh`.
