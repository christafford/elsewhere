# Historical standalone bridge entry point; not used by the active runtime.
cmake_minimum_required(VERSION 3.22)
project(elsewhere-godot-extension LANGUAGES NONE)
message(FATAL_ERROR
    "The experimental C bridge has been retired. "
    "Run tools/build-godot-runtime.sh to build and stage ElsewhereCompositorSession, "
    "or configure tests/godot-binding for its native binding tests.")
