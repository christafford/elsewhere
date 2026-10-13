# Sunlit village — actual render comparison

2026-10-13, Codex agent-run/agent-observed, base `a597286` plus this art revision.
[Owner reference](../../art-direction/art-direction-1.jpg),
[art brief](../../ART-DIRECTION.md), [handoff](../../handoffs/53-sunlit-village-palette.md).
These are actual Godot captures, not mockups or the reference image presented as
runtime output. Application text is produced by real Wayland clients.

| Matched view | Previous palette | Sunlit palette |
| --- | --- | --- |
| Arrival | [Before](before/arrival.png) | [After](arrival.png) |
| South approach | [Before](before/south-return.png) | [After](south-return.png) |
| North distance | [Before](before/north-outlook.png) | [After](north-outlook.png) |

Further final views: [east](east-outlook.png), [south](south-outlook.png),
[west](west-outlook.png), [pavilion edge](pavilion-edge.png),
[building group](east-square.png), [plaster/oak](plaster-timber.png),
[foliage](foliage.png), [pavilion](pavilion.png).
Warm roof courses, cream walls and wood are distinct; paving stays neutral enough
to support them. Greens retain shade variation against blue mountain distance.
Close views retain texture grain and clear steps. Existing bank height and
low-detail distant firs remain; no geometry-quality equivalence to the reference
is claimed. Owner visual approval is not an agent-verifiable check.

[Initial bright palette](initial-bright-palette.png) is superseded: cream and
leaves were toned down after inspection. [Initial flower shadow cost](initial-flower-shadow-cost.json)
is also superseded: 96 additional square-facing draw calls motivated disabling
tiny decorative flower shadows. No test assertion or useful collision was removed.

Final live-app renders: [terminal](terminal-revisited.png),
[editor](editor-revisited.png), [pavilion workspace](workspace-revisited.png),
[Firefox](firefox-relaunched.png). Screen-color verification preserves exact gray
steps and RGB swatches ([log](screen_color.txt)). Terminal/Vim state survives
walking away/returning; the pavilion retains its placed live shell; Firefox
reuses its profile, receives input and closes/relaunches independently of the
host Firefox.

Reproduction (run from repository root):

```sh
export GODOT_BINARY="$PWD/.tools/warm-art/godot-check.sh"
tools/check-godot-atmosphere.sh
tools/check-godot-architecture.sh
tools/check-godot-village-applications.sh
tools/check-godot-pavilion.sh
tools/check-firefox-application.sh
python3 -m unittest discover -s tests -p 'test_*.py'
node --test .opencode/tests/*.test.js
```

The local wrapper uses the same private Weston GL/fake-seat setup recorded in
[the Firefox evidence](../firefox-launch-fix/README.md). Available interactive
output also works. Godot 4.7.2, NVIDIA RTX 3080/615.78.08, Compatibility/OpenGL3.3,
private Weston 15.0.1 1280×800/60Hz; the terminal resize trial uses 1600×1000.
Desktop tests use isolated launcher state. No host session/services were changed.
The six default graphical tests invoke `res://tests/<name>.gd` with
`--path world --audio-driver Dummy --max-fps 60`, for `screen_color`,
`terminal_input`, `terminal_pointer`, `terminal_resize`, `app_launcher`, and
`application_transition`.

The final architecture capture-only run uses the same script with
`-- --capture-only`; the full headless/graphical collision and access trial
already passed before the last flower-only color/shadow refinement.

Logs are stored alongside this index with trailing whitespace trimmed:
[baseline](before.txt), [architecture](architecture.txt),
[final atmosphere](final-atmosphere.txt), [final close views](final-captures.txt),
[default interactions](default-checks.txt), [village apps](village-applications.txt),
[pavilion](pavilion.txt), [Firefox](firefox.txt),
[Python](python.txt), [Node/parser](node.txt). Individual default interaction logs
are also retained. Optional Weston-global/icon-theme and recompiled-shader-cache
warnings are recorded; no failed assertion is ignored.

The new flower GLB has a byte-identical rebuild: [SHA-256](flowers.sha256).
Existing texture hashes validate offline. No new full native suite is claimed
because C++ and bridge code did not change. Chrome and the retained study's
source cache remain unavailable; no fresh passes for those broader fixtures.
No Steam Deck, sustained performance, human comfort or final P22 gate claim.

## Matched host sample

| View | Draw calls before → after | Median ms before → after | p95 ms before → after |
| --- | ---: | ---: | ---: |
| arrival | 426 → 450 | 16.716 → 16.644 | 17.430 → 17.164 |
| north-outlook | 61 → 61 | 16.662 → 16.669 | 16.922 → 17.150 |
| east-outlook | 53 → 53 | 16.663 → 16.684 | 17.035 → 17.187 |
| south-outlook | 38 → 38 | 16.674 → 16.654 | 16.934 → 17.177 |
| west-outlook | 41 → 41 | 16.657 → 16.662 | 17.408 → 16.877 |
| south-return | 449 → 481 | 16.638 → 16.660 | 17.402 → 17.151 |
| pavilion-edge | 41 → 41 | 16.682 → 16.674 | 17.438 → 17.099 |

120 frames per fixed view, after settling. The flower borders add 24–32 draw calls
in square-facing views; other sampled views have unchanged counts. Median frame
times remain about 16.7ms on this vsync-bound 60Hz host. These are bounded samples,
not evidence of sustained GPU capacity or target-device acceptance. Raw reports:
[before](before/render-cost.json) and [after](render-cost.json).
