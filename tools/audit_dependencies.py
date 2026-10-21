"""Query OSV for exact npm lockfile, NuGet archive and direct-reference versions.

Only dependency names and versions are sent to api.osv.dev. This does not
resolve the .NET transitive graph or audit native Amiga software or binaries.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import urllib.request
import xml.etree.ElementTree as ET
import zipfile


def inventory(root):
    entries = {}
    def add(ecosystem, name, version, source):
        if version and not any(c in version for c in "$*[](),"):
            entries.setdefault((ecosystem, name, version), set()).add(source)
    for path in root.glob("src/**/package-lock.json"):
        lock = json.loads(path.read_text(encoding="utf-8"))
        for location, data in lock.get("packages", {}).items():
            if "node_modules/" in location:
                add("npm", location.rsplit("node_modules/", 1)[1], data.get("version"), path.relative_to(root).as_posix())
    for path in root.glob("src/**/*.csproj"):
        for node in ET.parse(path).iter():
            if node.tag.rsplit("}", 1)[-1] == "PackageReference":
                add("NuGet", node.attrib.get("Include", ""), node.attrib.get("Version"), path.relative_to(root).as_posix())
    for path in root.glob("src/packages/*.nupkg"):
        with zipfile.ZipFile(path) as archive:
            for name in archive.namelist():
                if name.endswith(".nuspec"):
                    metadata = {n.tag.rsplit("}", 1)[-1]: n.text for n in ET.fromstring(archive.read(name)).iter()}
                    add("NuGet", metadata["id"], metadata["version"], path.relative_to(root).as_posix())
    return [{"package": {"ecosystem": e, "name": n}, "version": v, "sources": sorted(s)}
            for (e, n, v), s in sorted(entries.items())]


def query(packages, request=None):
    def online(queries):
        req = urllib.request.Request("https://api.osv.dev/v1/querybatch",
            data=json.dumps({"queries": queries}).encode(),
            headers={"Content-Type": "application/json", "User-Agent": "hstwb-publication-audit"})
        with urllib.request.urlopen(req, timeout=45) as response:
            return json.load(response)
    request = request or online
    rows = []
    for start in range(0, len(packages), 100):
        batch = packages[start:start + 100]
        pending = [(i, {"package": p["package"], "version": p["version"]}) for i, p in enumerate(batch)]
        found = [set() for p in batch]
        while pending:
            results = request([q for _, q in pending])["results"]
            if len(results) != len(pending):
                raise ValueError("Incomplete OSV response")
            next_pages = []
            for (i, q), result in zip(pending, results):
                if result.get("error"):
                    raise ValueError("OSV rejected a dependency query")
                found[i].update(v["id"] for v in result.get("vulns", []))
                if result.get("next_page_token"):
                    next_pages.append((i, dict(q, page_token=result["next_page_token"])))
            pending = next_pages
        rows.extend(dict(p, advisories=sorted(ids)) for p, ids in zip(batch, found))
        print("Queried", min(start + 100, len(packages)), "of", len(packages), flush=True)
    return {"queried_at_utc": datetime.now(timezone.utc).isoformat(),
            "scope": __doc__.strip(), "packages": rows,
            "counts": {"queried_versions": len(rows),
                       "versions_with_advisories": sum(bool(p["advisories"]) for p in rows),
                       "by_ecosystem": dict(Counter(p["package"]["ecosystem"] for p in rows))}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = query(inventory(Path.cwd()))
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report["counts"], indent=2))
    return int(bool(report["counts"]["versions_with_advisories"]))


if __name__ == "__main__":
    raise SystemExit(main())
