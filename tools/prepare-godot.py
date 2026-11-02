#!/usr/bin/env python3
"""Acquire the pinned Linux engine/bindings locally, verifying before publishing."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parent.parent


def digest(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def acquire(spec, cache, offline):
    path = cache / spec["sha256"]
    if path.exists() and digest(path) == spec["sha256"]:
        return path
    if offline:
        raise RuntimeError(f"Missing verified offline archive: {path}")
    with tempfile.NamedTemporaryFile(dir=cache, delete=False) as target:
        temporary = Path(target.name)
        try:
            request = urllib.request.Request(spec["url"], headers={"User-Agent": "Elsewhere-toolchain/1"})
            with urllib.request.urlopen(request, timeout=120) as source:
                shutil.copyfileobj(source, target)
            target.flush()
            if digest(temporary) != spec["sha256"]:
                raise RuntimeError(f"Checksum mismatch for {spec['url']}")
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)
    return path


def prepare(root, offline=False):
    tools = root / "tools"
    lock = json.loads((tools / "godot-toolchain.json").read_text())
    cache = root / ".tools" / "godot-downloads"
    cache.mkdir(parents=True, exist_ok=True)
    engine = lock["engine"]
    binary = tools / engine["binary"]
    if not binary.exists() or digest(binary) != engine["binary_sha256"]:
        archive = acquire(engine, cache, offline)
        with tempfile.TemporaryDirectory(dir=tools, prefix=".godot-stage-") as staging:
            candidate = Path(staging) / engine["binary"]
            with zipfile.ZipFile(archive) as package:
                with package.open(engine["binary"]) as source, candidate.open("wb") as target:
                    shutil.copyfileobj(source, target)
            if digest(candidate) != engine["binary_sha256"]:
                raise RuntimeError("Engine binary checksum mismatch")
            candidate.chmod(0o755)
            os.replace(candidate, binary)
    version = subprocess.check_output([str(binary), "--version"], text=True).strip()
    if version != engine["version"]:
        raise RuntimeError(f"Unexpected engine identity: {version}")

    cpp = lock["godot_cpp"]
    checkout = tools / "godot-cpp"
    if checkout.exists():
        if (checkout / ".git").exists():
            revision = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
            dirty = subprocess.check_output(["git", "-C", str(checkout), "status", "--porcelain", "--untracked-files=no"], text=True)
            if revision != cpp["revision"] or dirty:
                raise RuntimeError("Existing godot-cpp differs from the pin; preserve/reconcile that checkout before upgrading")
        elif not (checkout / ".elsewhere-revision").exists() or (checkout / ".elsewhere-revision").read_text().strip() != cpp["revision"]:
            raise RuntimeError("Unrecognized godot-cpp directory; refusing to overwrite it")
    else:
        archive = acquire(cpp, cache, offline)
        with tempfile.TemporaryDirectory(dir=tools, prefix=".godot-cpp-stage-") as staging:
            with tarfile.open(archive) as package:
                package.extractall(staging, filter="data")
            source = Path(staging) / ("godot-cpp-" + cpp["revision"])
            (source / ".elsewhere-revision").write_text(cpp["revision"] + "\n")
            os.replace(source, checkout)
    print(f"Godot {version}; godot-cpp {cpp['revision']} (API {cpp['api']}) ready")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--offline", action="store_true")
    args = parser.parse_args()
    try:
        prepare(ROOT, args.offline)
    except (OSError, RuntimeError, subprocess.CalledProcessError, tarfile.TarError, zipfile.BadZipFile) as error:
        parser.exit(1, f"Godot preparation failed: {error}\n")
