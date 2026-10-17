# Tests for the AmigaOS 3.2.x release-manifest foundation (HSTWB-08).
#
# Proves, with the real manifest plus synthetic fixtures:
#   1. all five Phase-1 releases load
#   2. AcceptedSources and Includes/Supersedes remain distinct
#   3. 3.2.2 -> 3.2.2.1 is represented
#   4. 3.2.2.1 -> 3.2.3 is NOT represented as accepted
#   5. malformed/duplicate release records fail clearly
#   6. existing 3.2 / 3.2.1 CSV data behavior is unchanged by this slice
#
# Run:  python3 -m pytest tests/ -v
#
# All fixture data is synthetic and non-copyrighted.

import csv
import json
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = REPO_ROOT / "data" / "release-manifest.json"
KICKSTART_CSV = REPO_ROOT / "data" / "kickstart-entries.csv"
FIXTURES = Path(__file__).resolve().parent / "fixtures"

sys.path.insert(0, str(REPO_ROOT / "tools"))

from release_manifest import (  # noqa: E402
    load_release_manifest,
    validate_manifest,
)


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

@pytest.fixture(scope="module")
def manifest():
    data, errors = load_release_manifest(MANIFEST_PATH)
    assert errors == [], "real manifest must be structurally valid: {}".format(errors)
    assert data is not None
    return data


@pytest.fixture(scope="module")
def releases_by_version(manifest):
    return {release["Version"]: release for release in manifest["Releases"]}


# ---------------------------------------------------------------------------
# 1. all five Phase-1 releases load
# ---------------------------------------------------------------------------

def test_all_five_phase1_releases_load(manifest):
    versions = [release["Version"] for release in manifest["Releases"]]
    assert versions == ["3.2", "3.2.1", "3.2.2", "3.2.2.1", "3.2.3"]


def test_release_types(manifest, releases_by_version):
    assert releases_by_version["3.2"]["ReleaseType"] == "base"
    for version in ("3.2.1", "3.2.2", "3.2.2.1", "3.2.3"):
        assert releases_by_version[version]["ReleaseType"] == "update"


def test_required_fields_present_on_every_release(manifest):
    required = (
        "Version",
        "ReleaseType",
        "AcceptedSources",
        "Includes",
        "Supersedes",
        "RomSet",
        "ValidationProfile",
        "InstallEntryPoint",
    )
    for release in manifest["Releases"]:
        for field in required:
            assert field in release, "release {} missing {}".format(
                release.get("Version"), field
            )


# ---------------------------------------------------------------------------
# 2. AcceptedSources and Includes/Supersedes remain distinct
# ---------------------------------------------------------------------------

def test_accepted_sources_and_includes_supersedes_are_distinct(releases_by_version):
    """Each field carries its own meaning and the data keeps them apart.

    3.2.2.1 is accepted from 3.2.2, but it neither includes nor supersedes
    3.2.2 (it is not cumulative). Conversely 3.2.2 includes/supersedes 3.2.1
    and is accepted from 3.2.1. If the fields had collapsed into one another
    these assertions would fail.
    """
    rel_322 = releases_by_version["3.2.2"]
    rel_3221 = releases_by_version["3.2.2.1"]

    # 3.2.2: accepted from 3.2 and 3.2.1, and cumulative over 3.2.1
    assert rel_322["AcceptedSources"] == ["3.2", "3.2.1"]
    assert rel_322["Includes"] == ["3.2.1"]
    assert rel_322["Supersedes"] == ["3.2.1"]

    # 3.2.2.1: accepted from 3.2.2 only; not cumulative
    assert rel_3221["AcceptedSources"] == ["3.2.2"]
    assert rel_3221["Includes"] == []
    assert rel_3221["Supersedes"] == []

    # 3.2.3: accepted from all three earlier states, cumulative over 3.2.1 and 3.2.2
    rel_323 = releases_by_version["3.2.3"]
    assert rel_323["AcceptedSources"] == ["3.2", "3.2.1", "3.2.2"]
    assert rel_323["Includes"] == ["3.2.1", "3.2.2"]
    assert rel_323["Supersedes"] == ["3.2.1", "3.2.2"]

    # the base release has no accepted sources and is not cumulative
    rel_32 = releases_by_version["3.2"]
    assert rel_32["AcceptedSources"] == []
    assert rel_32["Includes"] == []
    assert rel_32["Supersedes"] == []


# ---------------------------------------------------------------------------
# 3. 3.2.2 -> 3.2.2.1 is represented
# ---------------------------------------------------------------------------

def test_322_to_3221_edge_represented(releases_by_version):
    rel_3221 = releases_by_version["3.2.2.1"]
    assert "3.2.2" in rel_3221["AcceptedSources"]
    semantics = rel_3221.get("Semantics", {})
    assert semantics.get("RequiredInstalledVersion") == "3.2.2"


# ---------------------------------------------------------------------------
# 4. 3.2.2.1 -> 3.2.3 is NOT represented as accepted
# ---------------------------------------------------------------------------

def test_3221_to_323_edge_not_represented(releases_by_version):
    rel_323 = releases_by_version["3.2.3"]
    assert "3.2.2.1" not in rel_323["AcceptedSources"]
    assert "3.2.2.1" not in rel_323["Includes"]
    assert "3.2.2.1" not in rel_323["Supersedes"]


# ---------------------------------------------------------------------------
# 5. malformed / duplicate release records fail clearly
# ---------------------------------------------------------------------------

def test_duplicate_version_fixture_fails_clearly():
    path = FIXTURES / "release-manifest-duplicate-version.json"
    data, errors = load_release_manifest(path)
    assert data is not None  # JSON parsed fine
    assert any("duplicate release Version '1.1'" in e for e in errors), errors


def test_dangling_accepted_source_fixture_fails_clearly():
    path = FIXTURES / "release-manifest-dangling-source.json"
    data, errors = load_release_manifest(path)
    assert any(
        "AcceptedSources entry '9.9' does not match any declared release Version" in e
        for e in errors
    ), errors


def test_malformed_json_fails_clearly(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{ this is not json", encoding="utf-8")
    data, errors = load_release_manifest(bad)
    assert data is None
    assert any("not valid JSON" in e for e in errors), errors


def test_malformed_json_cli_exits_one(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{ this is not json", encoding="utf-8")
    completed = subprocess.run(
        [sys.executable, str(REPO_ROOT / "tools" / "release_manifest.py"), str(bad)],
        capture_output=True,
        text=True,
    )
    assert completed.returncode == 1
    assert "not valid JSON" in completed.stderr


def test_missing_file_fails_clearly(tmp_path):
    data, errors = load_release_manifest(tmp_path / "nope.json")
    assert data is None
    assert any("cannot read manifest file" in e for e in errors), errors


def test_base_release_with_accepted_sources_fails():
    bad = {
        "Releases": [
            {
                "Version": "1.0",
                "ReleaseType": "base",
                "AcceptedSources": ["0.9"],
                "Includes": [],
                "Supersedes": [],
                "RomSet": {"KickstartVersion": "100.100"},
                "ValidationProfile": ["adf"],
                "InstallEntryPoint": "Install-Test",
            }
        ]
    }
    errors = validate_manifest(bad)
    assert any("a 'base' release must not declare AcceptedSources" in e for e in errors), errors


def test_update_release_without_accepted_sources_fails():
    bad = {
        "Releases": [
            {
                "Version": "1.0",
                "ReleaseType": "base",
                "AcceptedSources": [],
                "Includes": [],
                "Supersedes": [],
                "RomSet": {"KickstartVersion": "100.100"},
                "ValidationProfile": ["adf"],
                "InstallEntryPoint": "Install-Test",
            },
            {
                "Version": "1.1",
                "ReleaseType": "update",
                "AcceptedSources": [],
                "Includes": [],
                "Supersedes": [],
                "RomSet": {"KickstartVersion": "100.101"},
                "ValidationProfile": ["adf"],
                "InstallEntryPoint": "Install-Test",
            },
        ]
    }
    errors = validate_manifest(bad)
    assert any(
        "release must declare at least one AcceptedSource" in e for e in errors
    ), errors


def test_bad_md5_shape_fails():
    bad = {
        "Releases": [
            {
                "Version": "1.0",
                "ReleaseType": "base",
                "AcceptedSources": [],
                "Includes": [],
                "Supersedes": [],
                "RomSet": {"KickstartVersion": "100.100"},
                "ValidationProfile": ["adf"],
                "InstallEntryPoint": "Install-Test",
                "ArchiveIdentity": {"Filename": "x.lha", "Md5Hash": "NOTANMD5"},
            }
        ]
    }
    errors = validate_manifest(bad)
    assert any("ArchiveIdentity.Md5Hash" in e for e in errors), errors


# ---------------------------------------------------------------------------
# 6. existing 3.2 / 3.2.1 CSV data behavior is unchanged by this slice
# ---------------------------------------------------------------------------

def _read_rows(path: Path):
    text = path.read_text(encoding="utf-8")
    return [row for row in csv.reader(text.splitlines(), delimiter=";") if row]


def _git_head_version(rel_path: str) -> str:
    result = subprocess.run(
        ["git", "show", "HEAD:{}".format(rel_path)],
        cwd=str(REPO_ROOT),
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def test_existing_32_321_rows_unchanged():
    """Every pre-existing row in data/kickstart-entries.csv must be byte-identical
    to the row at git HEAD. Only appended 47.111/47.115 rows may differ."""
    current_text = KICKSTART_CSV.read_text(encoding="utf-8")
    head_text = _git_head_version("data/kickstart-entries.csv")

    head_rows = [row for row in csv.reader(head_text.splitlines(), delimiter=";") if row]
    current_rows = _read_rows(KICKSTART_CSV)

    # current file must start with the exact HEAD sequence of rows
    assert current_rows[: len(head_rows)] == head_rows, (
        "pre-existing kickstart rows were modified; expected the first {} rows "
        "to be byte-identical to git HEAD".format(len(head_rows))
    )

    # every appended row must be a 3.2.2/3.2.3 Kickstart ROM row
    appended = current_rows[len(head_rows):]
    for row in appended:
        assert "47.111" in row[0] or "47.115" in row[0], (
            "unexpected appended row: {}".format(row)
        )


def test_appended_32x_rom_rows_exist_with_expected_shape():
    rows = _read_rows(KICKSTART_CSV)
    appended = [r for r in rows if "47.111" in r[0] or "47.115" in r[0]]
    # 5 models x 2 ROM versions
    assert len(appended) == 10
    models_111 = sorted(r[3] for r in appended if "47.111" in r[0])
    models_115 = sorted(r[3] for r in appended if "47.115" in r[0])
    assert models_111 == ["A1200", "A3000", "A4000", "A4000T", "CDTV"]
    assert models_115 == models_111
    for row in appended:
        assert row[7] == row[7].lower() and len(row[7]) == 32  # lowercase 32-char MD5
        assert row[9].endswith(".rom")
        assert row[10] == "False"  # CopyFile: not pre-installed
        assert row[12] == "Hyperion Entertainment"
