#!/usr/bin/env python3
"""Prepare ignored village models and pinned textures before Godot import."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from fetch_assets import atomic_download
from verify_village_materials import verify as verify_materials
from verify_village_animals import verify as verify_animals

ROOT = Path(__file__).resolve().parents[2]
BUILDERS = (
    "build_village_models.py", "build_pavilion_furniture.py",
    "build_village_surrounds.py", "build_village_flowers.py",
    "build_village_expansion.py", "build_village_upstairs.py",
    "build_village_animals.py",
)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def matches(path, entry):
    return (path.is_file() and path.stat().st_size == entry["bytes"]
            and digest(path) == entry["sha256"])


def prepare_textures(root, offline=False):
    manifest = json.loads((root / "world/assets/manifest.json").read_text())
    for asset in manifest["assets"]:
        if asset.get("usage") != "P22-T05 village":
            continue
        for channel in ("Diffuse", "nor_gl", "Rough"):
            entry = asset["maps"][channel]
            target, cache = (root / entry[key] for key in ("runtime", "cache"))
            if matches(target, entry):
                continue
            if not matches(cache, entry):
                if offline:
                    raise ValueError(f"Missing/corrupt texture and cache: {target}; "
                                     "run prepare_world_assets.py once online")
                cache.parent.mkdir(parents=True, exist_ok=True)
                # Never publish a download until its pinned SHA-256 is verified.
                with tempfile.TemporaryDirectory(dir=cache.parent) as directory:
                    download = Path(directory) / cache.name
                    print(f"Downloading {entry['url']}", flush=True)
                    if not atomic_download(entry["url"], download):
                        raise ValueError(f"Download failed: {entry['url']}")
                    if not matches(download, entry):
                        raise ValueError(f"Size/SHA-256 mismatch: {entry['url']}")
                    os.replace(download, cache)
            target.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as f:
                temporary = Path(f.name)
            try:
                shutil.copyfile(cache, temporary)
                os.replace(temporary, target)
            finally:
                temporary.unlink(missing_ok=True)
    verify_materials(root)


def prepare_models(root):
    world = root / "world"
    # Import settings name every current model; the retired reference-1 bridge
    # is preserved only in the pre-cleanup archive, not used by this scene.
    outputs = sorted(p.with_suffix("") for p in (world / "art").rglob("*.glb.import")
                     if p.name != "courtyard_link.glb.import")
    sources = sorted((world / "tools").glob("*.py"))
    sources += sorted((world / "art").rglob("*.json"))
    sources += sorted((world / "art").rglob("*.glb.import"))
    inputs = {str(p.relative_to(root)): digest(p) for p in sources}
    stamp = root / ".tools/world-assets.json"
    try:
        previous = json.loads(stamp.read_text())
    except (OSError, ValueError):
        previous = {}
    if not isinstance(previous, dict):
        previous = {}
    hashes = {str(p.relative_to(root)): digest(p) for p in outputs if p.is_file()}
    if (previous.get("inputs") == inputs and previous.get("outputs") == hashes
            and len(hashes) == len(outputs)):
        return
    for builder in BUILDERS:
        subprocess.run([sys.executable, str(world / "tools" / builder)], check=True)
    hashes = {str(p.relative_to(root)): digest(p) for p in outputs}
    verify_animals(world / "art/animals")
    stamp.parent.mkdir(parents=True, exist_ok=True)
    stamp.write_text(json.dumps({"inputs": inputs, "outputs": hashes}, indent=2) + "\n")
    print(f"Prepared {len(outputs)} original models")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--offline", action="store_true", help="never download missing textures")
    args = parser.parse_args()
    prepare_textures(ROOT, args.offline or os.environ.get("ELSEWHERE_ASSETS_OFFLINE") == "1")
    prepare_models(ROOT)
    print("World assets ready (generated models and verified Poly Haven maps)")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(f"Asset preparation failed: {error}")
