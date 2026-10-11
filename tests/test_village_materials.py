"""Offline asset integrity failures must be explicit; never accept a fallback."""
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "world/tools"))
from verify_village_materials import verify


class VillageMaterialTest(unittest.TestCase):
    def test_tracked_maps(self):
        self.assertEqual(verify(ROOT), 9)

    def test_missing_and_corrupt_maps(self):
        manifest = json.loads((ROOT / "world/assets/manifest.json").read_text())
        entries = [entry for asset in manifest["assets"]
                   if asset.get("usage") == "P22-T05 village"
                   for entry in asset["maps"].values()]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "world/assets").mkdir(parents=True)
            shutil.copyfile(ROOT / "world/assets/manifest.json", root / "world/assets/manifest.json")
            for entry in entries:
                path = root / entry["runtime"]
                path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / entry["runtime"], path)
            target = root / entries[0]["runtime"]
            target.unlink()
            with self.assertRaisesRegex(ValueError, "Missing.*restore the tracked file"):
                verify(root)
            # Same byte count: hash validation must catch corruption independently.
            original = (ROOT / entries[0]["runtime"]).read_bytes()
            target.write_bytes(bytes([original[0] ^ 1]) + original[1:])
            with self.assertRaisesRegex(ValueError, "SHA-256 mismatch"):
                verify(root)

    def test_incomplete_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "world/assets").mkdir(parents=True)
            (root / "world/assets/manifest.json").write_text('{"assets": []}')
            with self.assertRaisesRegex(ValueError, "Expected nine"):
                verify(root)


if __name__ == "__main__":
    unittest.main()
