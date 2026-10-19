"""Check tracked content without printing matching secrets or personal paths.

This is a pattern-based publication check, not proof that every possible secret
has been detected. Run from the repository root with Python 3.
"""
import argparse
from collections import Counter
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
EXCLUDED_ROOTS = {".output", ".release", "test-media", "settings", ".hermes", ".aws", ".ssh", "private-notes"}
EXCLUDED_FILES = {"ACTIVE-TASK.md", "PROJECT-STATUS.md", "RECOVERY-STATUS.md", "SESSION-HANDOFF.md", ".env", "id_rsa", "id_ed25519"}


def inspect(data, location, findings):
    for category, pattern in CHECKS.items():
        for match in pattern.finditer(data):
            findings.append({"file": location, "line": data[:match.start()].count(b"\n") + 1, "category": category})


def audit(root, include_untracked=False):
    command = ["git", "ls-files", "-z"]
    if include_untracked:
        command += ["--cached", "--others", "--exclude-standard"]
    names = subprocess.check_output(command, cwd=root).decode().split("\0")
    findings = []
    files = archive_members = skipped_large_members = 0
    for name in filter(None, names):
        if name.split("/", 1)[0] in EXCLUDED_ROOTS or name in EXCLUDED_FILES:
            findings.append({"file": name, "category": "private_runtime_directory_tracked"})
        if name.endswith((".hstwb-profile.json", ".bundle")):
            findings.append({"file": name, "category": "private_profile_or_history_backup"})
        path = root / name
        if not path.is_file():
            continue
        data = path.read_bytes()
        files += 1
        inspect(data, name, findings)
        if name.lower().endswith((".zip", ".nupkg")):
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
    return {"tracked_files_scanned": files, "includes_untracked_files": include_untracked, "zip_members_scanned": archive_members,
            "large_zip_members_not_expanded": skipped_large_members, "findings": findings}


def audit_history(root):
    """Scan reachable Git text blobs and commit messages without printing values.

    Archives, images and other binary history still require separate review.
    Object identifiers are recorded so a maintainer can locate findings privately.
    """
    objects = subprocess.check_output(["git", "rev-list", "--objects", "--all"], cwd=root).decode("utf-8", "replace").splitlines()
    process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    findings = []
    counts = {"text_blobs_scanned": 0, "commits_scanned": 0, "binary_blobs_not_expanded": 0, "large_blobs_not_scanned": 0}
    try:
        for item in objects:
            oid, _, name = item.partition(" ")
            process.stdin.write((oid + "\n").encode())
            process.stdin.flush()
            header = process.stdout.readline().decode().strip().split()
            if len(header) != 3:
                raise RuntimeError("Cannot read history object " + oid)
            kind, size = header[1], int(header[2])
            if size > 16 * 1024 * 1024:
                remaining = size
                while remaining:
                    block = process.stdout.read(min(remaining, 1024 * 1024))
                    if not block:
                        raise RuntimeError("Truncated Git object")
                    remaining -= len(block)
                if kind == "blob":
                    counts["large_blobs_not_scanned"] += 1
                process.stdout.read(1)
                continue
            data = process.stdout.read(size)
            process.stdout.read(1)
            if kind == "commit":
                counts["commits_scanned"] += 1
            elif kind == "blob" and b"\0" not in data[:8192]:
                counts["text_blobs_scanned"] += 1
            else:
                if kind == "blob":
                    counts["binary_blobs_not_expanded"] += 1
                continue
            found = []
            inspect(data, name or "[commit metadata/message]", found)
            for finding in found:
                finding["object"] = oid
            findings.extend(found)
    finally:
        process.stdin.close()
        process.stdout.close()
        process.wait()
    return dict(counts, findings=findings)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--history", action="store_true", help="Also scan reachable historical text blobs and commit messages")
    parser.add_argument("--include-untracked", action="store_true", help="Also check new, non-ignored files before staging")
    parser.add_argument("--summary", action="store_true", help="Print counts instead of individual findings; --output still retains the detailed redacted report")
    parser.add_argument("--output", type=Path, help="Write a redacted JSON report to this local file")
    args = parser.parse_args()
    report = audit(args.root.resolve(), args.include_untracked)
    if args.history:
        report["history"] = audit_history(args.root.resolve())
    if args.output:
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    display = report
    if args.summary:
        display = dict(report)
        display["findings"] = dict(Counter(f["category"] for f in report["findings"]))
        if "history" in report:
            display["history"] = dict(report["history"])
            display["history"]["findings"] = dict(Counter(f["category"] for f in report["history"]["findings"]))
    print(json.dumps(display, indent=2))
    return 1 if report["findings"] or report.get("history", {}).get("findings") else 0


if __name__ == "__main__":
    raise SystemExit(main())
