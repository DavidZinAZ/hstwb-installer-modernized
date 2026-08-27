#!/usr/bin/env python3
# Release manifest loader/validator
# ---------------------------------
#
# Loads and structurally validates the first-class AmigaOS 3.2.x release
# manifest (data/release-manifest.json) defined by
# docs/amigaos-3.2.x-version-manifest-spec.md (HSTWB-02 / HSTWB-08 slice).
#
# Scope: parse + structural validation only. This module is not wired into
# installation behavior yet (deferred to a later slice).
#
# Usage:
#   python3 tools/release_manifest.py [manifest.json]
#
# Exit codes:
#   0  manifest parsed and structurally valid
#   1  parse or structural validation failure (one line per error on stderr)

import json
import re
import sys
from pathlib import Path
from typing import Any, TypeGuard

# schema constants
RELEASE_TYPES = ("base", "update", "hotfix")
VALIDATION_PROFILES = ("adf", "rom", "installed-files", "modules", "mutools")
REQUIRED_RELEASE_FIELDS = (
    "Version",
    "ReleaseType",
    "AcceptedSources",
    "Includes",
    "Supersedes",
    "RomSet",
    "ValidationProfile",
    "InstallEntryPoint",
)
MD5_RE = re.compile(r"^[0-9a-f]{32}$")

# default manifest location, resolved relative to the repository root
# (this file lives in tools/, the manifest in data/)
DEFAULT_MANIFEST = Path(__file__).resolve().parent.parent / "data" / "release-manifest.json"


def _is_str_list(value: Any) -> TypeGuard[list[str]]:
    return isinstance(value, list) and all(isinstance(item, str) for item in value)


def validate_manifest(data):
    """Validate parsed manifest data. Returns a list of error strings.

    An empty list means the manifest is structurally valid.
    """
    errors = []

    if not isinstance(data, dict):
        return ["manifest root must be a JSON object"]

    if "Releases" not in data:
        errors.append("missing required top-level field 'Releases'")
        return errors

    releases = data["Releases"]
    if not isinstance(releases, list) or not releases:
        errors.append("'Releases' must be a non-empty list")
        return errors

    versions = set()

    for index, release in enumerate(releases):
        where = "Releases[{}]".format(index)
        if not isinstance(release, dict):
            errors.append("{}: release entry must be a JSON object".format(where))
            continue

        version = release.get("Version")
        if isinstance(version, str) and version:
            where = "release '{}'".format(version)

        # required fields
        for field in REQUIRED_RELEASE_FIELDS:
            if field not in release:
                errors.append("{}: missing required field '{}'".format(where, field))

        # Version
        if not (isinstance(version, str) and version.strip()):
            errors.append("{}: 'Version' must be a non-empty string".format(where))
        elif version in versions:
            errors.append("{}: duplicate release Version '{}'".format(where, version))
        else:
            versions.add(version)

        # ReleaseType
        release_type = release.get("ReleaseType")
        if release_type is not None and release_type not in RELEASE_TYPES:
            errors.append(
                "{}: 'ReleaseType' must be one of {}".format(where, "/".join(RELEASE_TYPES))
            )

        # list fields
        for field in ("AcceptedSources", "Includes", "Supersedes"):
            value = release.get(field)
            if value is not None and not _is_str_list(value):
                errors.append("{}: '{}' must be a list of strings".format(where, field))

        # AcceptedSources semantics
        accepted = release.get("AcceptedSources")
        if _is_str_list(accepted):
            if release_type == "base" and accepted:
                errors.append(
                    "{}: a 'base' release must not declare AcceptedSources".format(where)
                )
            if release_type in ("update", "hotfix") and not accepted:
                errors.append(
                    "{}: a '{}' release must declare at least one AcceptedSource".format(
                        where, release_type
                    )
                )
            if isinstance(version, str) and version in accepted:
                errors.append(
                    "{}: AcceptedSources must not contain its own Version".format(where)
                )

        # RomSet
        rom_set = release.get("RomSet")
        if rom_set is not None:
            if not isinstance(rom_set, dict) or not isinstance(
                rom_set.get("KickstartVersion"), str
            ) or not rom_set.get("KickstartVersion", "").strip():
                errors.append(
                    "{}: 'RomSet' must be an object with a non-empty string "
                    "'KickstartVersion'".format(where)
                )

        # ValidationProfile
        profile = release.get("ValidationProfile")
        if profile is not None:
            if not _is_str_list(profile):
                errors.append(
                    "{}: 'ValidationProfile' must be a list of strings".format(where)
                )
            else:
                unknown = [item for item in profile if item not in VALIDATION_PROFILES]
                if unknown:
                    errors.append(
                        "{}: 'ValidationProfile' contains unknown entries: {}".format(
                            where, ", ".join(sorted(unknown))
                        )
                    )

        # InstallEntryPoint
        entry_point = release.get("InstallEntryPoint")
        if entry_point is not None and not (
            isinstance(entry_point, str) and entry_point.strip()
        ):
            errors.append("{}: 'InstallEntryPoint' must be a non-empty string".format(where))

        # optional ArchiveIdentity
        identity = release.get("ArchiveIdentity")
        if identity is not None:
            if not isinstance(identity, dict):
                errors.append("{}: 'ArchiveIdentity' must be an object".format(where))
            else:
                if not (
                    isinstance(identity.get("Filename"), str)
                    and identity["Filename"].strip()
                ):
                    errors.append(
                        "{}: 'ArchiveIdentity' requires a non-empty string 'Filename'".format(
                            where
                        )
                    )
                md5_hash = identity.get("Md5Hash")
                if md5_hash is not None and not (
                    isinstance(md5_hash, str) and MD5_RE.match(md5_hash)
                ):
                    errors.append(
                        "{}: 'ArchiveIdentity.Md5Hash' must be a 32-char lowercase "
                        "hex MD5 string".format(where)
                    )

        # optional Semantics
        if "Semantics" in release and not isinstance(release["Semantics"], dict):
            errors.append("{}: 'Semantics' must be an object".format(where))

    # referential integrity: accepted sources must reference declared releases
    if not errors:
        for release in releases:
            if not isinstance(release, dict):
                continue
            version = release.get("Version")
            for source in release.get("AcceptedSources", []):
                if source not in versions:
                    errors.append(
                        "release '{}': AcceptedSources entry '{}' does not match any "
                        "declared release Version".format(version, source)
                    )

    return errors


def load_release_manifest(path):
    """Load and validate a release manifest file.

    Returns (manifest_data, errors). manifest_data is None on parse failure.
    """
    try:
        with open(str(path), "r", encoding="utf-8") as handle:
            data = json.load(handle)
    except OSError as exc:
        return None, ["cannot read manifest file: {}".format(exc)]
    except json.JSONDecodeError as exc:
        return None, ["manifest is not valid JSON: {}".format(exc)]

    errors = validate_manifest(data)
    if errors:
        return data, errors
    return data, []


def main(argv):
    if len(argv) > 2:
        print("usage: release_manifest.py [manifest.json]", file=sys.stderr)
        return 1

    manifest_path = Path(argv[1]) if len(argv) == 2 else DEFAULT_MANIFEST
    data, errors = load_release_manifest(manifest_path)

    if errors or data is None:
        for error in errors:
            print("release-manifest ERROR: {}".format(error), file=sys.stderr)
        return 1

    releases = data["Releases"]
    print(
        "release-manifest OK: {} releases ({})".format(
            len(releases), ", ".join(r["Version"] for r in releases)
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
