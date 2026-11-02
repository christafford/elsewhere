"""Asset bootstrap must fail closed and reuse verified offline files."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "world/tools"))
from prepare_world_assets import prepare_textures


class PrepareTexturesTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.data = b"pinned texture fixture"
        self.entries = []
        assets = []
        for i in range(3):
            maps = {}
            for channel in ("Diffuse", "nor_gl", "Rough"):
                name = f"{i}-{channel}.jpg"
                entry = dict(runtime=f"runtime/{name}", cache=f"cache/{name}",
                             bytes=len(self.data), sha256=hashlib.sha256(self.data).hexdigest(),
                             url=f"https://example.invalid/{name}")
                maps[channel] = entry
                self.entries.append(entry)
            assets.append(dict(usage="P22-T05 village", maps=maps))
        manifest = self.root / "world/assets/manifest.json"
        manifest.parent.mkdir(parents=True)
        manifest.write_text(json.dumps(dict(assets=assets)))

    def seed(self, key):
        for entry in self.entries:
            path = self.root / entry[key]
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(self.data)

    def test_runtime_reused_without_network(self):
        self.seed("runtime")
        with patch("prepare_world_assets.atomic_download") as download:
            prepare_textures(self.root)
            download.assert_not_called()

    def test_offline_cache_repairs_missing_and_corrupt_runtime(self):
        self.seed("cache")
        self.seed("runtime")
        (self.root / self.entries[0]["runtime"]).unlink()
        (self.root / self.entries[1]["runtime"]).write_bytes(b"x" * len(self.data))
        with patch("prepare_world_assets.atomic_download") as download:
            prepare_textures(self.root, offline=True)
            download.assert_not_called()
        for entry in self.entries:
            self.assertEqual((self.root / entry["runtime"]).read_bytes(), self.data)

    def test_offline_missing_cache_is_error(self):
        with patch("prepare_world_assets.atomic_download") as download:
            with self.assertRaisesRegex(ValueError, "Missing/corrupt texture and cache"):
                prepare_textures(self.root, offline=True)
            download.assert_not_called()

    def test_verified_download_populates_cache_and_runtime(self):
        def download(url, target):
            target.write_bytes(self.data)
            return True
        with patch("prepare_world_assets.atomic_download", side_effect=download) as fetch:
            prepare_textures(self.root)
            self.assertEqual(fetch.call_count, 9)
        for entry in self.entries:
            for key in ("cache", "runtime"):
                self.assertEqual((self.root / entry[key]).read_bytes(), self.data)

    def test_corrupt_download_never_published(self):
        def download(url, target):
            target.write_bytes(b"x" * len(self.data))
            return True
        with patch("prepare_world_assets.atomic_download", side_effect=download):
            with self.assertRaisesRegex(ValueError, "Size/SHA-256 mismatch"):
                prepare_textures(self.root)
        self.assertFalse((self.root / self.entries[0]["cache"]).exists())
        self.assertFalse((self.root / self.entries[0]["runtime"]).exists())

    def test_failed_download_never_published(self):
        with patch("prepare_world_assets.atomic_download", return_value=False):
            with self.assertRaisesRegex(ValueError, "Download failed"):
                prepare_textures(self.root)
        self.assertFalse((self.root / self.entries[0]["runtime"]).exists())


if __name__ == "__main__":
    unittest.main()
