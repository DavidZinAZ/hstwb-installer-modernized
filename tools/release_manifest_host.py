#!/usr/bin/env python3
# Host-side release manifest integration (HSTWB-10)
# -------------------------------------------------
#
# Lets host-side discovery/validation consume the first-class AmigaOS 3.2.x
# release manifest (data/release-manifest.json) for release identity and
# validation decisions, instead of scattered filename/version assumptions.
#
# This module is the Python-facing entry point:
#   - hstwb_image_setup.py imports it (via tools/ on sys.path) to validate
#     manifest consistency and detect 3.2.x release states
#   - hstwb_image_setup.ps1 loads the same manifest file at startup and
#     performs the same MD5-indexing checks itself, in pure PowerShell
#     (no Python invocation on the Windows host path)
#   - this script also exposes the same checks on the command line, which
#     doubles as the documented CLI contract for host tooling
#
# Rules implemented (see docs/amigaos-3.2.x-version-manifest-spec.md):
#   - metadata (MD5 hash) is authoritative; filenames are a discovery hint only
#   - AcceptedSources and Includes/Supersedes remain distinct
#   - no install edges are inferred beyond the manifest's AcceptedSources
#   - the 3.2.2.1 -> 3.2.3 edge stays unresolved (not encoded as accepted)
#
# Usage:
#   python3 tools/release_manifest_host.py --list
#   python3 tools/release_manifest_host.py --check-archive FILE.md5
#   python3 tools/release_manifest_host.py --check-source INSTALLED TARGET
#   [manifest.json]  optional explicit manifest path (defaults to data/)
#
# Exit codes:
#   0  success (recognized / allowed)
#   1  manifest missing, invalid, or release metadata unknown
#   2  no matching / not an accepted source (valid input, negative answer)

import argparse
import json
import sys
from pathlib import Path

# default manifest location, resolved relative to the repository root
# (this file lives in tools/, the manifest in data/)
DEFAULT_MANIFEST = Path(__file__).resolve().parent.parent / "data" / "release-manifest.json"

# repository-relative path used when this module is imported by host scripts
DEFAULT_MANIFEST_REPO_REL = Path("data") / "release-manifest.json"

MD5_HEX_LEN = 32


def _is_md5(value):
    """True if value looks like a 32-char hex MD5 string (case-insensitive)."""
    return isinstance(value, str) and len(value) == MD5_HEX_LEN and all(
        c in "0123456789abcdefABCDEF" for c in value
    )


def load_release_manifest(path):
    """Load and structurally validate a release manifest file.

    Returns (manifest_data, errors). manifest_data is None on parse failure.
    """
    import release_manifest

    try:
        with open(str(path), "r", encoding="utf-8") as handle:
            data = json.load(handle)
    except OSError as exc:
        return None, ["cannot read manifest file: {}".format(exc)]
    except json.JSONDecodeError as exc:
        return None, ["manifest is not valid JSON: {}".format(exc)]

    errors = release_manifest.validate_manifest(data)
    if errors:
        return data, errors
    return data, []


def release_index(manifest_data):
    """Build {version: release} from manifest data (None-safe)."""
    releases = (manifest_data or {}).get("Releases")
    if not isinstance(releases, list):
        return {}
    index = {}
    for release in releases:
        if isinstance(release, dict) and isinstance(release.get("Version"), str):
            index[release["Version"]] = release
    return index


def get_release(manifest_data, version):
    """Return the release entry for version, or None if unknown."""
    return release_index(manifest_data).get(version)


def archive_identity_by_md5(manifest_data):
    """Index manifest ArchiveIdentity blocks by lowercase MD5 hash.

    Returns (index, errors). index maps hash -> (version, entry).
    A hash claimed by more than one release is an error.
    """
    index = {}
    errors = []
    for version, release in release_index(manifest_data).items():
        identity = release.get("ArchiveIdentity")
        if not isinstance(identity, dict):
            continue
        md5_hash = identity.get("Md5Hash")
        if not (
            isinstance(md5_hash, str)
            and len(md5_hash) == MD5_HEX_LEN
            and all(c in "0123456789abcdefABCDEF" for c in md5_hash)
        ):
            errors.append(
                "release '{}': ArchiveIdentity.Md5Hash is not a 32-char hex MD5 "
                "string".format(version)
            )
            continue
        key = md5_hash.lower()
        if key in index:
            errors.append(
                "MD5 hash {} is claimed by both release '{}' and release '{}': "
                "an archive MD5 must identify exactly one release".format(
                    md5_hash, index[key][0], version
                )
            )
        else:
            index[key] = (version, release)
    return index, errors


def archive_identity_by_filename(manifest_data):
    """Index manifest ArchiveIdentity blocks by lowercase filename (hint).

    Filenames are a discovery hint only and must never be authoritative.
    Returns (index, errors). index maps filename -> (version, entry).
    A filename claimed by more than one release is an error (ambiguous hint).
    """
    index = {}
    errors = []
    for version, release in release_index(manifest_data).items():
        identity = release.get("ArchiveIdentity")
        if not isinstance(identity, dict):
            continue
        filename = identity.get("Filename")
        if not (isinstance(filename, str) and filename.strip()):
            errors.append(
                "release '{}': ArchiveIdentity.Filename is missing or empty".format(version)
            )
            continue
        key = filename.strip().lower()
        if key in index:
            errors.append(
                "filename '{}' is claimed by both release '{}' and release '{}': "
                "an archive filename hint must not be ambiguous".format(
                    key, index[key][0], version
                )
            )
        else:
            index[key] = (version, release)
    return index, errors


def check_archive_md5(manifest_data, md5_hash):
    """Recognize an archive by its MD5 hash (metadata is authoritative).

    Returns (version, release) or (None, None).
    """
    if not _is_md5(md5_hash):
        return None, None
    return archive_identity_by_md5(manifest_data)[0].get(md5_hash.lower(), (None, None))


def check_archive_filename(manifest_data, filename):
    """Recognize an archive by filename (discovery hint only).

    Returns (version, release) or (None, None).
    """
    if not (isinstance(filename, str) and filename.strip()):
        return None, None
    return archive_identity_by_filename(manifest_data)[0].get(
        filename.strip().lower(), (None, None)
    )


def accepted_sources(manifest_data, target_version):
    """Return the AcceptedSources list for target_version, or None if unknown."""
    release = get_release(manifest_data, target_version)
    if release is None:
        return None
    accepted = release.get("AcceptedSources")
    if not isinstance(accepted, list):
        return None
    return [item for item in accepted if isinstance(item, str)]


def is_accepted_source(manifest_data, installed_version, target_version):
    """True if installed_version is an AcceptedSource of target_version.

    Unknown versions, self-references, and any edge not explicitly declared in
    the manifest are all rejected. The 3.2.2.1 -> 3.2.3 edge is therefore not
    accepted unless the manifest says so (it does not).
    """
    if not (
        isinstance(installed_version, str)
        and isinstance(target_version, str)
        and installed_version
        and target_version
    ):
        return False
    if installed_version == target_version:
        return False
    accepted = accepted_sources(manifest_data, target_version)
    if accepted is None:
        return False
    return installed_version in accepted


def check_manifest_consistency(manifest_data, host_rom_entries):
    """Cross-check manifest release facts against host-side ROM entries.

    host_rom_entries is an iterable of dicts with at least 'KickstartVersion'
    (str, e.g. '47.111') and 'ReleaseVersion' (str, e.g. '3.2.2').

    Returns a list of error strings (empty means consistent):
      - every manifest release with a RomSet.KickstartVersion must have host
        ROM entries for that version
      - every host ROM entry's KickstartVersion must map to its declared
        release's RomSet.KickstartVersion
      - host ROM entries may not declare a release version unknown to the manifest
    """
    errors = []
    index = release_index(manifest_data)

    # manifest -> host direction
    for version, release in index.items():
        rom_set = release.get("RomSet")
        kickstart_version = rom_set.get("KickstartVersion") if isinstance(rom_set, dict) else None
        if not (isinstance(kickstart_version, str) and kickstart_version.strip()):
            continue
        covered = [
            entry
            for entry in host_rom_entries
            if entry.get("KickstartVersion", "").strip() == kickstart_version.strip()
        ]
        if not covered:
            errors.append(
                "release '{}' declares RomSet.KickstartVersion '{}' but the host "
                "validation path has no ROM entries for it".format(version, kickstart_version)
            )

    # host -> manifest direction
    for entry in host_rom_entries:
        kickstart_version = str(entry.get("KickstartVersion", "")).strip()
        release_version = str(entry.get("ReleaseVersion", "")).strip()
        release = index.get(release_version)
        if release is None:
            errors.append(
                "host ROM entry for Kickstart {} declares release version '{}' "
                "which is not declared in the manifest".format(kickstart_version, release_version)
            )
            continue
        rom_set = release.get("RomSet")
        manifest_rom_version = (
            rom_set.get("KickstartVersion", "").strip() if isinstance(rom_set, dict) else ""
        )
        if kickstart_version and manifest_rom_version and kickstart_version != manifest_rom_version:
            errors.append(
                "host ROM entry declares Kickstart {} for release '{}', but the "
                "manifest RomSet.KickstartVersion is '{}'".format(
                    kickstart_version, release_version, manifest_rom_version
                )
            )

    return errors


def detect_release_states(manifest_data, detected_md5s):
    """Map detected archive MD5 hashes to 3.2.x release states.

    Metadata is authoritative: each hash is matched against the manifest's
    ArchiveIdentity blocks. Unknown hashes are ignored here (they are handled
    by the existing adf-based detection paths, which remain in force).

    Returns {version: detected_count} for recognized releases only.
    """
    index, _errors = archive_identity_by_md5(manifest_data)
    detected = {}
    for md5_hash in detected_md5s:
        match = index.get(str(md5_hash).lower())
        if match is None:
            continue
        version, _release = match
        detected[version] = detected.get(version, 0) + 1
    return detected


def main(argv):
    parser = argparse.ArgumentParser(
        description="Host-side checks against the AmigaOS 3.2.x release manifest"
    )
    parser.add_argument("--list", action="store_true", help="list recognized releases and exit")
    parser.add_argument(
        "--check-archive",
        metavar="MD5",
        help="recognize an archive by its 32-char MD5 hash (authoritative)",
    )
    parser.add_argument(
        "--check-source",
        nargs=2,
        metavar=("INSTALLED", "TARGET"),
        help="check whether INSTALLED is an AcceptedSource of TARGET",
    )
    parser.add_argument(
        "manifest",
        nargs="?",
        default=str(DEFAULT_MANIFEST),
        help="manifest path (default: data/release-manifest.json)",
    )
    args = parser.parse_args(argv[1:])
    if not (args.list or args.check_archive or args.check_source):
        parser.print_usage(sys.stderr)
        return 1

    data, errors = load_release_manifest(args.manifest)
    if errors or data is None:
        for error in errors:
            print("release-manifest-host ERROR: {}".format(error), file=sys.stderr)
        return 1

    if args.list:
        for version, _release in release_index(data).items():
            print(version)
        return 0

    if args.check_archive:
        if not _is_md5(args.check_archive):
            print(
                "release-manifest-host ERROR: '{}' is not a 32-char hex MD5 string".format(
                    args.check_archive
                ),
                file=sys.stderr,
            )
            return 1
        version, _release = check_archive_md5(data, args.check_archive)
        if version is None:
            print("release-manifest-host: no release matches MD5 {}".format(args.check_archive))
            return 2
        print(version)
        return 0

    installed_version, target_version = args.check_source
    if is_accepted_source(data, installed_version, target_version):
        print(
            "release-manifest-host: '{}' is an AcceptedSource of '{}'".format(
                installed_version, target_version
            )
        )
        return 0

    if accepted_sources(data, target_version) is None:
        print(
            "release-manifest-host ERROR: unknown target release '{}'".format(target_version),
            file=sys.stderr,
        )
        return 1
    print(
        "release-manifest-host: '{}' is NOT an accepted source of '{}'".format(
            installed_version, target_version
        )
    )
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
