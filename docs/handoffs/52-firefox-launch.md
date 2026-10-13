# Firefox launch repair

Owner-reported profile-lock error, 2026-10-13, based on `4235435`. Bounded repair
outside Project 22; P22-T09 and all later tasks remain unstarted.

## Cause and implementation

The desktop-entry helper disabled host remoting but still opened Firefox's
normal profile, which was already locked by the host browser. Native
`firefox`/`firefox-esr` now use `--new-instance --profile` with a persistent
`.tools/browser-profiles/<binary>` directory (0700 when created), and
`MOZ_ENABLE_WAYLAND=1`. `ELSEWHERE_BROWSER_PROFILE_DIR` still overrides the root.
No host profile copying, lock removal, browser termination, system changes or
new dependency. Explicit profile-selecting desktop entries are rejected instead
of ambiguously opening a requested host profile. Wrapped/Flatpak recipes are
outside this native recipe. [Mozilla command-line documentation](https://firefox-source-docs.mozilla.org/browser/CommandLineParameters.html)
and [profile documentation](https://firefox-source-docs.mozilla.org/toolkit/profile/index.html)
explain the separate-instance/profile boundary.

A repeat launcher selection returns to the already associated live Firefox
window, preserving its entity and owned process. Ctrl+N inside Firefox creates
another window. If the original associated window closes while another remains,
the launcher reports that Firefox is open and asks the user to select its panel;
it does not guess an association or launch another profile contender. PID tracking
is transient, using the existing owned-child list. Other applications retain
their existing launch behavior. Multiple concurrent Elsewhere runtimes sharing
this profile are not supported or tested by this repair.

The first isolated launch rendered but could not receive keyboard input. GTK
reported `gdk_seat_get_keyboard` assertions because it defers seat initialization
until both compositor and data-device-manager globals exist (see the
[GTK Wayland registry prerequisites](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gdk/wayland/gdkdisplay-wayland.c)).
`data-device.cpp` now provides a seat-owned v1 manager with real selection/FD
transfer, separate from shell policy and world entities. Only focused clients
may replace/read the selection; expired/future focus serials, undeclared MIME
and stale offers are rejected. Source destruction/disconnect clears selection;
seat shutdown destroys resources before ownership. Drag requests cancel their
unused source explicitly; no drop destinations or successful drag are exposed.
No host clipboard/D-Bus, clipboard persistence after source exit, primary
selection or general drag/drop claim.

## Verification

Agent-run, 2026-10-13, on CachyOS with Godot 4.7.2, NVIDIA RTX 3080/615.78.08,
OpenGL compatibility renderer and private Weston 15.0.1 headless GL/fake-seat
1280×800 output (1600×1000 for the retained resize trial). Firefox 157.0.1,
Weston terminal 15.0.1 and Vim 9.2. The host Firefox PID 1349 remained running
throughout; test children used a separate test profile and were shut down by
their owning runtime. No user browser/profile was closed or unlocked.

- `meson compile -C build` and `meson test -C build --print-errorlogs`: 36/36.
- New `data-device` test: two real Wayland connections, MIME/FD bytes, focused
  ownership, focus transfer, rejection of unfocused setters/future serials,
  stale/unknown-MIME reads, cancellation/clear, source/focus destruction,
  owner disconnect and shutdown. Also passes ASan+UBSan with
  `ASAN_OPTIONS=detect_leaks=0:halt_on_error=1` and
  `UBSAN_OPTIONS=halt_on_error=1`; leak detection is not claimed.
- `tools/check-godot-binding.sh`: native and Godot lifecycle/frame/input/resize/
  tree checks pass, including 300 probe calls, 32 protocol and 16 frame trials.
  Negative-fixture protocol errors are intentional; no ignored failed assertion.
- `tools/check-firefox-application.sh`: real browser launch, trusted typing,
  Ctrl+C/V, pointer click, world return, launcher reuse with same entity/PID,
  Ctrl+N, independent window close, suppression of another profile owner,
  typing into the remaining window, quit confirmation, owned-process release
  and same-profile relaunch with fresh trusted typing.
- Six retained default graphical trials: color, keyboard/repeat, pointer/scroll,
  resize, launcher and transitions. Village Terminal/Vim continuity and
  pavilion placement/stool/shell continuity also pass (22/50 background frame
  revisions respectively). No world art or placement algorithm changed.
- Python desktop helper 10 tests, Godot launcher Python test, Node parser/plugin
  62 tests, import/default startup, shell/Python syntax, documentation links,
  unchanged roadmap checkboxes and diff checks pass.

Reproduce graphical checks with `GODOT_BINARY` pointing to the private-output
wrapper recorded in [evidence](../evidence/firefox-launch-fix/README.md), or on
an available graphical output. `tools/check-firefox-application.sh` stores a
local fixture homepage in **test-only** `profiles/firefox/user.js`, avoiding
Firefox's initial welcome page; production launch never changes browser prefs.
The quit-confirmation pixel locator is specific to the tested default Firefox
157 UI/theme. It clicks the real button through ordinary input.

## Failed trials and limits

The initial profile-only trial exposed absent GTK input; a second launch also
reproduced the lock dialog against the newly occupied isolated profile. These
failures motivated the data-device prerequisite and repeat-launch policy.
Later close checks initially mistook Firefox's quit confirmation for a hung
close, then the fixture hit Cancel's similarly colored outline. Actual renders
identified both; the final locator requires the filled Quit button, and the
same close/relaunch assertions remain required. No browser safety preference
was disabled. Retained failed evidence is labeled separately.

Actual final Firefox input/click/world/relaunch and Terminal/Vim/pavilion renders
were inspected by the agent. This is agent-observed bounded functionality, not
owner acceptance or a broad browser compatibility gate. Chrome is absent; the
full legacy-study visual suite still lacks its cached source assets. Menus,
file dialogs, downloads, accelerated buffers, extensions, non-US input, host
clipboard, Firefox resizing/scrolling and sustained/human comfort were not
newly accepted here. Existing terminal resize/scroll regressions pass.

Restart Elsewhere to load the rebuilt compositor extension, then launch Firefox
from Applications. The user's normal Firefox can stay running. Stop after this
repair; no P22 task is advanced.
