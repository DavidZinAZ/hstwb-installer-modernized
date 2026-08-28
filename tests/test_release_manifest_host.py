# Tests for the host-side release manifest integration (HSTWB-10).
#
# Proves, with the real manifest plus synthetic fixtures:
#   1. release_manifest_host loads the real manifest and indexes the five
#      Phase-1 releases' ArchiveIdentity MD5 blocks
#   2. MD5 metadata is authoritative for archive recognition (case-insensitive,
#      unknown hashes unrecognized)
#   3. filenames are a discovery hint only (indexed case-insensitively)
#   4. AcceptedSource edges are enforced exactly as declared: 3.2.2 -> 3.2.2.1
#      accepted, 3.2.2.1 -> 3.2.3 NOT accepted, self-references rejected
#   5. malformed manifests (bad MD5 shape, duplicate MD5 claim, invalid JSON,
#      missing file) fail clearly
#   6. manifest/host ROM cross-check catches inconsistencies in both directions
#   7. the CLI contract: exit 0 recognized/allowed, 1 manifest/usage error,
#      2 valid-input negative answer
#   8. hstwb_image_setup.py loads the repo manifest on import and its built-in
#      kickstart ROM entries are consistent with it
#   9. hstwb_image_setup.ps1 carries a self-contained (no-Python) manifest
#      block that mirrors the MD5-authoritative recognition logic
#
# Run:  python3 -m pytest tests/test_release_manifest_host.py -v
#
# All fixture data is synthetic and non-copyrighted.

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
TOOLS_DIR = REPO_ROOT / "tools"
MANIFEST_PATH = REPO_ROOT / "data" / "release-manifest.json"
HOST_SCRIPT_PY = REPO_ROOT / "support" / "hstwb_image_setup" / "hstwb_image_setup.py"
HOST_SCRIPT_PS1 = REPO_ROOT / "support" / "hstwb_image_setup" / "hstwb_image_setup.ps1"
HOST_MODULE_PATH = TOOLS_DIR / "release_manifest_host.py"

sys.path.insert(0, str(TOOLS_DIR))

from release_manifest_host import (  # noqa: E402
    accepted_sources,
    archive_identity_by_filename,
    archive_identity_by_md5,
    check_archive_filename,
    check_archive_md5,
    check_manifest_consistency,
    detect_release_states,
    get_release,
    is_accepted_source,
    load_release_manifest,
    release_index,
)


# real manifest facts (data/release-manifest.json, HSTWB-08)
MD5_32 = "89ebf1b01a970cc88e114fa21ea388a6"
MD5_321 = "0f69c17125c9dfba37e2901835abbe33"
MD5_322 = "fa6fc2c7ff94d42b307f13cc7db36717"
MD5_3221 = "18e144ddfbc409980ea306885a12afd2"
MD5_323 = "f5bf7b0cbcf84d30204ab9182a003c63"
UNKNOWN_MD5 = "deadbeefdeadbeefdeadbeefdeadbeef"

KNOWN_ROM_ENTRIES = [
    {"KickstartVersion": "47.115", "ReleaseVersion": "3.2.3"},
    {"KickstartVersion": "47.111", "ReleaseVersion": "3.2.2"},
    {"KickstartVersion": "47.111", "ReleaseVersion": "3.2.2.1"},
    {"KickstartVersion": "47.102", "ReleaseVersion": "3.2.1"},
    {"KickstartVersion": "47.96", "ReleaseVersion": "3.2"},
]


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


def _write_manifest(tmp_path, releases):
    data = {
        "FormatVersion": "1.0",
        "Family": "Synthetic",
        "Releases": releases,
    }
    path = tmp_path / "manifest.json"
    path.write_text(json.dumps(data), encoding="utf-8")
    return path


def _release(version, accepted=(), rom="100.1", filename=None, md5="ab" * 16):
    if filename is None:
        filename = "rel-{0}.lha".format(version)
    return {
        "Version": version,
        "ReleaseType": "base" if not accepted else "update",
        "AcceptedSources": list(accepted),
        "Includes": [],
        "Supersedes": [],
        "RomSet": {"KickstartVersion": rom},
        "ValidationProfile": ["adf"],
        "InstallEntryPoint": "Install-Test",
        "ArchiveIdentity": {"Filename": filename, "Md5Hash": md5},
    }


def _run_cli(*args):
    return subprocess.run(
        [sys.executable, str(TOOLS_DIR / "release_manifest_host.py")] + list(args),
        capture_output=True,
        text=True,
    )


# ---------------------------------------------------------------------------
# 1. real manifest loads; five releases indexed
# ---------------------------------------------------------------------------

def test_real_manifest_loads_clean(manifest):
    assert manifest is not None


def test_release_index_covers_all_five_releases(manifest):
    assert sorted(release_index(manifest)) == ["3.2", "3.2.1", "3.2.2", "3.2.2.1", "3.2.3"]


def test_md5_index_covers_all_five_releases(manifest):
    index, errors = archive_identity_by_md5(manifest)
    assert errors == [], errors
    assert set(index) == {
        MD5_32.lower(),
        MD5_321.lower(),
        MD5_322.lower(),
        MD5_3221.lower(),
        MD5_323.lower(),
    }
    assert index[MD5_3221.lower()][0] == "3.2.2.1"


def test_get_release_returns_entry_or_none(manifest):
    assert get_release(manifest, "3.2.2")["Version"] == "3.2.2"
    assert get_release(manifest, "9.9") is None


# ---------------------------------------------------------------------------
# 2. MD5 metadata is authoritative
# ---------------------------------------------------------------------------

def test_check_archive_md5_recognizes_each_release(manifest):
    expected = {
        MD5_32: "3.2",
        MD5_321: "3.2.1",
        MD5_322: "3.2.2",
        MD5_3221: "3.2.2.1",
        MD5_323: "3.2.3",
    }
    for md5, version in expected.items():
        got_version, _release = check_archive_md5(manifest, md5)
        assert got_version == version, "MD5 {} must identify {}".format(md5, version)


def test_check_archive_md5_is_case_insensitive(manifest):
    got_version, _release = check_archive_md5(manifest, MD5_322.upper())
    assert got_version == "3.2.2"


def test_check_archive_md5_rejects_unknown_hash(manifest):
    assert check_archive_md5(manifest, UNKNOWN_MD5) == (None, None)


def test_check_archive_md5_rejects_non_md5_input(manifest):
    for bad in ("", "xyz", "ab" * 16 + "!", 12345, None):
        assert check_archive_md5(manifest, bad) == (None, None)


# ---------------------------------------------------------------------------
# 3. filenames are a discovery hint only
# ---------------------------------------------------------------------------

def test_check_archive_filename_recognizes_case_insensitive(manifest):
    got_version, _release = check_archive_filename(manifest, "AMIGAOS-3.2.3.LHA")
    assert got_version == "3.2.3"


def test_check_archive_filename_rejects_empty_and_unknown(manifest):
    assert check_archive_filename(manifest, "") == (None, None)
    assert check_archive_filename(manifest, "   ") == (None, None)
    assert check_archive_filename(manifest, "no-such-package.lha") == (None, None)


def test_filename_index_flags_ambiguous_hints(tmp_path):
    data, errors = load_release_manifest(
        _write_manifest(
            tmp_path,
            [
                _release("1.0", md5="aa" * 16, filename="same.lha"),
                _release("1.1", accepted=["1.0"], md5="bb" * 16, filename="same.lha"),
            ],
        )
    )
    assert errors == [], "valid fixture must load clean: {}".format(errors)
    _index, index_errors = archive_identity_by_filename(data)
    assert any("ambiguous" in e for e in index_errors), index_errors


# ---------------------------------------------------------------------------
# 4. AcceptedSource edges enforced exactly as declared
# ---------------------------------------------------------------------------

def test_322_to_3221_accepted(manifest):
    assert is_accepted_source(manifest, "3.2.2", "3.2.2.1") is True


def test_3221_to_323_not_accepted(manifest):
    # the unverified onward edge must never be inferred
    assert is_accepted_source(manifest, "3.2.2.1", "3.2.3") is False


@pytest.mark.parametrize(
    "installed,target",
    [
        ("3.2", "3.2.1"),
        ("3.2", "3.2.2"),
        ("3.2.1", "3.2.2"),
        ("3.2", "3.2.3"),
        ("3.2.1", "3.2.3"),
        ("3.2.2", "3.2.3"),
    ],
)
def test_declared_edges_accepted(manifest, installed, target):
    assert is_accepted_source(manifest, installed, target) is True


@pytest.mark.parametrize(
    "installed,target",
    [
        ("3.2.1", "3.2"),      # base has no accepted sources
        ("3.2.2.1", "3.2.2.1"),  # self-reference (see test_self_reference_never_accepted)
    ],
)
def test_rejected_edges(manifest, installed, target):
    assert is_accepted_source(manifest, installed, target) is False


def test_self_reference_never_accepted(manifest):
    for version in ("3.2", "3.2.1", "3.2.2", "3.2.2.1", "3.2.3"):
        assert is_accepted_source(manifest, version, version) is False


def test_unknown_versions_rejected(manifest):
    assert is_accepted_source(manifest, "9.9", "3.2.3") is False
    assert is_accepted_source(manifest, "3.2", "9.9") is False
    assert accepted_sources(manifest, "9.9") is None


def test_non_string_inputs_rejected(manifest):
    assert is_accepted_source(manifest, None, "3.2.3") is False
    assert is_accepted_source(manifest, "", "3.2.3") is False
    assert is_accepted_source(manifest, "3.2", "") is False


# ---------------------------------------------------------------------------
# 5. malformed manifests fail clearly
# ---------------------------------------------------------------------------

def test_bad_md5_shape_reported_per_release(tmp_path):
    data, _errors = load_release_manifest(
        _write_manifest(tmp_path, [_release("1.0", md5="NOTANMD5")])
    )
    _index, index_errors = archive_identity_by_md5(data)
    assert any("not a 32-char hex MD5" in e for e in index_errors), index_errors


def test_duplicate_md5_claim_reported(tmp_path):
    data, _errors = load_release_manifest(
        _write_manifest(
            tmp_path,
            [
                _release("1.0", md5="cc" * 16),
                _release("1.1", accepted=["1.0"], md5="CC" * 16),  # same hash, different case
            ],
        )
    )
    _index, index_errors = archive_identity_by_md5(data)
    assert any("claimed by both" in e for e in index_errors), index_errors


def test_invalid_json_returns_none_and_error(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{ this is not json", encoding="utf-8")
    data, errors = load_release_manifest(bad)
    assert data is None
    assert any("not valid JSON" in e for e in errors), errors


def test_missing_file_returns_none_and_error(tmp_path):
    data, errors = load_release_manifest(tmp_path / "nope.json")
    assert data is None
    assert any("cannot read manifest file" in e for e in errors), errors


# ---------------------------------------------------------------------------
# 6. manifest / host ROM cross-check
# ---------------------------------------------------------------------------

def test_known_rom_entries_consistent_with_manifest(manifest):
    assert check_manifest_consistency(manifest, KNOWN_ROM_ENTRIES) == []


def test_manifest_release_missing_from_host_entries(manifest):
    # drop the 47.115/3.2.3 entry: manifest says 3.2.3 needs it, host has none
    entries = [e for e in KNOWN_ROM_ENTRIES if e["KickstartVersion"] != "47.115"]
    errors = check_manifest_consistency(manifest, entries)
    assert any("47.115" in e for e in errors), errors


def test_host_entry_declares_unknown_release(manifest):
    entries = KNOWN_ROM_ENTRIES + [{"KickstartVersion": "47.999", "ReleaseVersion": "9.9"}]
    errors = check_manifest_consistency(manifest, entries)
    assert any("not declared in the manifest" in e for e in errors), errors


def test_host_entry_rom_version_mismatch(manifest):
    entries = [
        e if e["KickstartVersion"] != "47.111" or e["ReleaseVersion"] != "3.2.2"
        else {"KickstartVersion": "47.102", "ReleaseVersion": "3.2.2"}
        for e in KNOWN_ROM_ENTRIES
    ]
    errors = check_manifest_consistency(manifest, entries)
    assert any("47.102" in e and "3.2.2" in e for e in errors), errors


# ---------------------------------------------------------------------------
# 7. CLI contract
# ---------------------------------------------------------------------------

def test_cli_list_prints_versions_in_order():
    completed = _run_cli("--list")
    assert completed.returncode == 0
    assert completed.stdout.splitlines() == ["3.2", "3.2.1", "3.2.2", "3.2.2.1", "3.2.3"]
    assert completed.stderr == ""


def test_cli_check_archive_recognized_exit_zero():
    completed = _run_cli("--check-archive", MD5_3221)
    assert completed.returncode == 0
    assert completed.stdout.strip() == "3.2.2.1"
    assert completed.stderr == ""


def test_cli_check_archive_unknown_exit_two():
    completed = _run_cli("--check-archive", UNKNOWN_MD5)
    assert completed.returncode == 2
    assert "no release matches" in completed.stdout


def test_cli_check_archive_non_md5_exit_one():
    completed = _run_cli("--check-archive", "not-an-md5")
    assert completed.returncode == 1
    assert "not a 32-char hex MD5" in completed.stderr


def test_cli_check_source_accepted_exit_zero():
    completed = _run_cli("--check-source", "3.2.2", "3.2.2.1")
    assert completed.returncode == 0
    assert "AcceptedSource of '3.2.2.1'" in completed.stdout


def test_cli_check_source_not_accepted_exit_two():
    completed = _run_cli("--check-source", "3.2.2.1", "3.2.3")
    assert completed.returncode == 2
    assert "NOT an accepted source of '3.2.3'" in completed.stdout


def test_cli_check_source_unknown_target_exit_one():
    completed = _run_cli("--check-source", "3.2", "9.9")
    assert completed.returncode == 1
    assert "unknown target release '9.9'" in completed.stderr


def test_cli_missing_manifest_exit_one():
    completed = _run_cli("--list", str(REPO_ROOT / "no-such-manifest.json"))
    assert completed.returncode == 1
    assert "cannot read manifest file" in completed.stderr


def test_cli_malformed_manifest_exit_one(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{ not json", encoding="utf-8")
    completed = _run_cli("--list", str(bad))
    assert completed.returncode == 1
    assert "not valid JSON" in completed.stderr


def test_cli_no_action_prints_usage_exit_one():
    completed = _run_cli()
    assert completed.returncode == 1
    assert "usage" in completed.stderr.lower()


def test_cli_explicit_manifest_path_respected():
    completed = _run_cli("--list", str(MANIFEST_PATH))
    assert completed.returncode == 0
    assert completed.stdout.splitlines() == ["3.2", "3.2.1", "3.2.2", "3.2.2.1", "3.2.3"]


# ---------------------------------------------------------------------------
# 8. hstwb_image_setup.py integration
#    The manifest wiring lives in the file header (before the "# arguments"
#    section). The full script has an unguarded top-level main flow that
#    requires CLI arguments, so the header is executed directly in a fresh
#    namespace with __file__ set to the real script path.
# ---------------------------------------------------------------------------

def _exec_host_script_header(script_path):
    """Execute the real header of the host script (up to '# arguments')."""
    text = Path(script_path).read_text(encoding="utf-8")
    marker = "# arguments"
    index = text.find(marker)
    assert index != -1, "expected '# arguments' marker in host script header"
    header = text[:index]
    namespace = {"__file__": str(Path(script_path).resolve())}
    exec(compile(header, str(Path(script_path).resolve()), "exec"), namespace)
    return namespace


def test_host_script_loads_repo_manifest_on_import():
    module = _exec_host_script_header(HOST_SCRIPT_PY)
    assert module["_release_manifest_data"] is not None, (
        "the repo manifest must load when the host script header runs from the "
        "repository: {}".format(module["_release_manifest_errors"])
    )
    assert module["_release_manifest_errors"] == []
    assert module["_release_manifest_source"] == str(MANIFEST_PATH)
    assert module["_release_manifest_rom_errors"] == [], (
        "built-in kickstart ROM entries must be consistent with the manifest: "
        "{}".format(module["_release_manifest_rom_errors"])
    )


def test_host_script_without_manifest_stays_in_force(tmp_path):
    # image-dir deployment: no manifest anywhere in the lookup chain. The
    # built-in entries must remain fully in force and no manifest state may
    # leak in.
    empty_dir = tmp_path / "empty"
    empty_dir.mkdir()
    script_copy = empty_dir / "hstwb_image_setup.py"
    script_copy.write_bytes(HOST_SCRIPT_PY.read_bytes())
    old_env_value = os.environ.get("HSTWB_RELEASE_MANIFEST")
    os.environ["HSTWB_RELEASE_MANIFEST"] = str(tmp_path / "no-such-manifest.json")
    try:
        module = _exec_host_script_header(script_copy)
    finally:
        if old_env_value is None:
            os.environ.pop("HSTWB_RELEASE_MANIFEST", None)
        else:
            os.environ["HSTWB_RELEASE_MANIFEST"] = old_env_value
    assert module["_release_manifest_data"] is None
    assert module["_release_manifest_errors"] == []
    assert module["_release_manifest_source"] is None
    assert module["_release_manifest_rom_errors"] == []


# ---------------------------------------------------------------------------
# 9. hstwb_image_setup.ps1 static verification
#    (pwsh is not available on this host; verify the committed block is
#    present, self-contained, and mirrors the MD5-authoritative logic)
# ---------------------------------------------------------------------------

def _ps1_text():
    return HOST_SCRIPT_PS1.read_text(encoding="utf-8")


def test_ps1_manifest_block_present():
    text = _ps1_text()
    assert "release manifest (HSTWB-10)" in text
    assert "$releaseManifestData = $null" in text
    assert "$releaseManifestArchiveByMd5 = @{}" in text
    assert "$releaseManifestArchiveByFilename = @{}" in text


def test_ps1_uses_env_var_and_relative_candidates():
    text = _ps1_text()
    assert "$env:HSTWB_RELEASE_MANIFEST" in text
    assert "(Join-Path $PSScriptRoot -ChildPath '../../data/release-manifest.json')" in text


def test_ps1_md5_authoritative_recognition():
    text = _ps1_text()
    # 32-char hex MD5 validation, lowercase-keyed index, MD5-first lookup
    assert "$identity.Md5Hash -match '^[0-9a-fA-F]{32}$'" in text
    assert "$releaseManifestArchiveByMd5[$identity.Md5Hash.ToLower()] = $release" in text
    assert "$releaseManifestArchiveByMd5.ContainsKey($md5File.Md5)" in text
    assert "$releaseManifestArchiveByMd5[$md5File.Md5].Version" in text


def test_ps1_block_is_self_contained_no_python_delegation():
    text = _ps1_text()
    # the manifest block must load the manifest itself, never via python
    assert "Get-Content -Raw -LiteralPath $candidate | ConvertFrom-Json -ErrorAction Stop" in text
    assert "ConvertFrom-Json -Path $candidate" not in text
    lowered = text.lower()
    assert "python" not in lowered.replace("python", "PYTHON") or "python" in lowered
    # direct assertion: no python/pwsh-python invocation of the host module
    assert "release_manifest_host" not in lowered
    assert "& python" not in lowered
    assert "Invoke-Expression" not in text


def test_ps1_recognition_is_a_no_op_without_manifest():
    text = _ps1_text()
    assert "if ($null -ne $releaseManifestData)" in text
    assert "This block is self-contained: it never" in text


@pytest.mark.skipif(shutil.which("pwsh") is None, reason="PowerShell is not installed")
def test_ps1_real_runtime_detects_manifest_release_from_matching_md5(tmp_path):
    """Exercise the PowerShell host path that previously swallowed -Path errors."""
    amiga_os_dir = tmp_path / "amiga-os"
    for directory in (amiga_os_dir, tmp_path / "install", tmp_path / "kickstart", tmp_path / "packages"):
        directory.mkdir()

    manifest = tmp_path / "manifest.json"
    manifest.write_text(
        json.dumps({
            "FormatVersion": "1.0",
            "Family": "AmigaOS 3.2.x",
            "Releases": [{
                "Version": "3.2.2",
                "AcceptedSources": [],
                "RomSet": {"KickstartVersion": "47.111"},
                "ArchiveIdentity": {
                    "Filename": "fixture.lha",
                    "Md5Hash": "d41d8cd98f00b204e9800998ecf8427e",
                },
            }],
        }),
        encoding="utf-8",
    )
    (amiga_os_dir / "fixture.lha").write_bytes(b"")

    result = subprocess.run(
        [
            shutil.which("pwsh"), "-NoProfile", "-NonInteractive", "-File", str(HOST_SCRIPT_PS1),
            "-installDir", str(tmp_path / "install"),
            "-amigaOsDir", str(amiga_os_dir),
            "-kickstartDir", str(tmp_path / "kickstart"),
            "-userPackagesDir", str(tmp_path / "packages"),
            "-patchOnly",
        ],
        capture_output=True,
        text=True,
        env={**os.environ, "HSTWB_RELEASE_MANIFEST": str(manifest)},
    )

    assert result.returncode == 0, result.stderr
    assert "3.2.x release states detected from manifest metadata: 3.2.2" in result.stdout
    assert "No 3.2.x release states detected from manifest metadata" not in result.stdout
