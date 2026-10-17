"""Check tracked content without printing matching secrets or personal paths.

This is a pattern-based publication check, not proof that every possible secret
has been detected. Run from the repository root with Python 3.
"""
import argparse
import io
import json
import re
import subprocess
import zipfile
from pathlib import Path

CHECKS = {
    "private_archive_path": re.compile(rb"/archive\d+/[^\s\"<>]+", re.I),
    "personal_windows_path": re.compile(
        rb"[A-Z]:[\\/]Users[\\/](?!Public[\\/]|Default[\\/]|testuser[\\/])[^\s\"<>]+", re.I
    ),
    "personal_macos_path": re.compile(rb"/Users[/](?!testuser/)[^\s\"<>]+"),
    "access_token": re.compile(rb"\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[A-Z0-9]{16})\b"),
    "private_key": re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    "credential_url": re.compile(rb"https?://[^\s/:@]+:[^\s/@]+@"),
}
EXCLUDED_ROOTS = {".output", "test-media", "settings", ".hermes", ".aws", ".ssh"}


def inspect(data, location, findings):
    for category, pattern in CHECKS.items():
        for match in pattern.finditer(data):
            findings.append({"file": location, "line": data[:match.start()].count(b"\n") + 1, "category": category})


def audit(root):
    names = subprocess.check_output(["git", "ls-files", "-z"], cwd=root).decode().split("\0")
    findings = []
    files = archive_members = skipped_large_members = 0
    for name in filter(None, names):
        if name.split("/", 1)[0] in EXCLUDED_ROOTS:
            findings.append({"file": name, "category": "private_runtime_directory_tracked"})
        path = root / name
        if not path.is_file():
            continue
        data = path.read_bytes()
        files += 1
        inspect(data, name, findings)
        if name.lower().endswith(".zip"):
            try:
                with zipfile.ZipFile(io.BytesIO(data)) as archive:
                    for entry in archive.infolist():
                        inspect(entry.filename.encode(), name + " [member name]", findings)
                        if entry.is_dir():
                            continue
                        if entry.file_size > 2 * 1024 * 1024:
                            skipped_large_members += 1
                            continue
                        inspect(archive.read(entry), name + " :: " + entry.filename, findings)
                        archive_members += 1
            except zipfile.BadZipFile:
                findings.append({"file": name, "category": "unreadable_zip"})
    return {"tracked_files_scanned": files, "zip_members_scanned": archive_members,
            "large_zip_members_not_expanded": skipped_large_members, "findings": findings}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    report = audit(args.root.resolve())
    print(json.dumps(report, indent=2))
    return 1 if report["findings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
