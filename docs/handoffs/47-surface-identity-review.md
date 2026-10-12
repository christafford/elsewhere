# Review item 1 — surface identifier lifetime

Owner-requested bounded code-review repair, 2026-10-12, based on `c40748d`.
Only the first of five findings is in scope. No Project 22 task is advanced.

## Reachability and resolution

The reported `elsewhere_adapter_enumerate_surfaces()` lived in
`src/godot/elsewhere_bridge.cpp`. It reassigned `client_serial` on every visit,
including orphaned surfaces. There were no calls to this function. Meson's
`gdextension_sources` instead builds `elsewhere_extension.cpp` and
`elsewhere_gdextension_adapter.cpp`; its compile database excludes the bridge.
The generated `libelsewhere_godot.so` has no enumeration symbol. The old addon
is also excluded from Godot discovery by its tracked `.gdignore`.

The current world uses `addons/elsewhere_runtime/runtime.gdextension`, staged
by `tools/build-godot-runtime.sh` from `tests/godot-binding/CMakeLists.txt`.
It registers `ElsewhereCompositorSession`, whose enumeration calls
`CompositorRuntime`. `compositor-core.cpp::initialize_frame_state()` already
allocates a positive 64-bit handle exactly once during surface creation, with
overflow rejection instead of wraparound. Enumeration reads that handle;
snapshot lookup searches only live surfaces. No allocator fix was needed.

Removed the unused bridge implementation/header and its single unused include.
Its obsolete shell build helper now delegates to the supported runtime build;
its optional legacy build-directory argument fails explicitly. The old standalone
CMake entry point now reports retirement with the supported build instructions.
Neither path can accidentally compile the unstable implementation again.
Historical handoffs retain their original descriptions; Git preserves the source.
Meson's separate experimental adapter, native binary and active Godot classes,
paths and ABI remain intact. Broader adapter cleanup is outside this finding.

## Identity contract and regression coverage

- The native lifecycle fixture creates 16 windows in one client. Repeated
  enumeration/pumping preserves all distinct handles and snapshot resolution.
- Destroying eight windows invalidates only those handles. Recreating eight
  windows in the same client gets fresh handles while the survivors retain
  theirs. This allows protocol object-ID reuse without runtime-handle reuse.
- Handles remain distinct across 16 stop/start trials in one process. Stopped
  sessions reject all retired snapshot handles.
- The same enumeration/destruction/recreation checks run through Godot's actual
  `ElsewhereCompositorSession` binding.
- Frame tests explicitly preserve the original handle across replacement
  buffers, scale/transform changes, detach and remap (32 state barriers).

Surface handles are not app-instance IDs, PIDs, protocol serials, or durable
artifact IDs. The current world's `application_object.gd` already generates its
own random `entity_id`; `application_objects.gd` keeps transient handle bindings
separately. Recreated windows are not automatically associated with an old
application entity. This repair adds no persistence or application grouping.

## Validation

Agent-run automated checks in this session:

- `meson compile -C build`: passed.
- `meson test -C build --print-errorlogs`: 34/34 passed, including the extended
  native lifecycle and frame tests and retained nested/headless regressions.
- `tools/check-godot-binding.sh`: passed; fresh import, 300 binding probe calls,
  32 native/Godot lifecycle trials, native/Godot frame trials and keyboard,
  pointer, resize and surface-tree checks. Godot 4.7.2
  `ed1daf0bf`; godot-cpp `507ed9d840c01a3c5b2a39af8bb4000bfac30bf5`.
- `tools/build-elsewhere-extension.sh`: builds/stages the supported runtime.
  Its obsolete argument exits 2; standalone CMake exits 1 with the intended
  retirement message. Shell syntax check passes.
- `npm test --prefix .opencode`: plugin/parser suite passed.
- `tools/validate-godot-project.sh`: default world import/startup passed.
- Changed-document local links, unchanged roadmap IDs/checkboxes, unique P22
  IDs, parser compatibility and `git diff --check`: passed. An initial global
  uniqueness check found the unchanged historical duplicate `P1-T06`; it is
  outside this repair.

Initial sandboxed test attempts could not create local sockets; Godot also could
not save editor settings. They are failed environment attempts, not passed tests.
The full suites subsequently passed with approved execution outside the sandbox.
Logs: `build/meson-logs/testlog.txt`, `build-godot-probe/*.log`, and this session's
`/tmp/elsewhere-review-1-*.log` (local generated artifacts, not tracked evidence).

No new visual or human usability acceptance is claimed: runtime production
behavior and world presentation did not change. The synthetic protocol clients
prove only the stated handle/lifecycle assertions.

Next: stop after review item 1; await the owner's next finding. P22-T07 remains
unstarted and unauthorized. The pre-existing deletion of `xxx.txt` is unrelated
and excluded from this change.
