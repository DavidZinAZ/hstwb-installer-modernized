"""Inspect ZIP/NuGet and LhA payloads in memory without extracting disk images.

Requires lhafile==0.3.1 for LhA. Reports contain locations and categories,
never matching values. Passing patterns do not clear licenses or disk contents.
"""
import argparse
from collections import Counter
import io
import json
from pathlib import Path
import subprocess
import tarfile
import zipfile

from audit_public_content import inspect

MEMBER_LIMIT = 16 * 1024 * 1024
CONTAINER_LIMIT = 128 * 1024 * 1024
TOTAL_LIMIT = 2 * 1024 * 1024 * 1024
ARCHIVES = (".zip", ".nupkg", ".lha", ".lzh", ".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tar.xz", ".7z")


def review(root):
    import lhafile
    report = {"archive_members_scanned": 0, "bytes_scanned": 0,
              "findings": [], "uninspected": [], "archives": []}
    def visit(data, location, depth=0):
        if depth > 3:
            report["uninspected"].append({"file": location, "reason": "nesting limit"})
            return
        try:
            if location.lower().endswith(".7z"):
                import py7zr
                from py7zr.io import BytesIOFactory
                with py7zr.SevenZipFile(io.BytesIO(data)) as archive7:
                    metadata = archive7.list()
                    if sum(m.uncompressed or 0 for m in metadata) > MEMBER_LIMIT:
                        report["uninspected"].append({"file": location, "reason": "7z expanded-size limit"})
                        return
                    factory = BytesIOFactory(MEMBER_LIMIT)
                    archive7.extractall(factory=factory)
                    report["archives"].append({"file": location, "members": len(metadata)})
                    for member in metadata:
                        if member.is_directory:
                            continue
                        child = location + " :: " + member.filename
                        reader = factory.get(member.filename)
                        reader.seek(0)
                        payload = reader.read()
                        if len(payload) != member.uncompressed:
                            raise ValueError("Incomplete 7z member read")
                        report["archive_members_scanned"] += 1
                        report["bytes_scanned"] += len(payload)
                        inspect(member.filename.encode(), child, report["findings"])
                        inspect(payload, child, report["findings"])
                        if member.filename.lower().endswith(ARCHIVES):
                            visit(payload, child, depth + 1)
                return
            is_tar = location.lower().endswith((".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tar.xz"))
            if is_tar:
                archive = tarfile.open(fileobj=io.BytesIO(data), mode="r:*")
                members = archive.getmembers()
            elif location.lower().endswith((".lha", ".lzh")):
                archive = lhafile.Lhafile(io.BytesIO(data))
                members = archive.infolist()
            else:
                archive = zipfile.ZipFile(io.BytesIO(data))
                members = archive.infolist()
            report["archives"].append({"file": location, "members": len(members)})
            for member in members:
                name = member.name if is_tar else member.filename
                child = location + " :: " + name
                inspect(name.encode("utf-8"), child, report["findings"])
                if name.endswith(("/", "\\")) or (is_tar and member.isdir()):
                    continue
                if is_tar and not member.isfile():
                    report["uninspected"].append({"file": child, "reason": "link or special TAR entry"})
                    continue
                size = member.size if is_tar else member.file_size
                limit = CONTAINER_LIMIT if name.lower().endswith(ARCHIVES) else MEMBER_LIMIT
                if size > limit or report["bytes_scanned"] + size > TOTAL_LIMIT:
                    report["uninspected"].append({"file": child, "bytes": size, "reason": "size limit"})
                    continue
                payload = archive.extractfile(member).read() if is_tar else archive.read(name)
                report["bytes_scanned"] += len(payload)
                report["archive_members_scanned"] += 1
                inspect(payload, child, report["findings"])
                if name.lower().endswith(ARCHIVES):
                    visit(payload, child, depth + 1)
                elif name.lower().endswith((".lzx", ".7z", ".rar", ".gz", ".bz2", ".xz", ".tar", ".adf", ".hdf", ".img", ".iso")):
                    report["uninspected"].append({"file": child, "reason": "nested format or disk filesystem not expanded"})
            if hasattr(archive, "close"):
                archive.close()
        except Exception as error:
            report["uninspected"].append({"file": location, "reason": "reader error: " + type(error).__name__})
    names = subprocess.check_output(["git", "ls-files", "-z"], cwd=root).decode().split("\0")
    for name in names:
        path = root / name
        if name.lower().endswith(ARCHIVES) and path.is_file():
            visit(path.read_bytes(), name)
    report["finding_counts"] = dict(Counter(x["category"] for x in report["findings"]))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = review(Path.cwd())
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"archives_read": len(result["archives"]),
        "members_scanned": result["archive_members_scanned"], "bytes_scanned": result["bytes_scanned"],
        "finding_counts": result["finding_counts"], "uninspected": len(result["uninspected"])}, indent=2))
    return int(bool(result["findings"] or result["uninspected"]))


if __name__ == "__main__":
    raise SystemExit(main())
