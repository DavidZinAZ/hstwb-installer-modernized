# Tests for host-side AmigaOS 3.2.x media catalog entries (3.2.2 / 3.2.2.1 / 3.2.3).
#
# These tests verify the host-side catalog slice:
#   1. data/amiga-os-entries.csv schema, CRLF discipline, and that every
#      manifest ArchiveIdentity release has a catalog row matched by MD5
#      metadata (filename is a hint only, CopyFile False for archives).
#   2. every update ADF the qualified AmigaDOS execution layer requires
#      (parsed from Install-Adf-3.2.x) has a CopyFile True catalog row with
#      the exact volume name the Adf-Template invokes.
#   3. the two legitimate vendor Update3.2.2.adf hashes (original 3.2.2
#      package vs the re-bundled 3.2.2.1 package copy) are both cataloged,
#      following the established multi-hash row pattern (3.1.4 install disks).
#   4. no invented 3.2.2.1 -> 3.2.3 upgrade edge exists, and the manifest-
#      driven state detection algorithm (run.ps1) resolves the expected
#      target/source for representative archive sets.
#   5. all qualified pre-existing 3.2 / 3.2.1 catalog rows are preserved.
#   6. functional recognition smoke using the real host modules (data.psm1
#      FindMatchingFileHashes / FindMatchingAmigaOsEntriesByAdfVolumeName)
#      under pwsh against the locally licensed media, when available.
#
# No copyrighted media is read from, copied into, or referenced by the
# repository: the CSV contains only hashes and file names (metadata).
#
# Run:  python3 -m pytest tests/test_amiga_os_32x_media.py -v

import csv
import json
import re
import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = REPO_ROOT / "data" / "amiga-os-entries.csv"
MANIFEST_PATH = REPO_ROOT / "data" / "release-manifest.json"
ADF_RUNNER = (
    REPO_ROOT / "amiga" / "amiga-os-3.2" / "S" / "Amiga-OS-3.2" / "Install-Adf-3.2.x"
)

# licensed media + extracted trees, if present on this host (never committed)
LICENSED_MEDIA_DIR = Path("PRIVATE_MEDIA_LOCATION")

SET_32 = "Amiga OS 3.2"

CSV_HEADER = [
    "Name", "Required", "Set", "AmigaOsVersion", "KickstartVersionRequired",
    "Model", "Md5Hash", "VolumeName", "Filename", "CopyFile",
    "InstallAmigaOsPrefs", "Comment",
]

# MD5s of the update ADFs measured from the licensed vendor archives
# (extracted off-repo; the values here are metadata only).
EXPECTED_UPDATE_ADF_HASHES = {
    "amiga-os-322-update.adf": {
        # Update3.2.2.adf from AmigaOS-3.2.2.lha
        "b83e74d6fc87c40eebc102355bcf1382",
        # Update3.2.2.adf re-bundled inside AmigaOS-3.2.2.1-Hotfix.lha
        "17257b34ff0047df27263a5a9104e190",
    },
    "amiga-os-3221-update.adf": {
        "9ee0f110645413020d6d18b1e4302122",
    },
    "amiga-os-323-update.adf": {
        "58aff9a5c27d8bb0c5d7c43ceeeadd6b",
    },
}

# verbatim qualified rows that must remain untouched (3.2 / 3.2.1 behavior pin)
PRESERVED_ROWS = [
    "Amiga OS 3.2 Workbench Disk;True;Amiga OS 3.2;3.2;3.1;;5edf0b7a10409ef992ea351565ef8b6c;Workbench3.2;amiga-os-32-workbench.adf;True;Amiga-OS-32-ADF;Hyperion Entertainment",
    "Amiga OS 3.2 Install Disk;True;Amiga OS 3.2;3.2;3.1;;71edc1249c013d60380d3db81fd87ae7;Install3.2;amiga-os-32-install.adf;True;Amiga-OS-32-ADF;Hyperion Entertainment",
    "Amiga OS 3.2.1 Update Disk;False;Amiga OS 3.2;3.2;3.1;;13ccf7096a9ca66af0d8bdf0a1c4e500;Update3.2.1;amiga-os-321-update.adf;True;Amiga-OS-321-ADF;Hyperion Entertainment",
]


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def load_rows():
    raw = CSV_PATH.read_bytes()
    text = raw.decode("ascii")
    reader = csv.DictReader(text.splitlines(), delimiter=";")
    assert reader.fieldnames == CSV_HEADER
    return [row for row in reader if row["Name"] and row["Name"].strip()]


def load_manifest():
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))


def manifest_releases():
    return {r["Version"]: r for r in load_manifest()["Releases"]}


def detect_release_state(detected_versions):
    """Mirror run.ps1 state detection: newest detected target that is a base
    release, or an update release with at least one detected accepted
    source; otherwise None (mirrors the `break` / no-state outcomes)."""

    def vkey(v):
        return tuple(int(p) for p in v.split("."))

    releases = manifest_releases()
    for target in sorted(detected_versions, key=vkey, reverse=True):
        release = releases[target]
        if release["ReleaseType"] == "base":
            return (target, None)
        sources = [s for s in release["AcceptedSources"] if s in detected_versions]
        if sources:
            return (target, sources[0])
    return None


# ---------------------------------------------------------------------------
# 1. schema / line endings / metadata-only content
# ---------------------------------------------------------------------------

def test_csv_is_ascii_crlf_and_consistent():
    raw = CSV_PATH.read_bytes()
    raw.decode("ascii")  # metadata-only: catalog must stay plain ASCII
    assert raw.count(b"\r\n") == raw.count(b"\n")  # CRLF throughout (repo blob convention)


def test_csv_rows_have_exact_column_count():
    for line in CSV_PATH.read_text(encoding="ascii").splitlines():
        if not line.strip():
            continue
        assert len(line.split(";")) == len(CSV_HEADER), line


def test_md5_fields_are_lowercase_hex32():
    for row in load_rows():
        assert re.fullmatch(r"[0-9a-f]{32}", row["Md5Hash"]), row["Name"]


# ---------------------------------------------------------------------------
# 2. manifest is the source of truth for archive recognition
# ---------------------------------------------------------------------------

def test_every_manifest_release_has_md5_archive_catalog_row():
    rows = load_rows()
    for version, release in manifest_releases().items():
        identity = release.get("ArchiveIdentity")
        assert identity, f"manifest release {version} has no ArchiveIdentity"
        matches = [
            r for r in rows
            if r["Set"] == SET_32
            and r["Md5Hash"] == identity["Md5Hash"].lower()
            and r["Filename"] == identity["Filename"]
        ]
        assert len(matches) == 1, f"release {version} not cataloged exactly once"
        row = matches[0]
        # archives are recognition metadata only - never raw-copied, no volume
        assert row["CopyFile"] == "False"
        assert row["VolumeName"] == ""
        assert row["Required"] == "False"
        assert row["Model"] == ""


def test_release_archive_rows_carry_no_copy_or_prefs_trigger():
    """Archive rows must not set any prefs trigger: dispatch is state-file driven."""
    for row in load_rows():
        if row["Filename"].lower().endswith(".lha") and row["Set"] == SET_32:
            assert row["CopyFile"] == "False", row["Name"]
            assert row["InstallAmigaOsPrefs"] == "", row["Name"]


# ---------------------------------------------------------------------------
# 3. execution-contract coverage (3.2.2 / 3.2.2.1 / 3.2.3 update ADFs)
# ---------------------------------------------------------------------------

def parse_adf_contract():
    """(target_version, temp_adf_filename, template_volume) from the qualified
    Install-Adf-3.2.x script - the authoritative host-side obligation."""
    text = ADF_RUNNER.read_text(encoding="ascii")
    contract = []
    blocks = re.split(r"\nIF \"\$target\" EQ \"([0-9.]+)\"\n", text)[1:]
    it = iter(blocks)
    for version, body in zip(it, it):
        adf = re.search(r"Temp/Amiga-OS/([A-Za-z0-9._-]+\.adf)", body)
        template = re.search(
            r'Execute "INSTALLDIR:S/Amiga-OS-3\.2/Adf-Template" "([A-Za-z0-9._-]+)"',
            body,
        )
        assert adf and template, f"unparsable contract block for {version}"
        contract.append((version, adf.group(1), template.group(1)))
    return contract


def test_execution_contract_targets_are_32x_updates():
    contract = parse_adf_contract()
    assert sorted(v for v, _, _ in contract) == ["3.2.2", "3.2.2.1", "3.2.3"]


def test_every_contract_adf_has_copy_enabled_catalog_row():
    rows = load_rows()
    for version, adf_name, volume in parse_adf_contract():
        matches = [
            r for r in rows
            if r["Set"] == SET_32
            and r["Filename"] == adf_name
            and r["CopyFile"] == "True"
        ]
        assert matches, f"execution contract {adf_name} not cataloged"
        for row in matches:
            assert row["VolumeName"] == volume, (
                f"{adf_name} volume '{row['VolumeName']}' != contract volume '{volume}'"
            )
        assert rows_match_update_hashes(adf_name, matches)


def rows_match_update_hashes(adf_name, matches):
    got = {row["Md5Hash"] for row in matches}
    return got == EXPECTED_UPDATE_ADF_HASHES[adf_name]


def test_dual_hash_update322_rows_follow_multi_hash_pattern():
    """Two legitimate Update3.2.2.adf variants (original vs hotfix re-bundle)
    share identity and differ only by MD5 - the qualified 3.1.4 precedent."""
    rows = [
        r for r in load_rows()
        if r["Filename"] == "amiga-os-322-update.adf"
    ]
    assert len(rows) == 2
    keys = [k for k in CSV_HEADER if k != "Md5Hash"]
    assert {tuple(r[k] for k in keys) for r in rows}.__len__() == 1, \
        "dual-hash rows must be identical except Md5Hash"
    assert {r["Md5Hash"] for r in rows} == EXPECTED_UPDATE_ADF_HASHES["amiga-os-322-update.adf"]


# ---------------------------------------------------------------------------
# 4. no invented upgrade edge + manifest-driven detection outcomes
# ---------------------------------------------------------------------------

def test_no_3221_to_323_edge():
    releases = manifest_releases()
    assert "3.2.2.1" not in releases["3.2.3"]["AcceptedSources"]
    assert "3.2.2.1" not in releases["3.2.3"].get("Includes", [])


def test_only_hotfix_source_is_322_for_hotfix_target():
    releases = manifest_releases()
    assert releases["3.2.2.1"]["AcceptedSources"] == ["3.2.2"]


def test_detection_resolves_newest_target_with_accepted_source():
    # full ladder archives present -> newest update (3.2.3) from 3.2.2
    assert detect_release_state({"3.2", "3.2.1", "3.2.2", "3.2.3"}) == ("3.2.3", "3.2")
    # 3.2.2 + base -> 3.2.2 from 3.2
    assert detect_release_state({"3.2", "3.2.2"}) == ("3.2.2", "3.2")
    # hotfix + its source -> 3.2.2.1 from 3.2.2
    assert detect_release_state({"3.2.2", "3.2.2.1"}) == ("3.2.2.1", "3.2.2")
    # 3.2.2.1 + 3.2.3 only: no accepted source for 3.2.3 and 3.2.2.1's
    # source (3.2.2) is absent -> the unverified 3.2.2.1 -> 3.2.3 edge must
    # NOT be silently invented; only a base archive may produce state.
    assert detect_release_state({"3.2.2.1", "3.2.3"}) is None


def test_base_only_detection_unchanged():
    assert detect_release_state({"3.2"}) == ("3.2", None)


# ---------------------------------------------------------------------------
# 5. qualified 3.2 / 3.2.1 catalog behavior preserved
# ---------------------------------------------------------------------------

def test_qualified_rows_preserved_verbatim():
    text = CSV_PATH.read_text(encoding="ascii")
    lines = {line for line in text.splitlines() if line.strip()}
    for row in PRESERVED_ROWS:
        assert row in lines, f"qualified row changed or missing:\n{row}"


def test_32_set_row_counts_pin_preservation():
    rows = [r for r in load_rows() if r["Set"] == SET_32]
    old_adf = [r for r in rows if re.match(r"^amiga-os-32-[^.\-]", r["Filename"] + "x")
               or r["Filename"].startswith("amiga-os-32-")
               or r["Filename"].startswith("amiga-os-321-")]
    new_rows = [r for r in rows if r not in old_adf]
    assert len(old_adf) == 60, "qualified 3.2/3.2.1 rows were not preserved intact"
    assert len(new_rows) == 37, "release archives, update disks, and 3.2.3 companion media"


def test_new_adf_rows_never_trigger_legacy_32_or_321_markers():
    """run.ps1 legacy marker patterns are '^amiga-os-32-[^.]+\\.adf' and
    '^amiga-os-321-[^.]+\\.adf'; new update files must not leak into them."""
    legacy = re.compile(r"^amiga-os-32-[^.\-]+\.adf$|^amiga-os-321-[^.\-]+\.adf$")
    for name in EXPECTED_UPDATE_ADF_HASHES:
        assert not legacy.match(name), name


# ---------------------------------------------------------------------------
# 6. functional recognition smoke (real modules + real licensed media)
# ---------------------------------------------------------------------------

PWSH = shutil.which("pwsh")
requires_pwsh = pytest.mark.skipif(not PWSH, reason="pwsh not installed")
requires_media = pytest.mark.skipif(
    not LICENSED_MEDIA_DIR.is_dir(), reason="licensed media dir not present"
)


SMOKE_PS1 = r"""
$ErrorActionPreference = 'Stop'
Import-Module '%(moduledir)s/data.psm1' -Force
$hstwb = [pscustomobject]@{
    Settings = [pscustomobject]@{ Installer = [pscustomobject]@{ Mode = 'Install' } }
    Paths = [pscustomobject]@{ AmigaOsEntriesFile = '%(csv)s' }
    AmigaOsEntries = @()
}
UpdateAmigaOsEntries $hstwb
$entries = $hstwb.AmigaOsEntries

# archive recognition by md5 against the manifest identity hashes
FindMatchingFileHashes $entries '%(media)s' | Out-Null
$archiveRows = $entries | Where-Object { $_.Filename -like '*.lha' -and $_.File }
$adfs = Get-ChildItem '%(adfs)s' -Filter *.adf
FindMatchingAmigaOsEntriesByAdfVolumeName $entries '%(adfs)s' | Out-Null
$updateRows = $entries | Where-Object { $_.Filename -in @(
    'amiga-os-322-update.adf','amiga-os-3221-update.adf','amiga-os-323-update.adf') -and $_.File }

$out = @{
    archives = @($archiveRows | ForEach-Object { $_.Filename })
    archiveMatchTypes = @($archiveRows | ForEach-Object { $_.MatchType })
    updateFiles = @($updateRows | ForEach-Object { $_.Filename } | Sort-Object -Unique)
}
$out | ConvertTo-Json -Compress
"""


@requires_pwsh
@requires_media
def test_pwsh_functional_recognition_against_licensed_media(tmp_path):
    # loose update ADFs under their vendor names in a throwaway dir
    adf_dir = tmp_path / "amiga-os-dir"
    adf_dir.mkdir()
    extracted = Path("/tmp/hstwb-media-work")
    wanted = [
        ("x-322/Update3.2.2/ADFs/Update3.2.2.adf", "Update3.2.2.adf"),
        ("x-3221/Update3.2.2/ADFs/Update/Update3.2.2.adf", "Update3.2.2-hotfixcopy.adf"),
        ("x-3221/Update3.2.2/ADFs/Hotfix/Update3.2.2.1.adf", "Update3.2.2.1.adf"),
        ("x-323/Update3.2.3/ADFs/Update3.2.3.adf", "Update3.2.3.adf"),
    ]
    available = [(s, d) for s, d in wanted if (extracted / s).is_file()]
    if len(available) != len(wanted):
        pytest.skip("extracted vendor ADF tree not present under /tmp/hstwb-media-work")
    for src, dst in available:
        shutil.copyfile(extracted / src, adf_dir / dst)

    script = SMOKE_PS1 % {
        "moduledir": REPO_ROOT / "modules",
        "csv": CSV_PATH,
        "media": LICENSED_MEDIA_DIR,
        "adfs": adf_dir,
    }
    script_file = tmp_path / "smoke.ps1"
    script_file.write_text(script, encoding="utf-8")
    result = subprocess.run(
        [PWSH, "-NoProfile", "-File", str(script_file)],
        capture_output=True, text=True, timeout=180,
    )
    assert result.returncode == 0, result.stderr
    data = json.loads(result.stdout.strip().splitlines()[-1])

    # every manifest release archive recognized by MD5 metadata
    identities = {
        r["ArchiveIdentity"]["Filename"]
        for r in manifest_releases().values() if r.get("ArchiveIdentity")
    }
    assert set(data["archives"]) == identities & {
        "AmigaOS-3.2-full.lha", "AmigaOS-3.2.1.lha", "AmigaOS-3.2.2.lha",
        "AmigaOS-3.2.2.1-Hotfix.lha", "AmigaOS-3.2.3.lha",
    }
    assert set(data["archiveMatchTypes"]) == {"MD5"}

    # all three contract ADF identities recognized from loose vendor files
    assert set(data["updateFiles"]) == set(EXPECTED_UPDATE_ADF_HASHES)
