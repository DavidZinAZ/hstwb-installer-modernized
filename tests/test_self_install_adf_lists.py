# Tests for self-install helper loose-ADF media lists (hstwb_image_setup.py / .ps1).
#
# The self-install helpers recognize loose AmigaOS ADFs by MD5 against a built-in
# "valid_amiga_os_32" list. The host media catalog (data/amiga-os-entries.csv) and
# the qualified AmigaDOS execution contract already recognize the 3.2.2 / 3.2.2.1 /
# 3.2.3 update ADFs; these tests pin the helper lists to that qualified identity set.
#
# Verified here:
#   1. Both helper lists contain exactly the qualified update ADF identities
#      (md5 + canonical filename), cross-checked against the CSV rows.
#   2. The helper MD5-index lookup (the actual recognition mechanism in both
#      scripts) accepts each of the four qualified update hashes.
#   3. All pre-existing 3.2 base-disk entries are preserved verbatim and in order.
#   4. Unsupported/deferred Classes/Modules 3.2.2/3.2.3 media are NOT in either
#      helper list.
#   5. Python and PowerShell list contents are in sync with each other.
#
# The PowerShell index-probe executes under real pwsh when available; otherwise the
# test falls back to a native parse of the ps1 literal (still asserting contents),
# and the pwsh-evaluation test is skipped.
#
# Run:  python3 -m pytest tests/test_self_install_adf_lists.py -v

import ast
import csv
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
PY_HELPER = REPO_ROOT / "support" / "hstwb_image_setup" / "hstwb_image_setup.py"
PS1_HELPER = REPO_ROOT / "support" / "hstwb_image_setup" / "hstwb_image_setup.ps1"
CSV_PATH = REPO_ROOT / "data" / "amiga-os-entries.csv"

SET_32 = "Amiga OS 3.2"

# Qualified update ADF identities: canonical filename -> { md5 } exactly as
# cataloged in data/amiga-os-entries.csv (CopyFile True) and consumed by the
# qualified Install-Adf-3.2.x execution contract.
QUALIFIED_UPDATE_ADFS = {
    "amiga-os-322-update.adf": {
        "b83e74d6fc87c40eebc102355bcf1382",
        "17257b34ff0047df27263a5a9104e190",
    },
    "amiga-os-3221-update.adf": {"9ee0f110645413020d6d18b1e4302122"},
    "amiga-os-323-update.adf": {"58aff9a5c27d8bb0c5d7c43ceeeadd6b"},
}

# Pre-existing 3.2 base-disk entries that must remain untouched (filename, md5)
# in the same relative order in both helper lists.
PRESERVED_32_BASE = [
    ("amiga-os-32-extras.adf", "4f0c3383a10e62fdea5e5758a9238223"),
    ("amiga-os-32-fonts.adf", "e03eb0505fb244aaf1c7486f6fe61ede"),
    ("amiga-os-32-install.adf", "71edc1249c013d60380d3db81fd87ae7"),
    ("amiga-os-32-locale.adf", "b697a03f0620b5e06947b5e9d7b16142"),
    ("amiga-os-32-storage.adf", "3726fab6ec5cfc48f7c2368005964d90"),
    ("amiga-os-32-workbench.adf", "5edf0b7a10409ef992ea351565ef8b6c"),
    ("amiga-os-32-modules-cd32.adf", "00b2c4d420c933894151c43dc3a24155"),
]

# Media deferred by the qualified AmigaDOS contract (commit 023c624 removed the
# Classes/Modules dispatch): must never enter the helper recognition lists.
DEFERRED_PATTERN = re.compile(r"^amiga-os-32(2|3)-(classes|modules)", re.IGNORECASE)

ALL_QUALIFIED_HASHES = {
    h for hashes in QUALIFIED_UPDATE_ADFS.values() for h in hashes
}


# ---------------------------------------------------------------------------
# extraction of the two helper lists, without executing the helper scripts
# ---------------------------------------------------------------------------

def extract_py_entries():
    """Evaluate the `valid_amiga_os_32_md5_entries` literal from the python helper."""
    tree = ast.parse(PY_HELPER.read_text(encoding="ascii"))
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if (isinstance(target, ast.Name)
                        and target.id == "valid_amiga_os_32_md5_entries"):
                    return ast.literal_eval(node.value)
    raise AssertionError("valid_amiga_os_32_md5_entries not found in python helper")


def extract_ps1_entries():
    """Parse the $validAmigaOs32Md5Entries hashtable literal from the ps1 helper
    natively (fallback used for the sync test when pwsh is unavailable)."""
    text = PS1_HELPER.read_text(encoding="ascii")
    m = re.search(
        r"\$validAmigaOs32Md5Entries = @\((.*?)\r?\n\)", text, re.DOTALL
    )
    assert m, "$validAmigaOs32Md5Entries not found in powershell helper"
    entries = []
    for line in m.group(1).splitlines():
        line = line.strip().rstrip(",")
        if not line:
            continue
        pairs = re.findall(r"'([^']*)'\s*=\s*'([^']*)'", line)
        assert pairs, f"unparsable ps1 entry line: {line}"
        entries.append({k: v for k, v in pairs})
    return entries


def load_csv_update_rows():
    """Qualified catalog rows for the three update ADFs (source of truth)."""
    reader = csv.DictReader(
        CSV_PATH.read_text(encoding="ascii").splitlines(), delimiter=";")
    return [
        r for r in reader
        if r["Set"] == SET_32 and r["Filename"] in QUALIFIED_UPDATE_ADFS
    ]


PY_PAIRS = None  # computed lazily per test


def pairs_of(entries):
    return sorted((e["Md5"].lower(), e["Filename"].lower()) for e in entries)


# ---------------------------------------------------------------------------
# 1. qualified update identities present, sourced from the catalog
# ---------------------------------------------------------------------------

def test_csv_source_of_truth_matches_expectations():
    """Guard: the QUALIFIED_UPDATE_ADFS constant mirrors the qualified catalog.
    If the CSV ever changes under this test, stop and reconcile deliberately."""
    rows = load_csv_update_rows()
    from_csv = {}
    for r in rows:
        assert r["CopyFile"] == "True", r
        from_csv.setdefault(r["Filename"], set()).add(r["Md5Hash"])
    assert from_csv == QUALIFIED_UPDATE_ADFS


def test_python_helper_contains_update_identities():
    entries = extract_py_entries()
    got = {}
    for e in entries:
        if e["Filename"] in QUALIFIED_UPDATE_ADFS:
            got.setdefault(e["Filename"].lower(), set()).add(e["Md5"].lower())
    assert got == QUALIFIED_UPDATE_ADFS


def test_powershell_helper_contains_update_identities():
    entries = extract_ps1_entries()
    got = {}
    for e in entries:
        if e["Filename"] in QUALIFIED_UPDATE_ADFS:
            got.setdefault(e["Filename"].lower(), set()).add(e["Md5"].lower())
    assert got == QUALIFIED_UPDATE_ADFS


def test_helper_entry_names_follow_convention():
    """Update entries carry the catalog disk name + Hyperion comment, matching
    every other 3.2 entry's 'Name' convention."""
    for e in extract_py_entries() + extract_ps1_entries():
        if e["Filename"] in QUALIFIED_UPDATE_ADFS:
            assert e["Name"].startswith("Amiga OS 3.2.2") or \
                e["Name"].startswith("Amiga OS 3.2.3"), e
            assert e["Name"].endswith("Update Disk, Hyperion Entertainment"), e


# ---------------------------------------------------------------------------
# 2. recognition behavior: the md5 index lookup the helpers actually run
# ---------------------------------------------------------------------------

def build_index(entries):
    """Mirror the helper indexing loop: last write wins per md5, priority by
    insertion order (python helper hstwb_image_setup.py:679-682 / ps1 :587-588)."""
    index = {}
    for e in entries:
        index[e["Md5"].lower()] = e
    return index


def test_python_index_recognizes_every_update_hash():
    index = build_index(extract_py_entries())
    for md5 in ALL_QUALIFIED_HASHES:
        assert md5 in index, f"python helper index rejects {md5}"
    # the dual-hash 3.2.2 entries both resolve to the canonical adf name
    assert index["b83e74d6fc87c40eebc102355bcf1382"]["Filename"] == "amiga-os-322-update.adf"
    assert index["17257b34ff0047df27263a5a9104e190"]["Filename"] == "amiga-os-322-update.adf"
    assert index["9ee0f110645413020d6d18b1e4302122"]["Filename"] == "amiga-os-3221-update.adf"
    assert index["58aff9a5c27d8bb0c5d7c43ceeeadd6b"]["Filename"] == "amiga-os-323-update.adf"


PWSH = shutil.which("pwsh")
requires_pwsh = pytest.mark.skipif(not PWSH, reason="pwsh not installed")

# Evaluate the real ps1 list literal + real indexing loop inside pwsh, then probe
# the resulting hashtable exactly like the helper's detection loop does.
PS1_PROBE = r"""
$ErrorActionPreference = 'Stop'
$text = Get-Content -Raw -LiteralPath '%(helper)s'
$m = [regex]::Match($text, '(?s)\$validAmigaOs32Md5Entries = @\((?<body>.*?)\r?\n\)')
if (!$m.Success) { throw 'list literal not found' }
$validAmigaOs32Md5Entries = Invoke-Expression ('@(' + $m.Groups['body'].Value + ')')
$validAmigaOs32Md5Index = @{}
$validAmigaOs32Md5Entries | ForEach-Object { $_.Priority = $validAmigaOs32Md5Index.Count + 1; $validAmigaOs32Md5Index[$_['Md5'].ToLower()] = $_ }
$probe = New-Object System.Collections.Generic.List[System.Object]
foreach ($md5 in @(%(hashes)s)) {
    if ($validAmigaOs32Md5Index.ContainsKey($md5)) {
        $probe.Add(($validAmigaOs32Md5Index[$md5]['Filename']))
    } else {
        $probe.Add($null)
    }
}
@{ Count = @($validAmigaOs32Md5Entries).Count; Probe = $probe } | ConvertTo-Json -Compress
"""


@requires_pwsh
def test_powershell_index_recognizes_every_update_hash_under_pwsh():
    hashes = sorted(ALL_QUALIFIED_HASHES)
    script = PS1_PROBE % {
        "helper": str(PS1_HELPER).replace("\\", "\\\\"),
        "hashes": ", ".join("'%s'" % h for h in hashes),
    }
    with tempfile.NamedTemporaryFile("w", suffix=".ps1", delete=False) as fh:
        fh.write(script)
        script_path = fh.name
    try:
        result = subprocess.run(
            [PWSH, "-NoProfile", "-File", script_path],
            capture_output=True, text=True, timeout=180,
        )
    finally:
        Path(script_path).unlink(missing_ok=True)
    assert result.returncode == 0, result.stderr
    data = json.loads(result.stdout.strip().splitlines()[-1])
    expected = {
        "b83e74d6fc87c40eebc102355bcf1382": "amiga-os-322-update.adf",
        "17257b34ff0047df27263a5a9104e190": "amiga-os-322-update.adf",
        "9ee0f110645413020d6d18b1e4302122": "amiga-os-3221-update.adf",
        "58aff9a5c27d8bb0c5d7c43ceeeadd6b": "amiga-os-323-update.adf",
    }
    assert data["Probe"] == [expected[h] for h in hashes]


# ---------------------------------------------------------------------------
# 3. preserved behavior for existing 3.2 base disks
# ---------------------------------------------------------------------------

def test_python_preserves_existing_entries_in_order():
    got = [(e["Filename"].lower(), e["Md5"].lower())
           for e in extract_py_entries()]
    positions = [got.index((f, m)) for f, m in PRESERVED_32_BASE]
    assert len(positions) == len(PRESERVED_32_BASE)
    assert positions == sorted(positions), "preserved 3.2 entries reordered"


def test_powershell_preserves_existing_entries_in_order():
    got = [(e["Filename"].lower(), e["Md5"].lower())
           for e in extract_ps1_entries()]
    positions = [got.index((f, m)) for f, m in PRESERVED_32_BASE]
    assert len(positions) == len(PRESERVED_32_BASE)
    assert positions == sorted(positions), "preserved 3.2 entries reordered"


# ---------------------------------------------------------------------------
# 4. deferred Classes/Modules media stay out of the helper path
# ---------------------------------------------------------------------------

def test_no_deferred_classes_modules_in_python_helper():
    for e in extract_py_entries():
        assert not DEFERRED_PATTERN.match(e["Filename"]), e["Filename"]


def test_no_deferred_classes_modules_in_powershell_helper():
    for e in extract_ps1_entries():
        assert not DEFERRED_PATTERN.match(e["Filename"]), e["Filename"]


# ---------------------------------------------------------------------------
# 5. python <-> powershell list sync
# ---------------------------------------------------------------------------

def test_python_and_powershell_lists_are_in_sync():
    assert pairs_of(extract_py_entries()) == pairs_of(extract_ps1_entries())


# ---------------------------------------------------------------------------
# 6. helper files stay ASCII/CRLF (they are deployed to Windows image tooling)
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("path", [PY_HELPER, PS1_HELPER])
def test_helpers_remain_ascii_crlf(path):
    raw = path.read_bytes()
    raw.decode("ascii")
    assert raw.count(b"\r\n") == raw.count(b"\n"), f"{path.name}: bare LF introduced"
