"""Export current source without Git history or ignored local files.

This prepares a review candidate, not redistribution or security clearance.
Run after reviewing changes; new non-ignored files are included deliberately.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from audit_public_content import audit


def export_snapshot(root, destination):
    root = root.resolve()
    destination = destination.resolve()
    # Keep generated output under the ignored output directory. Never overwrite
    # an existing candidate or recursively copy the development checkout.
    output = (root / ".output").resolve()
    if not output.is_relative_to(root) or not destination.is_relative_to(output) or destination == output:
        raise ValueError("Destination must be a new directory inside .output")
    if destination.exists() or destination.with_name(destination.name + "-manifest.json").exists():
        raise ValueError("Destination already exists; choose a new candidate name")
    report = audit(root, include_untracked=True)
    if report["findings"]:
        raise ValueError("Current-content audit has findings; resolve them before export")
    names = subprocess.check_output(
        ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"], cwd=root
    ).decode("utf-8").split("\0")
    deleted = set(subprocess.check_output(
        ["git", "ls-files", "-z", "--deleted"], cwd=root
    ).decode("utf-8").split("\0"))
    files = []
    for name in sorted(set(names) - deleted - {""}):
        source = root / name
        if source.is_symlink() or not source.resolve().is_relative_to(root):
            raise ValueError("Symlinks and paths outside the source tree are unsupported")
        if not source.is_file():
            raise ValueError("Missing source file: " + name)
        files.append((name, source))
    destination.mkdir(parents=True)
    manifest = []
    for name, source in files:
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        manifest.append({"path": name, "bytes": target.stat().st_size,
                         "sha256": hashlib.sha256(target.read_bytes()).hexdigest()})
    evidence = {"status": "review candidate; not publication clearance",
                "source_commit": subprocess.check_output(
                    ["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
                "source": "current working files, including non-ignored new files; no Git history",
                "audit": report, "files": manifest}
    # Evidence stays outside the candidate source tree.
    destination.with_name(destination.name + "-manifest.json").write_text(
        json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    return evidence


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New candidate folder under .output")
    args = parser.parse_args()
    result = export_snapshot(Path.cwd(), args.destination)
    print("Exported", len(result["files"]), "files; candidate still requires publication review.")


if __name__ == "__main__":
    main()
