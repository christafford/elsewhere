"""Bootstrap fixtures verify acquisition/failure behavior, not engine functionality."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tarfile
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("prepare_godot", ROOT / "tools/prepare-godot.py")
PREPARE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PREPARE)


class ToolchainTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="elsewhere toolchain ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "tools").mkdir()
        self.cache = self.root / ".tools/godot-downloads"
        self.cache.mkdir(parents=True)
        binary = b"#!/bin/sh\necho 4.8.fixture\n"
        engine_archive = self.root / "engine.zip"
        with zipfile.ZipFile(engine_archive, "w") as package:
            package.writestr("fixture-godot", binary)
        cpp_dir = self.root / "godot-cpp-fixture"
        cpp_dir.mkdir()
        (cpp_dir / "CMakeLists.txt").write_text("# fixture\n")
        cpp_archive = self.root / "cpp.tar.gz"
        with tarfile.open(cpp_archive, "w:gz") as package:
            package.add(cpp_dir, arcname=cpp_dir.name)
        self.lock = {
            "engine": {"version": "4.8.fixture", "binary": "fixture-godot",
                       "binary_sha256": hashlib.sha256(binary).hexdigest(),
                       "url": engine_archive.as_uri(), "sha256": PREPARE.digest(engine_archive)},
            "godot_cpp": {"revision": "fixture", "api": "4.7",
                          "url": cpp_archive.as_uri(), "sha256": PREPARE.digest(cpp_archive)},
        }
        self.save_lock()

    def save_lock(self):
        (self.root / "tools/godot-toolchain.json").write_text(json.dumps(self.lock))

    def test_acquisition_then_offline_reuse_and_recovery(self):
        PREPARE.prepare(self.root)
        executable = self.root / "tools/fixture-godot"
        self.assertTrue(executable.stat().st_mode & 0o111)
        PREPARE.prepare(self.root, offline=True)
        executable.write_bytes(b"damaged")
        PREPARE.prepare(self.root, offline=True)
        self.assertEqual(PREPARE.digest(executable), self.lock["engine"]["binary_sha256"])
        self.assertTrue((self.root / "tools/godot-cpp/CMakeLists.txt").exists())

    def test_missing_offline_archive_fails(self):
        with self.assertRaisesRegex(RuntimeError, "offline archive"):
            PREPARE.prepare(self.root, offline=True)
        self.assertFalse((self.root / "tools/fixture-godot").exists())

    def test_bad_archive_hash_never_publishes(self):
        self.lock["engine"]["sha256"] = "0" * 64
        self.save_lock()
        with self.assertRaisesRegex(RuntimeError, "Checksum mismatch"):
            PREPARE.prepare(self.root)
        self.assertFalse((self.root / "tools/fixture-godot").exists())

    def test_bad_extracted_hash_preserves_old_binary(self):
        old = self.root / "tools/fixture-godot"
        old.write_bytes(b"existing engine")
        self.lock["engine"]["binary_sha256"] = "0" * 64
        self.save_lock()
        with self.assertRaisesRegex(RuntimeError, "binary checksum"):
            PREPARE.prepare(self.root)
        self.assertEqual(old.read_bytes(), b"existing engine")

    def test_unrecognized_binding_directory_is_preserved(self):
        checkout = self.root / "tools/godot-cpp"
        checkout.mkdir()
        (checkout / "valuable.txt").write_text("keep")
        with self.assertRaisesRegex(RuntimeError, "refusing to overwrite"):
            PREPARE.prepare(self.root)
        self.assertEqual((checkout / "valuable.txt").read_text(), "keep")

    def test_default_wrapper_resolves_pin_and_preserves_arguments(self):
        PREPARE.prepare(self.root)
        wrapper = self.root / "tools/godot"
        shutil.copyfile(ROOT / "tools/godot", wrapper)
        executable = self.root / "tools/fixture-godot"
        executable.write_text("#!/usr/bin/python3\nimport json,sys\nprint(json.dumps(sys.argv[1:]))\n")
        import subprocess
        output = subprocess.check_output(["bash", str(wrapper), "--", "argument with spaces"], text=True)
        self.assertEqual(json.loads(output), ["--", "argument with spaces"])


if __name__ == "__main__":
    unittest.main()
