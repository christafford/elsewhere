# Review item 2 — shared-memory snapshot reachability

Owner-requested bounded review, 2026-10-12, based on `c197d43`. Only the second
finding is in scope; no Project 22 task is advanced. No implementation change
is needed in the production path.

## Reachability

The named `elsewhere_adapter_create_snapshot()` belonged to
`src/godot/elsewhere_bridge.cpp`, removed in `c112659` during
[review item 1](47-surface-identity-review.md). Its source at `c40748d` confirms
the reported source-stride allocation and packed destination-row mismatch.

A duplicate defect still exists in
[`elsewhere_gdextension_adapter_create_snapshot()`](../../src/godot/elsewhere_gdextension_adapter.cpp).
Meson builds this experimental adapter into `libelsewhere_godot.so`, and the
old manual binding calls it. It is not the desktop's active extension: the old
addon is excluded by [`.gdignore`](../../world/addons/elsewhere_godot/.gdignore).
This audit does not fix or certify that legacy adapter. It must be repaired or
retired before anyone re-enables it.

The current route is:

1. [`terminal_screen.gd`](../../world/scripts/terminal_screen.gd) instantiates
   `ElsewhereCompositorSession` and requests `snapshot(handle, revision)`.
2. [`runtime.gdextension`](../../world/addons/elsewhere_runtime/runtime.gdextension)
   loads `libelsewhere_runtime.so`, staged by
   [`build-godot-runtime.sh`](../../tools/build-godot-runtime.sh).
3. Its [CMake target](../../tests/godot-binding/CMakeLists.txt) compiles
   `compositor_session.cpp`, `compositor-runtime.cpp`, `compositor-core.cpp` and
   `surface-tree.cpp`, excluding both old adapters. Generated build rules agree.
   `nm -C` on the staged library finds `ElsewhereCompositorSession::snapshot`
   and neither legacy snapshot function.

## Existing production contract

[`copy_frame()`](../../src/compositor-core.cpp) already reads rows using the
source stride and writes exactly `width * height * 4` bytes with output stride
`width * 4`. [`FrameSnapshot`](../../src/frame-snapshot.h) specifies RGBA8,
top-left rows and straight alpha; source stride/format remain separate metadata.
ARGB is unpremultiplied, XRGB alpha is forced opaque. The
[Godot binding](../../src/godot/compositor_session.cpp) labels the result `RGBA8`
and checks its owned byte-array allocation.

Before allocating, the core explicitly rejects formats other than ARGB8888 and
XRGB8888, nonpositive dimensions, insufficient stride and frames above 64 MiB.
The stride comparison uses `int64_t`, the pixel-count comparison uses `uint64_t`,
and the cap precedes packed-size multiplication/allocation. Retained compositor
frames have a separate 256 MiB cap; allocation failure is caught at commit.
Libwayland also validates shm pool bounds and buffer metadata before commit.

Existing [native](../../tests/test_frame_snapshot.cpp) and
[Godot](../../tests/godot-binding/frames.gd) tests compare every output byte for
padded ARGB (4x2, source stride 24) and XRGB (2x3, source stride 16), verify packed
stride, channel order/alpha, source metadata and immutable ownership. Their
[client fixture](../../tests/frame-client.c) also tests oversize allocation,
unsupported RGB565, truncated backing storage, invalid scale/transform and
dimensions not divisible by scale. These are specific cases, not exhaustive
integer-boundary or allocation-failure injection coverage. Unsupported RGB565
is rejected by libwayland before the core copy; the core's explicit whitelist
is also confirmed by source inspection.

## Validation and boundary

Fresh agent-run checks:

- `meson test -C build frame-snapshot --print-errorlogs`: 1/1 passed, including
  32 pixel/state barriers and six negative cases.
- `tools/check-godot-binding.sh`: passed, including a current native/binding
  build, fresh import, lifecycle, frame, keyboard, pointer, resize and surface-tree
  checks. Godot frame result: 32 barriers, six negative cases, zero failures.
  Godot `4.7.2 ed1daf0bf`; godot-cpp `507ed9d840c01a3c5b2a39af8bb4000bfac30bf5`.
- Plugin/parser tests, changed-document local links, unchanged roadmap IDs and
  checkboxes, and `git diff --check`: passed.

Initial sandbox attempts failed to bind private Wayland sockets and save Godot
editor settings. The checks above passed after approved execution outside the
sandbox. Local generated logs: `build/meson-logs/testlog.txt`,
`build-godot-probe/*.log`, `/tmp/elsewhere-review-2-binding-approved.log` and
`/tmp/elsewhere-review-2-parser.log`. No full Meson-suite rerun is claimed.

This is a documentation-only
audit using existing regressions, not a new implementation or new test coverage.
No visual, real-application or human acceptance is claimed. Stop after item 2;
await the next owner-requested finding. P22-T07 remains unauthorized.
