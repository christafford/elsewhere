# Review item 3 — keyboard focus follows selection

Owner-requested repair, 2026-10-12, based on `a3ae3df`. Only finding 3 is in
scope; no Project 22 task is advanced.

## Complete focus path and reachability

The reported call in [`compositor.cpp`](../../src/compositor.cpp) is live in
Meson's retained `elsewhere` native/nested/headless executable. It assigned focus
on every commit with a current buffer, including background redraws, metadata
commits and roleless surfaces. This was also supplying the native frontend's
initial target before application entry. Removing it alone would leave that
frontend without initial selection.

The village uses a different path, already correct for this finding:

- [`terminal_screen.gd`](../../world/scripts/terminal_screen.gd) starts an
  `ElsewhereCompositorSession`. Startup/window enumeration and `select_window`
  select presentation content without acquiring keyboard focus.
- [`application_mode.gd`](../../world/scripts/application_mode.gd) calls
  `focus_keyboard(handle)` on application entry (Enter, panel double-click or
  the launcher's explicit activation). World return and host-focus loss call
  `focus_keyboard(0)`; regaining host focus alone does not reactivate an app.
- [`CompositorRuntime`](../../src/compositor-runtime.cpp) accepts only live,
  mapped toplevel handles. Its pump clears invalidated focus; it never selects
  a new target on commit. The active core is `compositor-core.cpp`, not
  `compositor.cpp`, as confirmed by the runtime's CMake source list.
- Shared [`seat.cpp`](../../src/seat.cpp) sends enter/leave, held-key releases,
  modifiers and keys only to the focused client's resources. Repeated focus
  requests are idempotent; late keyboard binding gets the existing focus;
  resource destruction clears it. Neither event chooses another window.
- Legacy Tab/Shift-Tab calls `xdg_shell_cycle_focus` explicitly. The native
  script path restores its selected window on host-focus regain only when the
  saved mode was Application. This historical native restoration policy remains
  distinct from Godot's explicit reactivation policy.

## Change

Removed commit-driven focus. Native `mode app` and targeted Enter now preserve
the selected live toplevel, or choose the first mapped toplevel in the existing
surface order. Empty entry does nothing; later mapping does not auto-activate.
Legacy dimensions survive buffer release by the renderer, so selection does
not require a still-owned buffer. No persistent/window identity change.

The legacy script path previously broadcast keys/modifiers to all clients even
after selecting a focus target. It now uses the existing focused-seat API for
keys and exit cleanup. Returning to world clears seat focus while retaining the
native panel selection for later entry. Explicit world return cancels saved
application-mode restoration. Redraws cannot restore lost focus.

The destruction regression found that legacy `wl_surface.destroy` was a no-op.
It now destroys the resource, allowing focus listeners to run immediately.
The callback returns to world regardless of whether the seat listener already
cleared focus. Orphans retain renderer pixels but drop live buffer listeners and
pointers, preserving the existing screenshot path without dangling callbacks.

## Regression coverage and verification

New [`test_commit_focus.cpp`](../../tests/test_commit_focus.cpp) runs the actual
legacy compositor/input/seat code with two real Wayland fixture clients:

- initial mapping requires explicit application selection;
- mapping another client and repeated buffer, metadata-only and roleless
  commits preserve both selected focus and the keyboard event stream;
- Shift+A, key releases and modifiers reach only the selected client;
- background redraws cannot reacquire focus after host loss or world return;
- native host restoration and application reentry preserve selection;
- destroying the selected window returns to world; the remaining client must
  be selected before it receives keys.

The existing [runtime keyboard test](../../tests/test_runtime_keyboard.cpp)
also uses the extended [fixture](../../tests/keyboard-client.c) to assert that
redraws from both clients preserve the active runtime's handle and event stream.

Initial native-suite failures exposed a fixture problem:
[`elsewhere-test-client.c`](../../tests/elsewhere-test-client.c) destroyed its
toplevel role immediately after drawing, before its input/presentation trial.
It now retains the role until trial completion. Existing key/fullscreen
assertions remain intact. `app_exit.sh` now explicitly rejects an unsolicited
keyboard enter on the second client's mapping, replacing its historical
expectation of the behavior this review removes.

Agent-run automated results in this session:

- `meson compile -C build`: passed. The existing unused `send_pointer_axis`
  warning remains; no new dependency or warning suppression.
- `meson test -C build --print-errorlogs`: **35/35 passed**, including the new
  commit-focus test and existing native input, fullscreen, lifecycle and
  nested-host/headless regressions.
- `tools/check-godot-binding.sh`: passed, including the extended runtime keyboard
  regression, native/Godot lifecycle and frame checks, pointer, resize and
  surface-tree checks. Godot `4.7.2 ed1daf0bf`; godot-cpp
  `507ed9d840c01a3c5b2a39af8bb4000bfac30bf5`.
- Plugin/parser tests, changed-document links, unchanged numbered roadmap,
  shell syntax and `git diff --check`: passed.

Tests used approved execution outside the sandbox for private sockets and Godot
settings. Local generated logs are `/tmp/elsewhere-review-3-*.log`,
`build/meson-logs/testlog.txt` and `build-godot-probe/*.log`. Initial failures are
retained in the temporary logs; they are not claimed as passing runs.

No Godot production code or world art changed. Synthetic protocol evidence
proves these focus assertions, not real-application usability, visuals or human
acceptance. No fresh graphical application acceptance is claimed.

Next: stop after finding 3; await the next owner request. P22-T07 remains
unstarted and unauthorized.
