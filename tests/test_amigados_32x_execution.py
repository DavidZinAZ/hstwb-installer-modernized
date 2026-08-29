# Tests for the AmigaOS 3.2.x AmigaDOS execution layer.
#
# The AmigaDOS scripts cannot be executed on this host, so these tests are
# behavior-oriented static tests against the real script content and flow:
#   1. the executor's real sed extraction pipeline parses the exact pinned
#      host state format (BOM-free, LF, 2-space indent, one key per line)
#   2. every supported path maps to the intended script/update sequence
#   3. the 3.2.2.1 -> 3.2.3 edge is explicitly rejected in-script
#   4. 3.2.2.1 installer-driven update semantics are preserved
#   5. Kickstart versions match the manifest
#   6. existing 3.2 / 3.2.1 scripts and Detect-AmigaOS / InstallEntry are
#      preserved (unchanged or purely additive)
#   7. line-ending discipline for new and touched files
#   8. no copyrighted payloads enter the new files
#
# Run:  python3 -m pytest tests/test_amigados_32x_execution.py -v
#
# All fixtures are synthetic and non-copyrighted; the state format is the
# exact byte format produced by run.ps1 (GetAmigaOs32ReleaseState +
# ConvertTo-Json -Depth 5 + Set-Content -Encoding utf8).

import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
AMIGA_DIR = REPO_ROOT / "amiga" / "amiga-os-3.2" / "S" / "Amiga-OS-3.2"
MANIFEST_PATH = REPO_ROOT / "data" / "release-manifest.json"
PACKAGES_DIR = REPO_ROOT / "amiga" / "packages" / "S"

EXECUTOR = AMIGA_DIR / "Install-Update-3.2.x"
ADF_RUNNER = AMIGA_DIR / "Install-Adf-3.2.x"
INSTALL_MAIN = AMIGA_DIR / "Install-Amiga-OS-3.2"
MENU = AMIGA_DIR / "Amiga-OS-3.2-Menu"

# the 8 supported host states: (target, source, entry point, kickstart)
# 3.2.2.1 -> 3.2.3 is intentionally absent (unverified edge, host rejects it).
SUPPORTED_STATES = [
    ("3.2", None, "Amiga-OS-32-ADF", "47.96"),
    ("3.2.1", "3.2", "Amiga-OS-321-ADF", "47.102"),
    ("3.2.2", "3.2", "Install-Update-3.2.x", "47.111"),
    ("3.2.2", "3.2.1", "Install-Update-3.2.x", "47.111"),
    ("3.2.2.1", "3.2.2", "Install-Update-3.2.x", "47.111"),
    ("3.2.3", "3.2", "Install-Update-3.2.x", "47.115"),
    ("3.2.3", "3.2.1", "Install-Update-3.2.x", "47.115"),
    ("3.2.3", "3.2.2", "Install-Update-3.2.x", "47.115"),
]


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def pinned_state(target, source, entry_point, kickstart):
    """Build the exact host state byte format (ConvertTo-Json -Depth 5).

    Built by concatenation: the JSON braces would otherwise be read as
    replacement fields by str.format, so the dynamic lines use % formatting.
    """
    if source is None:
        source_line = '"SourceVersion": null,'
        sequence = '    "%s"' % target
    else:
        source_line = '"SourceVersion": "%s",' % source
        sequence = '    "%s",\n    "%s"' % (source, target)
    return (
        "{\n"
        '  "FormatVersion": "1.0",\n'
        '  "Family": "AmigaOS 3.2.x",\n'
        '  "TargetVersion": "%s",\n' % target
        + "  %s\n" % source_line
        + '  "MediaSequence": [\n'
        + "%s\n" % sequence
        + "  ],\n"
        + '  "InstallEntryPoint": "%s",\n' % entry_point
        + '  "KickstartVersion": "%s"\n' % kickstart
        + "}\n"
    )


def read(path):
    return path.read_text(encoding="utf-8")


def git_show(base_ref, rel_path):
    return subprocess.run(
        ["git", "show", "{}:{}".format(base_ref, rel_path)],
        cwd=REPO_ROOT, capture_output=True, text=True, check=True,
    ).stdout


def head_ref():
    return subprocess.run(
        ["git", "rev-parse", "--verify", "HEAD"],
        cwd=REPO_ROOT, capture_output=True, text=True, check=True,
    ).stdout.strip()


def sed_extract(script_text, key, state_text):
    """Run the executor's own sed pipeline for one key against one state."""
    pattern = None
    for line in script_text.splitlines():
        # lines look like: sed -n 's/.../p' "file"  or
        #                  set target `sed -n 's/.../p' "file"`
        if '"{}"'.format(key) in line and "sed -n " in line:
            pattern = line.split("'")[1]
            break
    assert pattern is not None, "no sed pipeline for key {} in {}".format(
        key, EXECUTOR.name)
    proc = subprocess.run(
        ["sed", "-n", pattern],
        input=state_text, capture_output=True, text=True,
    )
    assert proc.returncode == 0
    return proc.stdout.strip()


def is_subsequence(short_lines, long_lines):
    """True if short_lines appear in long_lines in order (trailing-ws blind)."""
    norm = lambda s: s.rstrip()
    it = iter(long_lines)
    return all(any(norm(s) == norm(l) for l in it) for s in short_lines)


# ---------------------------------------------------------------------------
# 1. executor state parsing
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("target,source,entry,kick", SUPPORTED_STATES)
def test_executor_sed_pipeline_parses_pinned_state(target, source, entry, kick):
    state = pinned_state(target, source, entry, kick)
    script = read(EXECUTOR)
    assert sed_extract(script, "FormatVersion", state) == "1.0"
    assert sed_extract(script, "Family", state) == "AmigaOS 3.2.x"
    assert sed_extract(script, "TargetVersion", state) == target
    if source is None:
        assert sed_extract(script, "SourceVersion", state) == ""
    else:
        assert sed_extract(script, "SourceVersion", state) == source
    assert sed_extract(script, "KickstartVersion", state) == kick


def test_adf_runner_sed_pipeline_parses_target():
    for target, source, entry, kick in SUPPORTED_STATES:
        state = pinned_state(target, source, entry, kick)
        assert sed_extract(read(ADF_RUNNER), "TargetVersion", state) == target


def test_state_format_is_bom_free_lf_single_line_keys():
    for target, source, entry, kick in SUPPORTED_STATES:
        state = pinned_state(target, source, entry, kick)
        assert not state.startswith("\ufeff")
        assert "\r" not in state
        assert state.endswith("}\n")


# ---------------------------------------------------------------------------
# 2. supported path mapping
# ---------------------------------------------------------------------------

def test_executor_no_state_is_noop():
    script = read(EXECUTOR)
    first_action = [l for l in script.splitlines()
                    if l.strip() and not l.strip().startswith(";")][0]
    assert 'IF NOT EXISTS "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json"' \
        in first_action


def test_executor_base_and_321_targets_are_noops():
    script = read(EXECUTOR)
    assert 'IF "$targetversion" EQ "3.2"' in script
    assert 'IF "$targetversion" EQ "3.2.1"' in script
    # both no-ops must skip to end without running any adf template
    base_block = script.split('IF "$targetversion" EQ "3.2"')[1].split(
        'IF "$targetversion" EQ "3.2.1"')[0]
    assert "Adf-Template" not in base_block
    assert "SKIP end" in base_block
    p321_block = script.split('IF "$targetversion" EQ "3.2.1"')[1].split(
        'IF "$targetversion" EQ "3.2.2"')[0]
    assert "Adf-Template" not in p321_block
    assert "SKIP end" in p321_block


def test_executor_322_runs_update_and_updates_prefs():
    script = read(EXECUTOR)
    block = script.split('IF "$targetversion" EQ "3.2.2"')[1].split(
        'IF "$targetversion" EQ "3.2.2.1"')[0]
    assert 'execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.x"' in block
    assert 'echo "3.2.2" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in block
    assert 'echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.2' in block
    # accepted sources only: 3.2 and 3.2.1
    assert '"$sourceversion" EQ "3.2"' in block
    assert '"$sourceversion" EQ "3.2.1"' in block
    assert '"$sourceversion" EQ "3.2.2"' not in block
    assert '"$sourceversion" EQ "3.2.2.1"' not in block


def test_executor_323_runs_update_and_updates_prefs():
    script = read(EXECUTOR)
    # the 3.2.3 block runs to the unsupported-target fallback; the source
    # guards inside it legitimately contain quit 20 before the execute line
    block = script.split('IF "$targetversion" EQ "3.2.3"')[1].split(
        "; unsupported target version")[0]
    assert 'execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.x"' in block
    assert 'echo "3.2.3" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in block
    assert 'echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.3' in block
    # accepted sources only: 3.2, 3.2.1, 3.2.2
    assert '"$sourceversion" EQ "3.2"' in block
    assert '"$sourceversion" EQ "3.2.1"' in block
    assert '"$sourceversion" EQ "3.2.2"' in block


def test_executor_unknown_target_rejected():
    script = read(EXECUTOR)
    assert "not a supported AmigaOS 3.2.x update" in script
    # the fallback rejection sits after all target blocks
    last_target = script.rfind('IF "$targetversion" EQ "3.2.3"')
    assert "not a supported AmigaOS 3.2.x update" in script[last_target:]


# ---------------------------------------------------------------------------
# 3. unsupported 3.2.2.1 -> 3.2.3 edge
# ---------------------------------------------------------------------------

def test_3221_to_323_explicitly_rejected_in_executor():
    script = read(EXECUTOR)
    block = script.split('IF "$targetversion" EQ "3.2.3"')[1]
    assert '"$sourceversion" EQ "3.2.2.1"' in block
    assert "is not supported" in block
    assert "3.2.2.1 -> 3.2.3" in block
    # the rejection must quit before any adf template runs for 3.2.3
    reject_pos = block.find('IF "$sourceversion" EQ "3.2.2.1"')
    adf_pos = block.find("Install-Adf-3.2.x")
    assert 0 < reject_pos < adf_pos
    assert "quit 20" in block[reject_pos:adf_pos]


def test_3221_target_requires_322_source():
    script = read(EXECUTOR)
    block = script.split('IF "$targetversion" EQ "3.2.2.1"')[1].split(
        'IF "$targetversion" EQ "3.2.3"')[0]
    assert '"$sourceversion" EQ "3.2.2"' in block
    for forbidden in ('"3.2"', '"3.2.1"', '"3.2.2.1"'):
        assert 'EQ ' + forbidden not in block


def test_host_manifest_does_not_accept_3221_as_source_of_323():
    manifest = __import__("json").loads(read(MANIFEST_PATH))
    releases = {r["Version"]: r for r in manifest["Releases"]}
    assert "3.2.2.1" not in releases["3.2.3"]["AcceptedSources"]
    assert releases["3.2.2.1"]["AcceptedSources"] == ["3.2.2"]
    # manifest semantics agree with the in-script rejection
    sem = releases["3.2.2.1"]["Semantics"]
    assert sem["StandaloneBase"] is False
    assert sem["RebootRequired"] is True
    assert "3.2.2.1 -> 3.2.3" in sem["Notes"]


# ---------------------------------------------------------------------------
# 4. 3.2.2.1 installer-driven update semantics
# ---------------------------------------------------------------------------

def test_3221_requires_installed_version_library_47_4():
    script = read(EXECUTOR)
    block = script.split('IF "$targetversion" EQ "3.2.2.1"')[1].split(
        'IF "$targetversion" EQ "3.2.3"')[0]
    assert "SYSTEMDIR:Libs/version.library" in block
    assert 'Version >NIL: "SYSTEMDIR:Libs/version.library" 47 4' in block
    assert "quit 20" in block


def test_3221_detector_enforces_version_library_47_4():
    script = read(AMIGA_DIR / "Detect-Update3.2.2.1")
    assert 'IF NOT "`Which $amigaosdisk:`" EQ "Update3.2.2.1:"' in script
    assert 'IF NOT EXISTS "SYSTEMDIR:Libs/version.library"' in script
    assert 'Version >NIL: "SYSTEMDIR:Libs/version.library" 47 4' in script
    assert "SKIP notvalid" in script


def test_3221_installer_copies_release_and_workbench():
    script = read(AMIGA_DIR / "Install-Update3.2.2.1")
    assert 'Copy >NIL: "$amigaosdisk:Update/Release" ' \
           '"SYSTEMDIR:Prefs/Env-Archive/Versions"' in script
    assert 'Copy >NIL: "$amigaosdisk:Update/Startup-HardDrive" ' \
           '"SYSTEMDIR:S/Startup-Sequence"' in script
    # workbench replacement (manifest Semantics.WorkbenchReplacement=true)
    assert 'IF EXISTS "$amigaosdisk:Workbench"' in script
    assert 'Copy >NIL: "$amigaosdisk:Workbench/#?" ' \
           '"SYSTEMDIR:Workbench" ALL CLONE' in script


def test_3221_is_not_characterized_as_standalone_base():
    executor = read(EXECUTOR)
    assert "not standalone base media" in executor
    runner = read(ADF_RUNNER)
    # 3.2.2.1 dispatches a single update adf, no base install set
    block = runner.split('IF "$target" EQ "3.2.2.1"')[1].split(
        'IF "$target" EQ "3.2.3"')[0]
    assert 'amiga-os-3221-update.adf' in block
    assert block.count("Adf-Template") == 1


# ---------------------------------------------------------------------------
# 5. kickstart mapping
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("target,source,entry,kick", SUPPORTED_STATES)
def test_kickstart_matches_manifest(target, source, entry, kick):
    manifest = __import__("json").loads(read(MANIFEST_PATH))
    releases = {r["Version"]: r for r in manifest["Releases"]}
    assert releases[target]["RomSet"]["KickstartVersion"] == kick
    assert releases[target]["InstallEntryPoint"] == entry


def test_expected_media_sequence_shape():
    for target, source, entry, kick in SUPPORTED_STATES:
        state = pinned_state(target, source, entry, kick)
        if source is None:
            assert '"MediaSequence": [\n    "{}"\n  ],'.format(target) \
                in state
        else:
            assert '"MediaSequence": [\n    "{}",\n    "{}"\n  ],'.format(
                source, target) in state


# ---------------------------------------------------------------------------
# 6. adf runner and detect/install dispatch
# ---------------------------------------------------------------------------

ADF_DISPATCH = [
    ("3.2.2", "Update3.2.2", "amiga-os-322-update.adf",
     ["amiga-os-322-classes.adf", "amiga-os-322-modules.adf"]),
    ("3.2.2.1", "Update3.2.2.1", "amiga-os-3221-update.adf", []),
    ("3.2.3", "Update3.2.3", "amiga-os-323-update.adf",
     ["amiga-os-323-classes.adf", "amiga-os-323-modules.adf"]),
]


@pytest.mark.parametrize("target,disk,required,optional", ADF_DISPATCH)
def test_adf_runner_dispatch(target, disk, required, optional):
    runner = read(ADF_RUNNER)
    assert 'setenv amigaosdisk "ff0"' in runner
    block = runner.split('IF "$target" EQ "{}"'.format(target))[1].split(
        "SKIP adfdone")[0]
    # required update adf is checked before dispatch
    assert 'IF NOT EXISTS "INSTALLDIR:Temp/Amiga-OS/{}"'.format(required) \
        in block
    assert "quit 20" in block.split(
        'IF NOT EXISTS "INSTALLDIR:Temp/Amiga-OS/{}"'.format(required))[1]
    # adf template dispatch with the update volume name
    assert '"INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "{}"'.format(disk) \
        in block
    assert '"INSTALLDIR:Temp/Amiga-OS/{}"'.format(required) in block
    # optional disks are guarded by IF EXISTS
    for opt in optional:
        assert 'IF EXISTS "INSTALLDIR:Temp/Amiga-OS/{}"'.format(opt) \
            in block


def test_detect_and_install_pairs_exist_for_template_dispatch():
    # Adf-Template references Detect-{disk} and Install-{disk}
    template = read(AMIGA_DIR / "Adf-Template")
    assert "Detect-{disk}" in template
    assert "Install-{disk}" in template
    for target, disk, required, optional in ADF_DISPATCH:
        detector = AMIGA_DIR / "Detect-{}".format(disk)
        installer = AMIGA_DIR / "Install-{}".format(disk)
        assert detector.is_file(), detector
        assert installer.is_file(), installer
        det = read(detector)
        assert 'IF NOT "`Which $amigaosdisk:`" EQ "{}:"'.format(disk) in det
        assert "SKIP notvalid" in det
        assert "LAB end" in det
        # every update installer copies the release state
        assert 'Copy >NIL: "$amigaosdisk:Update/Release" ' \
               '"SYSTEMDIR:Prefs/Env-Archive/Versions"' in read(installer)


def test_detectors_require_release_state():
    for target, disk, required, optional in ADF_DISPATCH:
        det = read(AMIGA_DIR / "Detect-{}".format(disk))
        assert 'IF NOT EXISTS "$amigaosdisk:Update/Release"' in det


# ---------------------------------------------------------------------------
# 7. backward compatibility
# ---------------------------------------------------------------------------

UNCHANGED_FILES = [
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Adf-3.2.1",
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Detect-Update3.2.1",
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Update3.2.1",
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Adf-Template",
    "amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Adf",
    "amiga/packages/S/Detect-AmigaOS",
    "amiga/packages/S/InstallEntry",
]


@pytest.mark.parametrize("rel_path", UNCHANGED_FILES)
def test_existing_files_unchanged(rel_path):
    head = head_ref()
    assert read(REPO_ROOT / rel_path) == git_show(head, rel_path), \
        "{} must remain untouched".format(rel_path)


def test_install_amiga_os_32_edit_is_purely_additive():
    head = head_ref()
    original = git_show(head, "amiga/amiga-os-3.2/S/Amiga-OS-3.2/"
                              "Install-Amiga-OS-3.2")
    current = read(INSTALL_MAIN)
    assert is_subsequence(original.splitlines(), current.splitlines())
    # the 3.2.1 update flow still runs before the new hook
    p321 = current.find("Install-Adf-3.2.1")
    hook = current.find("Install-Update-3.2.x")
    assert 0 < p321 < hook
    # the hook is gated on the state file
    assert 'IF EXISTS "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json"' \
        in current[hook - 400:hook]


def test_menu_edit_is_purely_additive_and_gated():
    head = head_ref()
    original = git_show(head, "amiga/amiga-os-3.2/S/Amiga-OS-3.2/"
                              "Amiga-OS-3.2-Menu")
    current = read(MENU)
    assert is_subsequence(original.splitlines(), current.splitlines())
    # the new line is gated on the state file
    assert 'IF EXISTS "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json"' in current
    assert "Amiga OS 3.2.x Update detected" in current
    # existing 3.2.1 detection line preserved
    assert "Amiga OS 3.2.1 Update detected" in current


def test_32_base_and_321_flow_preserved_in_install_main():
    current = read(INSTALL_MAIN)
    # existing 3.2 base flow
    assert 'execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf"' in current
    assert 'execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Disk"' in current
    assert 'echo "3.2" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in current
    # existing 3.2.1 flow
    assert 'execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.1"' in current
    assert 'echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.1' in current


# ---------------------------------------------------------------------------
# 8. line endings and payload hygiene
# ---------------------------------------------------------------------------

NEW_AMIGA_FILES = [
    EXECUTOR, ADF_RUNNER,
    AMIGA_DIR / "Detect-Update3.2.2",
    AMIGA_DIR / "Detect-Update3.2.2.1",
    AMIGA_DIR / "Detect-Update3.2.3",
    AMIGA_DIR / "Install-Update3.2.2",
    AMIGA_DIR / "Install-Update3.2.2.1",
    AMIGA_DIR / "Install-Update3.2.3",
]


@pytest.mark.parametrize("path", NEW_AMIGA_FILES)
def test_new_amiga_scripts_are_lf_ascii(path):
    data = path.read_bytes()
    assert b"\r" not in data, "{} must be LF-only".format(path.name)
    data.decode("ascii")  # raises on non-ascii


def test_readmes_match_self_install_convention_crlf():
    for rel in ("support/self_install/amigaos/amiga-os-3.2.2/readme.txt",
                "support/self_install/amigaos/amiga-os-3.2.3/readme.txt"):
        data = (REPO_ROOT / rel).read_bytes()
        assert data.endswith(b"\r\n")
        assert b"\n" not in data.replace(b"\r\n", b"")
        data.decode("ascii")


def test_no_copyrighted_payload_references_in_new_files():
    for path in NEW_AMIGA_FILES:
        text = path.read_text(encoding="utf-8")
        for forbidden in (".lha", ".rom", ".zip", ".lzx"):
            assert forbidden not in text, (
                "{} must not reference archive payloads".format(path.name))


# ---------------------------------------------------------------------------
# 9. executor structural sanity
# ---------------------------------------------------------------------------

def test_executor_uses_house_conventions():
    script = read(EXECUTOR)
    # explicit, boring flow: guarded reads, explicit exits, no magic
    assert "quit 20" in script
    assert "SKIP end" in script
    assert "LAB end" in script
    # state file path matches the host contract
    assert 'INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json' in script
    # reboot is required for all update completions (3.2.2.1 semantics)
    assert "TotalReset" in script
    assert "UAEquit" in script


def test_executor_updates_version_prefs_for_each_target():
    script = read(EXECUTOR)
    assert 'echo "3.2.2" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in script
    assert 'echo "3.2.2.1" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in script
    assert 'echo "3.2.3" NOLINE >SYSTEMDIR:Prefs/AmigaOS' in script
