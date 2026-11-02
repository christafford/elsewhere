# Source-only history cleanup (2026-11-01)

Owner-requested repository maintenance, independent of Project 22. No roadmap
task or human acceptance gate advances. The initial working tree was clean at
`4b20a510775dcbfee7cb2190184cc6f954cfa1f2`; GitHub main was checked at
`3b143424b359f7ca989fa758c2f72c62eb680622` before rewriting local history.

## Storage policy

The old checkout contained approximately 398.9 MiB of tracked files, dominated
by 358.2 MiB of PNG captures, 32.3 MiB of generated models and 5.0 MiB of pinned
downloadable textures. No individual blob exceeded 3.1 MiB; accumulation of
artifacts caused the bulk.

Remove these paths throughout main's history, preserving the other files,
commit messages, authors and ordering:

- `docs/**/*.png`: screenshots, including the three old `docs/capture_*.png`.
- `world/art/**/*.glb`: generated models, including the inactive courtyard link.
- `world/art/village/textures/*.jpg`: the nine pinned Poly Haven maps.
- `tests/mansion-test-client`: an accidentally tracked historical executable.

Keep Python/C++/Godot sources, JSON manifests, import settings, licenses,
provenance, written evidence and the three small owner-provided art-reference
JPEGs (original reference inputs, not generated/downloadable runtime outputs).
Ignore future generated assets and capture images/videos. No Git LFS or new
dependency is introduced. Existing local artifacts remain in place, untracked.

## Build and verification

`tools/build-godot-runtime.sh` now calls
`python3 world/tools/prepare_world_assets.py`. Both the launcher and project
validator use this build entry point; validation prepares assets before checking
their integrity and importing them. Fresh source checkouts should run:

```sh
tools/validate-godot-project.sh
tools/run-godot.sh
```

Existing pinned engine, godot-cpp and native build prerequisites still apply;
this does not complete the separately unfinished toolchain bootstrap.

Preparation builds 48 active GLBs from the existing standard-library generators.
An ignored stamp hashes sources and outputs, skipping unchanged work and repairing
missing/corrupt models. It downloads only the nine village maps from the existing
manifest URLs, verifies size and SHA-256 before publishing cache/runtime files,
and uses the existing finite-retry atomic downloader. It never changes texture
checksums to accept changed upstream bytes. No network is used when runtime files
or cached maps verify. Use `--offline` for direct preparation, or
`ELSEWHERE_ASSETS_OFFLINE=1` for build/launch, to prohibit downloads.

Verified in this session:

- Source-only temporary checkout: all nine real CDN downloads verify; all 48
  generated models match the pre-cleanup files byte-for-byte.
- An offline fresh checkout without cache fails explicitly; prepared offline
  rerun skips generation; corrupt-model regeneration restores the original bytes.
- Six new texture preparation tests cover cache reuse, corrupt/missing files,
  offline failure, verified downloads, bad hashes and failed downloads. All 20
  Python tests pass. Existing socket tests required an unsandboxed rerun.
- Godot extension build, offline asset verification, import and startup checked
  with repository-local settings/cache. Initial sandbox import failed on socket
  creation/settings writes; the permitted rerun is the relevant result.
- Shell syntax and diff checks. No C++ or scene behavior changes; generated model
  bytes are unchanged. No new visual, real-application or human acceptance claim.

## Archive and rewritten revisions

The complete original history is preserved locally in the ignored, verified
bundle `.tools/history-cleanup-20261101/original.bundle`. Original screenshots
also remain at their existing local paths. Historical SHA references and image
links in old handoffs refer to this archive; a fresh source-only clone does not
contain historical captures, and new captures cannot recreate those observations.
The old/new commit map is kept beside the bundle. For historical inspection,
clone the archive into a separate directory:

```sh
git clone .tools/history-cleanup-20261101/original.bundle /tmp/elsewhere-original
```

The cleanup preserves history rather than squashing the project into one commit.
Commits affected by removed files and their descendants receive new IDs. Local
reflogs, remote-tracking refs and the archive intentionally retain old objects,
so the existing `.git` directory need not immediately shrink. A fresh clone of
rewritten main measures the cleaned history. Do not push archive/original refs.

No push is performed. Publishing rewritten main requires an explicit lease
against the observed remote tip:

```sh
git push --force-with-lease=refs/heads/main:3b143424b359f7ca989fa758c2f72c62eb680622 origin main:main
```

If someone updates remote main, this command refuses to overwrite it. Review
that new work before choosing another lease. Other GitHub branches are unchanged;
server-side retention of unreachable historical objects is outside this local
cleanup. Existing clones should be reconciled with rewritten main before pushing.

Next task: stop after this owner-requested cleanup. No P22 continuation authorized.
