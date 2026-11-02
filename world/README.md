# Godot world frontend

The current engine is **Godot 4.8 beta 2**. Prepare the pinned engine and C++
bindings with `python3 tools/prepare-godot.py` (`--offline` reuses verified
local files/cache). Launch and acceptance scripts share the `tools/godot`
wrapper. The launcher now adds fuzzy name matches after exact keyword matches;
recent-app titles fit their slots within a 12–15px font range. Navigation and
object placement reuse typed physics results. **Forward+/Vulkan** is the desktop
renderer, with 4.8 contact shadows, multi-bounce occlusion and streamed world
textures. A working Vulkan-capable GPU/driver is required for graphical launch;
headless operation is retained. See [Decision 09](../docs/decisions/09-godot-48-prerelease.md)
and [toolchain](../docs/TOOLCHAIN.md) for the prerelease/stable update procedure.

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

Original models are generated from tracked Python sources during build/launch;
import settings remain tracked. Nine pinned Poly Haven maps are downloaded only
when neither verified runtime files nor a verified cache is available. Run
`python3 world/tools/prepare_world_assets.py` to prepare assets independently,
or add `--offline` to require cached textures. Build/launch accepts the equivalent
`ELSEWHERE_ASSETS_OFFLINE=1`. See [model provenance](art/village/README.md),
[material provenance](art/village/textures/README.md) and
[history/archive policy](../docs/handoffs/67-source-only-history.md).

The existing player controller and desktop runtime are reused. Startup opens
no application; use Tab / Applications to launch a terminal or another installed
application. Home returns to the level square. The owner authorized P22-T06 on
2026-10-12, proceeding with version 2 past the art checkpoint. Material/render
and live-application checks are agent-observed; human comfort and final Project
22 acceptance remain separate. See [the integration handoff](../docs/handoffs/46-village-applications.md).

From the repository root, using the existing pinned tools:

```sh
tools/validate-godot-project.sh
tools/run-godot.sh --audio-driver Dummy
```

**F1** opens the complete commands and techniques overlay from the world,
launcher or application view. F1, Escape or Close dismisses it. Scroll on small
windows. Help releases held input and restores the previous view on dismissal;
applications keep running. `?` remains ordinary text everywhere. The world and
application views have no persistent instructional text.

Elsewhere opens fullscreen. **F11** toggles between fullscreen and a resizable
window; **Alt+F4** quits Elsewhere and closes its owned applications. These are
reserved host shortcuts, alongside F1, in the world, launcher and application
view. Other application shortcuts, including Ctrl+Q, continue to reach the client.
For development, start windowed with `tools/run-godot.sh -- --windowed`
(the `--` separator is required). F11 returns to the last window size, initially
1280×800. This remains a nested application; it does not replace the host session.

No study assets are needed by the default scene. The launcher builds and stages
`addons/elsewhere_runtime/` using the repository's godot-cpp checkout and C++
build dependencies. Godot uses Forward+/Vulkan. `/usr/bin/weston-terminal`
runs on the private compositor socket when requested. `-- --terminal` starts
the initial `/bin/sh` with isolated configuration, prompt and repository-local
shell history; `-- --terminal-demo` starts the changing-output demo. A missing
requested terminal is an explicit error, with no simulated fallback.
Engine/binding and world-asset bootstrap are reproducible; system build,
Wayland and Python/GIO dependencies must already be installed.

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
| F1 | Open / close the commands and techniques overlay in any view |
| F11 | Toggle Elsewhere fullscreen / windowed, in every input mode |
| Alt+F4 | Quit Elsewhere and close its owned applications |
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

Application mode keeps the live world visible around the focused application
at the same camera viewpoint. The surrounding area does not accept world input.
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
# Real Terminal + Vim: search launch, manipulate, walk away, revisit and close.
tools/check-godot-village-applications.sh
# Retained study geometry plus general desktop checks on the current default.
tools/check-godot-study.sh
# Existing bounded real-Chrome compatibility regression on the current default.
tools/check-chrome-application.sh
```

Architecture captures are written to `.tools/village-architecture-test/`.
Landscape captures are written to `.tools/village-landscape-test/`; the outdoor
startup check writes `.tools/outdoor-startup-test/`.
The multi-application trial writes `.tools/village-applications-test/`; it
requires installed Weston Terminal and Vim plus a graphical display.
Open them for visual review. Headless checks cannot supply visual acceptance;
injected input and screenshots do not establish human comfort or comprehensive
application compatibility. See [status](../docs/STATUS.md) and the
[P22-T04 handoff](../docs/handoffs/42-village-architecture.md) for exact evidence.

The old experimental bridge remains under `addons/elsewhere_godot/`, excluded
from discovery by `.gdignore`. The standard binding's protocol/owned-frame
regression command remains `tools/check-godot-binding.sh`.
