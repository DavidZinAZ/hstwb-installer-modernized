"""Archive review keeps findings redacted and exposes coverage gaps."""
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import types
import unittest
from unittest.mock import patch
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from audit_bundled_archives import review


class ArchiveAuditTests(unittest.TestCase):
    def test_nested_payload_redaction_and_unreadable_archive(self):
        output = Path(__file__).resolve().parents[1] / ".output"
        output.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output, ignore_cleanup_errors=True) as directory:
            root = Path(directory)
            self.assertTrue(root.resolve().is_relative_to(output.resolve()))
            subprocess.check_call(["git", "init", "-q", str(root)])
            token = "gh" + "p_" + "a" * 30
            nested = io.BytesIO()
            with zipfile.ZipFile(nested, "w") as archive:
                archive.writestr("fixture.txt", token)
            with zipfile.ZipFile(root / "outer.zip", "w") as archive:
                archive.writestr("nested.zip", nested.getvalue())
                archive.writestr("disk.hdf", b"placeholder disk payload")
            (root / "invalid.zip").write_bytes(b"not an archive")
            subprocess.check_call(["git", "-C", str(root), "add", "."])
            # ZIP behavior is tested offline; the optional LhA reader is not used.
            with patch.dict(sys.modules, {"lhafile": types.ModuleType("lhafile")}):
                result = review(root)
            self.assertEqual(result["finding_counts"], {"access_token": 1})
            self.assertNotIn(token, json.dumps(result))
            self.assertEqual(len(result["uninspected"]), 2)
            self.assertTrue(any("BadZipFile" in p["reason"] for p in result["uninspected"]))
            self.assertTrue(any("disk filesystem" in p["reason"] for p in result["uninspected"]))


if __name__ == "__main__":
    unittest.main()
