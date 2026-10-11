# Owner reference — courtyard alignment

Owner-requested bounded visual revision, 2026-10-11, base `e32c9dc` (completed
P22-T04). The owner supplied
[the reference JPEG](../art-direction/village-square-example.jpg) and asked to
align the existing world with it. This request authorizes this visual revision;
it does not start an autonomous task sequence or close the P22-T05 art gate.
Authority remains [Decision 08](../decisions/08-elsewhere-village-world.md).

## Implemented interpretation

The reference suggests an intimate, inhabited alpine courtyard: pale plaster
and warm timber, tall curved slate roofs/dormers, lattice windows, flower boxes,
a planted fountain, leafy trees and an arched timber link. The revised
[art brief](../ART-DIRECTION.md) makes this the current visual direction.

The existing lodge, guildhall and workshop move closer to the square, to
(-12,-16), (9.5,-17) and (18,-9), respectively. The fountain stays at (-5,-4)
and pavilion at (-18,18). Roofs now have curved profiles, thick staggered slate
courses and dormers. The guildhall's stepped stone gable becomes timber/plaster;
its decorative clock stays. Windows gain lattice detail and planted boxes;
a small canvas awning accents the guildhall entry. A 13.2m timber arch link
joins the northern exteriors above the approach. Buildings remain closed;
this is exterior architecture, not a new functional destination.

A low 6.3m planted surround and lower compass crown give the fountain a garden
setting. Eight fixed trees frame approaches. Original shaders add plaster and
timber grain, stone/slate joints, varied pale paving and a radial fountain
surround. The visual paving field expands over the existing terrain to
28 × 24m centered at (0,-1); ground geometry and routes are unchanged.
Sun energy changes from 1.0 to 0.85. Exposure, sky, tone mapping, controller,
desktop services and application shaders remain unchanged.

Two scene-local helpers apply material finishes and fixed tree placement.
Trunk cylinders block walking; decorative leaves/branches do not. Architecture
uses the existing static mesh collision. No new engine/service abstraction,
external dependency, downloaded asset, native source, or app/input change.
Seven reproducible original GLBs and import settings are included; their
[provenance, triangle counts and hashes](../../world/art/village/README.md)
record the exact assets. The JPEG is reference only, not a runtime texture;
[source notes](../art-direction/README.md) do not invent its artist/license.

## Actual rendered review

Observer: Codex agent, 2026-10-11. Godot 4.7.2 Compatibility/OpenGL,
Mesa 26.2.4, AMD Custom GPU 0405 (Vangogh/Steam Deck), private Weston,
1280 × 800. Views use the player's supported 1.6m eye height.

Compare the same arrival camera:
[before](../evidence/p22-t04/arrival.png) /
[after](../evidence/village-reference/arrival.png).
These are real engine renders. The owner's JPEG is neither a render of the
implementation nor a substitute for this evidence.

Reviewed final views:

- [Arrival](../evidence/village-reference/arrival.png) and
  [east square](../evidence/village-reference/east-square.png): closer buildings,
  warm frames/plaster, planted landmark and connected northern frontage.
- [Lodge](../evidence/village-reference/lodge.png),
  [guildhall](../evidence/village-reference/guildhall.png) and
  [workshop](../evidence/village-reference/workshop.png): curved roofs, dormers,
  lattice, flower boxes, grain and masonry joints. Close-up camera positions
  follow the moved buildings; these are not identical to the old close-ups.
- [North return](../evidence/village-reference/north-return.png) and
  [south approach](../evidence/village-reference/south-approach.png): the landmark
  and open routes remain legible; the broad outer lawn/bank remains visible.
- [Pavilion](../evidence/village-reference/pavilion.png) and
  [covered view](../evidence/village-reference/pavilion-covered.png): slate roof,
  timber grain, supported floor, clear ramp and view back to the square.

Initial renders revealed sparse foliage, thin flowers and an incongruous blue
foundation. Denser leaf clusters/flower planting and stone foundations address
those defects. A second close-up exposed an undetailed blue hip roof; added
slate joints/variation there and inspected the final workshop again. The arch,
window lattice and awning strengthen the reference's architectural vocabulary.
Initial/refined capture-only logs remain explicitly labeled as captures, not
collision tests. Their images are retained locally in
`.tools/reference-revision/first-renders/`; the committed images come from the
final full architecture trial, including its newly captured covered view.

This is a substantial direction change, not a claim of matching the reference's
finished quality. The wide lawn, faceted boundary, simple canopy silhouettes,
bright flowers and regular paving remain visible limitations. No person has
yet approved this revision; no movement-comfort or performance benchmark is
claimed. P22-T05 stays unchecked for the broader material/foliage/light and
owner art-review checkpoint. No subsequent numbered task was accepted or advanced; interiors remain closed.

## Verification

Logs are local under `.tools/reference-revision/`. The existing private Weston
wrapper supplies graphical output and passes headless runs to the pinned engine;
no host desktop/service configuration is changed.

```sh
python3 world/tools/build_village_models.py
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-architecture.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-landscape.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-godot-outdoor.sh
GODOT_BINARY="$PWD/.tools/rename/godot-check.sh" tools/check-chrome-application.sh
python3 tests/test_desktop_apps.py
python3 tests/test_godot_launcher.py
node --test .opencode/tests/auto-continue.test.js
```

- Godot import/default startup and full architecture trial pass in headless
  and GPU modes (`VILLAGE_ARCHITECTURE_OK ... failures=0`). Checks include closed
  exteriors, fountain collision, pavilion ramp/covered floor, Home return and
  initialized empty desktop. The revised contact assertion matches the actual
  enlarged planting surround, not a weakened collision condition. Logs:
  `architecture.log`, `/tmp/elsewhere-architecture-check.82FIqY/`.
- The unchanged landscape trial passes in both modes, including all full route
  round trips and the north approach under the link: 24,178 ground samples,
  337.8m walked, max grade 14.39°, floor gap below 6mm. Logs: `landscape.log`,
  `/tmp/elsewhere-landscape-check.FZNixw/`.
- Eight Python catalog/launcher and 62 Node parser/plugin tests pass. Known
  optional icon-theme/Wayland-decoration warnings remain. Python syntax and
  byte-identical seven-model regeneration pass. Task parsing preserves ten
  unique P22 IDs and the unchecked T05–T09 plus human T10. An initial ad-hoc
  parser invocation used unsupported scope `P22`; the supported `Project 22`
  check passes without changing the plugin.

The unchanged outdoor trial passes headless and graphically
(`OUTDOOR_STARTUP_OK ... boundaries=10 failures=0`): empty startup beyond the
watchdog, manual real-terminal launch, movement/jump/Home, all ten boundaries
and corner, panel drag/rotation/cancel, typing/return, terrain-supported live
panel identity and cleanup. Logs: `outdoor.log`,
`/tmp/elsewhere-outdoor-check.lvItd7/`. Agent-inspected captures:
[empty arrival](../evidence/village-reference/empty-arrival.png),
[readable real terminal output](../evidence/village-reference/application.png),
and [live panel on the western terrain](../evidence/village-reference/slope-panel.png).
The last uses the existing explicit fixture repositioning; it does not claim
new pavilion work surfaces or P22-T07 acceptance.

Full architecture, landscape and outdoor logs are also copied into the local
`architecture-details/`, `landscape-details/` and `outdoor-details/` directories.

All seven existing graphical regressions pass unchanged: `screen_color`,
`terminal_input`, `terminal_pointer`, `terminal_resize`, `app_launcher`,
`application_objects`, `application_transition`. They verify color, ordinary
keyboard/repeat, pointer selection/scroll, real client resize, launcher/Vim/
relaunch, independent live instances/manipulation and mode transitions.
Five use the outdoor default; color owns its fixture and object tests retain
the study. The controller, desktop/application scripts, study and native source
are byte-identical to the base. Each trial runs sequentially as:

```sh
ELSEWHERE_LAUNCHER_STATE_DIR="$PWD/.tools/reference-revision/desktop-check-state" \
  timeout -k 2s 90s .tools/rename/godot-check.sh --path "$PWD/world" \
  --audio-driver Dummy --max-fps 60 --script res://tests/terminal_input.gd
```

Substitute the seven script names above. `regressions.sh` preserves the exact
sequence; `regressions.log` and per-trial logs contain passing markers with
zero failures and no engine errors/leaks. The unchanged real Chrome test also
passes trusted typing/click, scroll both ways, resize/reflow, world return,
second-window identity and close (`CHROME_APPLICATION_OK failures=0`).
Inspected [browser input](../evidence/village-reference/browser-input.png)
and [world return](../evidence/village-reference/browser-in-room.png).
The historical first-character flake was not observed; no fix is claimed.

Documentation links, task references/parser and diff checks pass. The existing
runtime library is built/staged by Godot validation; no native source changed,
so no fresh Meson or full historical 21-trial suite result is claimed.
The owner-requested reference revision is complete. P22-T05 and later gates
remain unchecked. Stop here; no continuation is authorized.
