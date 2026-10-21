"""Publication export must exclude private working data and history."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

TOOLS = Path(__file__).resolve().parents[1] / "tools"
sys.path.insert(0, str(TOOLS))
from export_public_snapshot import export_snapshot


class SnapshotTests(unittest.TestCase):
    def test_export_contains_working_changes_but_no_history_or_ignored_data(self):
        output = TOOLS.parent / ".output"
        output.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output, ignore_cleanup_errors=True) as directory:
            root = Path(directory)
            self.assertTrue(root.resolve().is_relative_to(output.resolve()))
            def git(*args):
                return subprocess.check_output(["git", "-C", str(root), *args])
            git("init", "-q")
            git("config", "user.name", "Synthetic Test")
            git("config", "user.email", "test@example.invalid")
            (root / ".gitignore").write_text(".output/\nsettings/\n")
            (root / "source.txt").write_text("original")
            (root / "removed.txt").write_text("obsolete screenshot stand-in")
            git("add", ".")
            git("commit", "-qm", "Synthetic fixture")
            (root / "source.txt").write_text("reviewed working changes")
            (root / "new.txt").write_text("new public source")
            (root / "removed.txt").unlink()
            (root / "settings").mkdir()
            (root / "settings/private.ini").write_text("private fixture")
            destination = root / ".output/candidate"
            result = export_snapshot(root, destination)
            self.assertEqual((destination / "source.txt").read_text(), "reviewed working changes")
            self.assertTrue((destination / "new.txt").is_file())
            self.assertFalse((destination / "settings").exists())
            self.assertFalse((destination / ".git").exists())
            self.assertFalse((destination / "removed.txt").exists())
            self.assertTrue(all(len(f["sha256"]) == 64 for f in result["files"]))
            with self.assertRaises(ValueError):
                export_snapshot(root, destination)
            with self.assertRaises(ValueError):
                export_snapshot(root, root / "outside-output")
            (root / "new.txt").write_text("gh" + "p_" + "a" * 30)
            with self.assertRaises(ValueError):
                export_snapshot(root, root / ".output/unsafe")
            self.assertFalse((root / ".output/unsafe").exists())


if __name__ == "__main__":
    unittest.main()
