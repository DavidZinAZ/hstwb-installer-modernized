"""Privacy checks use synthetic values and never print matched content."""
import importlib.util
import json
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("content_audit", ROOT / "tools/audit_public_content.py")
audit_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit_module)


class PublicContentAuditTests(unittest.TestCase):
    def test_report_redacts_matching_values(self):
        token = b"gh" + b"p_" + b"a" * 30
        results = []
        audit_module.inspect(token, "example.txt", results)
        self.assertEqual(results[0]["category"], "access_token")
        self.assertNotIn(token.decode(), json.dumps(results))

    def test_history_finds_removed_content(self):
        output = ROOT / ".output"
        output.mkdir(exist_ok=True)
        root = Path(tempfile.mkdtemp(prefix="content-audit-test-", dir=output))

        def git(*args):
            return subprocess.check_output(["git", "-C", str(root), *args], stderr=subprocess.STDOUT)

        git("init", "-q")
        git("config", "user.name", "Synthetic Test")
        git("config", "user.email", "test@example.invalid")
        value = "C:" + "\\Users\\" + "SyntheticPrivate\\example"
        (root / "example.txt").write_text(value, encoding="utf-8")
        git("add", "example.txt")
        git("commit", "-qm", "Synthetic initial fixture")
        (root / "example.txt").write_text("Clean now", encoding="utf-8")
        git("add", "example.txt")
        git("commit", "-qm", "Remove synthetic path")
        self.assertFalse(audit_module.audit(root)["findings"])
        history = audit_module.audit_history(root)
        self.assertTrue(any(f["category"] == "personal_windows_path" for f in history["findings"]))
        self.assertNotIn(value, json.dumps(history))

        (root / "new.txt").write_text(value, encoding="utf-8")
        self.assertTrue(audit_module.audit(root, include_untracked=True)["findings"])
        (root / "settings").mkdir()
        (root / "settings" / "example.ini").write_text("sample", encoding="utf-8")
        git("add", "settings/example.ini")
        self.assertTrue(any(f["category"] == "private_runtime_directory_tracked" for f in audit_module.audit(root)["findings"]))

    def test_zip_member_content_is_checked(self):
        output = ROOT / ".output"
        output.mkdir(exist_ok=True)
        root = Path(tempfile.mkdtemp(prefix="zip-audit-test-", dir=output))
        subprocess.check_output(["git", "init", "-q", str(root)])
        with zipfile.ZipFile(root / "sample.zip", "w") as archive:
            archive.writestr("nested.txt", b"gh" + b"p_" + b"b" * 30)
        subprocess.check_output(["git", "-C", str(root), "add", "sample.zip"])
        result = audit_module.audit(root)
        self.assertEqual(result["zip_members_scanned"], 1)
        self.assertTrue(any("nested.txt" in f["file"] for f in result["findings"]))


if __name__ == "__main__":
    unittest.main()
