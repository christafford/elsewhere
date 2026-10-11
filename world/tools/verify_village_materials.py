#!/usr/bin/env python3
"""Verify the tracked village texture subset of the shared asset manifest offline."""
import hashlib
import json
from pathlib import Path


def verify(root: Path) -> int:
    manifest = json.loads((root / "world/assets/manifest.json").read_text())
    count = 0
    for asset in manifest["assets"]:
        if asset.get("usage") != "P22-T05 village":
            continue
        for channel in ("Diffuse", "nor_gl", "Rough"):
            entry = asset["maps"][channel]
            path = root / entry["runtime"]
            if not path.is_file():
                raise ValueError(f"Missing {path}; restore the tracked file or fetch {entry['url']} with fetch_assets.atomic_download, then verify again")
            data = path.read_bytes()
            if len(data) != entry["bytes"] or hashlib.sha256(data).hexdigest() != entry["sha256"]:
                raise ValueError(f"Size/SHA-256 mismatch: {path}; refusing unverified material")
            count += 1
    if count != 9:
        raise ValueError(f"Expected nine curated village maps, found {count}")
    return count


if __name__ == "__main__":
    print(f"Verified {verify(Path(__file__).resolve().parents[2])} Poly Haven village maps (offline)")
