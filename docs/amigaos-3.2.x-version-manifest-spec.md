# HSTWB-02 SPEC — Manifest-Driven AmigaOS 3.2.x Version Model

Date: 2026-08-26
Corrections applied: 2026-08-26 (HSTWB-03 spec correction)

Scope: Implementation specification for AmigaOS 3.2.x support using operator-supplied Hyperion archives and the validation extracts produced from them (exact media locations are operator-managed and intentionally not recorded in this repository).

> This specification is for implementation guidance only. It does not reproduce Hyperion documentation or copyrighted payload metadata.

## Executive recommendation

Introduce a version-family manifest layer for AmigaOS 3.2.x that preserves existing 3.2/3.2.1 behavior, models updates/hotfixes declaratively, and keeps media discovery, validation, and install sequencing parameterized by manifest data rather than hardcoded version branches.

Preferred path: add a first-class release-manifest layer as the authoritative source for release-level facts, while retaining `data/amiga-os-entries.csv` as the media/disk catalog. Install behavior should derive from manifest/media metadata and hashes, not from filename parsing or hardcoded upgrade graphs.

## 1. Manifest/schema-driven release model

### 1.1 Release taxonomy

- `base` — first-class installation source for a given 3.2.x patch level. Only one base may be active per install: 3.2 currently, with future 3.2.x bases possible.
- `update` — cumulative patch set that can be applied over one or more accepted sources. 3.2.1, 3.2.2, and 3.2.3 are updates in this taxonomy.
- `hotfix` — optional update variant that is distributed alongside another release but is not a standalone base. 3.2.2.1 is not modeled as a hotfix candidate; inspection shows it is an ordinary update for an installed 3.2.2 system.

### 1.2 Release-level manifest fields

Authoritative release facts should live in a first-class release-manifest layer (file/format TBD), not in `data/amiga-os-entries.csv`. Required facts include:

- `Version`: release version identifier
- `ReleaseType`: base/update/hotfix
- `AcceptedSources`: versions that this release can be applied over
- `Includes` / `Supersedes`: versions whose changes are included in this release
- `ArchiveIdentity` / `Hash`: media-package identity for `.lha` packages supplied by the operator
- `RomSet`: Kickstart version required by this release
- `ValidationProfile`: adf/rom/installed-files/modules/mutools or subset
- `InstallEntryPoint`: pref marker or script path used to start installation
- `HotfixSemantics`: not applicable for 3.2.2.1; record verified 3.2.2 prerequisite, Workbench replacement behavior, `Prefs/Env-Archive/Versions` marker, reboot requirement, and model-selection behavior instead

`data/amiga-os-entries.csv` remains the media/disk catalog: it stores per-disk metadata such as volume names, filenames, per-ADF MD5 hashes, models, install pref markers, and comments. New fields should remain additive and optional so existing CSV consumers ignore unknown columns.

### 1.3 Release identity and hashing

- Use source-archive identity/hash at media-package level for `.lha` packages supplied by the operator.
- Keep per-ADF MD5 entries in the CSV for runtime validation of extracted ADFs.
- Release identity and behavior must derive from manifest/media metadata and hashes, not filename parsing.
- Existing filename patterns may remain as compatibility/discovery helpers, but they are not the source of truth for version identity.

### 1.4 Kickstart ROM requirements

Operator-supplied media establishes the following Kickstart facts. The spec requires release metadata for these ROM sets; 3.2.2/3.2.3 ROM entries must not be described as hypothetical:

- 3.2.1 = Kickstart 47.102
- 3.2.2 / 3.2.2.1 package = Kickstart 47.111
- 3.2.3 = Kickstart 47.115

### 1.5 Accepted sources vs included/superseded versions

These are distinct concepts:

- `AcceptedSources` defines what installed state an update may be applied over.
- `Includes` / `Supersedes` defines what prior changes are bundled into the release.

Example:
- 3.2.3 `AcceptedSources` = 3.2, 3.2.1, 3.2.2
- 3.2.3 `Includes` / `Supersedes` = 3.2.1, 3.2.2

## 2. Upgrade graph

### 2.1 Verified accepted-source edges

Current evidence supports the following accepted-source relationships:

- 3.2 -> 3.2.1
- 3.2 -> 3.2.2
- 3.2.1 -> 3.2.2
- 3.2.2 -> 3.2.2.1
- 3.2.2 -> 3.2.3
- 3.2.1 -> 3.2.3
- 3.2 -> 3.2.3

### 2.2 Pending validation

The following edge is unverified and must not be treated as a documented upgrade path until focused validation completes:

- 3.2.2.1 -> 3.2.3

The operator's 3.2.2.1 archive contains the full 3.2.2 update set plus `Update3.2.2.1.adf`. Inspection of `Update3.2.2.1.adf` confirms `3.2.2 -> 3.2.2.1` is a verified accepted-source edge with explicit 3.2.2 prerequisite, `Libs/version.library` 47.4 check, Workbench file replacement, `Prefs/Env-Archive/Versions` update/Release marker, reboot requirement, and model-selection behavior.

Implementation guidance:
- Model accepted-source edges explicitly from release metadata rather than assuming linear progression.
- If manifests declare supersedes relationships, the installer can present only valid upgrade targets for the currently installed detected version.

## 3. Manifest fields mapped to current HstWB files/code paths

### 3.1 Data/metadata

- `data/release-manifest` (new) — authoritative source for release-level facts listed in section 1.2
- `data/amiga-os-entries.csv` — retained as media/disk catalog; add optional columns only if they support media discovery without duplicating release semantics
- `data/kickstart-entries.csv` — add expected 3.2.2/3.2.3 ROM entries because those ROM versions are already established by operator-supplied media

### 3.2 Host discovery/validation

- `support/hstwb_image_setup/hstwb_image_setup.ps1` — extend ADF/ROM MD5 discovery to 3.2.2/3.2.3 entries; add optional manifest-path discovery for `.lha` packages
- `support/hstwb_image_setup/hstwb_image_setup.py` — same parity as PS1 script

### 3.3 Install script generation

- `run.ps1` — extend prefs generation:
  - detect `amiga-os-32x-*.adf` and archive patterns generically
  - create prefs such as `Amiga-OS-322-ADF`, `Install-Amiga-OS-322-ADF`, `Amiga-OS-323-ADF`, `Install-Amiga-OS-323-ADF`, `Amiga-OS-3221-ADF`, `Install-Amiga-OS-3221-ADF`
- `amiga/amiga-os-3.2/S/Amiga-OS-3.2/Amiga-OS-3.2-Menu` — add optional menu entries for 3.2.2/3.2.3 when pref markers exist
- `amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Amiga-OS-3.2` — branch to a generic update executor when 3.2.2/3.2.3 prefs are present

### 3.4 Amiga-side sequencing

Add shared update executor:

- `amiga/amiga-os-3.2/S/Amiga-OS-3.2/Install-Update-3.2.x` — generic update runner parameterized by detected version and manifest role
- `amiga/amiga-os-3.2/S/Amiga-OS-3.2/Detect-Update-3.2.x` — generic update detector

Keep existing specialized `Detect-Update3.2.1` and `Install-Adf-3.2.1` until the generic runner is verified.

## 4. Preservation of existing 3.2 and 3.2.1 behavior

- Do not change existing `Amiga-OS-32-ADF` and `Amiga-OS-321-ADF` flows.
- Keep current `Install-Amiga-OS-3.2`, `Install-Adf-3.2.1`, and `Detect-Update3.2.1` behavior intact.
- New 3.2.2/3.2.3 paths must be additive and disabled unless manifest/media is present.
- Existing supported-version filtering must continue to recognize `3.2` and `3.2.1`; extend supported-version registry only if new base versions are added later.

## 5. 3.2.2.1 update handling

- 3.2.2.1 is an ordinary update for an installed AmigaOS 3.2.2 system. Inspection of `Update3.2.2.1.adf` confirms the following verified behavior:
  - Source prerequisite: installed 3.2.2. Accepted source for this release is 3.2.2 only.
  - Installer check: `Libs/version.library` version 47 revision 4 must be present on the target.
  - Application behavior: replaces Workbench files from 3.2.2 on the selected target and copies `Update/Release` into `Prefs/Env-Archive/Versions`.
  - Reboot: required after installation.
  - Hardware/model selection: used for choosing the appropriate system updates.
- 3.2.2.1 is an installer-driven update requiring an installed 3.2.2. It is not a standalone base and is not modeled as a hotfix candidate.

## 5.1 3.2.2.1 onward upgrade status

- `3.2.2.1 -> 3.2.3` is not established as a directly documented accepted-source edge from the current verified evidence.
- `HotfixSemantics` is not applicable for 3.2.2.1; release-level metadata should record the verified 3.2.2 prerequisite, Workbench replacement behavior, `Prefs/Env-Archive/Versions` marker, reboot requirement, and model-selection behavior.

## 6. Media discovery from operator-supplied `.lha` packages

Recommended flow:

1. Operator places unpacked or archived `.lha` media under an operator-managed media directory outside Git.
2. Host-side discovery scans for known archive identities by manifest metadata, not hardcoded paths.
3. Discovery extracts temporary ADF/ROM candidates into a scratch workspace; licensed payloads are never copied into the repo.
4. Validation compares extracted ADF/ROM hashes against `data/amiga-os-entries.csv` and optional release-manifest MD5/SHA files.
5. After validation, host-side script generation copies only verified ADFs/ROMs into the temporary install image workspace.

Identity principle:
- Release identity and behavior derive from manifest/media metadata and hashes, not filename parsing.
- Existing filename patterns may remain as compatibility/discovery helpers.

Privacy/license safeguard:
- Repo must remain free of Hyperion payload files, extracted documentation text, and operator-specific path secrets.
- Include only checksums, filenames, volume names, and install roles needed to drive installer logic.

## 7. Test/QA acceptance criteria

### 7.1 Mandatory criteria

Per target:
- 3.2: base install detection, module menu, disk validation, Kickstart 3.2 mapping, prefs generation
- 3.2.1: update detection over valid 3.2, update over invalid base must fail gracefully
- 3.2.2: update detection over 3.2 and 3.2.1; skip if neither valid base present
- 3.2.2.1: verified update detection over installed 3.2.2 only; requires 3.2.2 base and `Libs/version.library` 47.4
- 3.2.3: update detection over 3.2, 3.2.1, and 3.2.2; menu/prefs reflect selected path

Representative upgrade paths:
- clean 3.2 -> 3.2.1
- clean 3.2 -> 3.2.3
- clean 3.2.1 -> 3.2.3
- clean 3.2.2 -> 3.2.2.1
- attempt 3.2.1 without 3.2 base must fail with clear message

Non-functional QA:
- existing 3.2 and 3.2.1 flows must remain unchanged in behavior/output
- package filtering must continue using supported-version registry without widening unexpectedly
- no licensed payload files may be written into Git-tracked paths by build/install flows

### 7.2 Pending validation

The following criteria are explicitly deferred until focused validation completes:
- `3.2.2.1 -> 3.2.3`: accepted-source semantics are not established as a documented edge in current evidence
- clean 3.2 -> 3.2.2 -> 3.2.2.1 -> 3.2.3 sequence

## 8. Future-version extensibility

Recommended conventions so future 3.2.x releases require minimal code changes:

- New release metadata-first: add manifest entry/metadata first; code paths read behavior from metadata.
- Release-manifest layer: keep release-level facts in one place rather than scattering them across CSV, code, and scripts.
- Version-family modules: keep all 3.2.x logic in `amiga/amiga-os-3.2/S/Amiga-OS-3.2/` rather than creating `amiga-os-3.4`, etc., until a new base family is required.
- Shared runner scripts: `Install-Update-3.2.x` and `Detect-Update-3.2.x` should accept version/role parameters from prefs or detected manifest instead of hardcoding version strings.
- Host-side discovery should map filename/role patterns generically: `amiga-os-32x-*.adf`.
- Supported-version registry should be data-driven from CSV and package metadata rather than hardcoded in multiple PowerShell/Python/AmigaDOS sites.
- Additive schema: new manifest fields should be optional and ignored by older code paths.

### 8.1 Long-project boundary preservation

Phase 2 will likely modernize `user-packages/`, and later phases may address historical upstream issues. Boundaries must remain reusable and avoid a one-off OS-only rewrite. The 3.2.x manifest layer should be designed so it can inform, but not constrain, future packaging work.

## 9. Recommended smallest implementation task chain

This specification intentionally stops at task recommendations. No child tasks are created here.

1. Release manifest layer
   - Define `data/release-manifest` schema and file format
   - Add release entries for all Phase 1 releases/states: 3.2 as base, 3.2.1 as update, 3.2.2 as cumulative update, 3.2.2.1 as verified update from 3.2.2, and 3.2.3 as cumulative update, with accepted sources, includes/supersedes, ROM set, archive identity/hash, validation profile, install entry point, and non-hotfix semantics where applicable
   - Add Kickstart ROM entries to `data/kickstart-entries.csv` for 47.111 and 47.115 as required/expected metadata for the releases that use them

2. Host discovery parity
   - Update `hstwb_image_setup.ps1` and `.py` for 3.2.2/3.2.3 ADF/ROM discovery and release-manifest discovery
   - Add `.lha` package handling for operator media directory

3. Install prefs generation
   - Extend `run.ps1` to emit new prefs markers for 3.2.2/3.2.3 and 3.2.2.1 as a 3.2.2 update

4. Shared AmigaDOS update runtime
   - Add generic `Detect-Update-3.2.x` and `Install-Update-3.2.x`
   - Update `Amiga-OS-3.2-Menu` to offer new update paths when prefs exist

5. Validation and QA
   - Manual QA for each supported target and verified upgrade path
   - Regression checks for existing 3.2/3.2.1 flows
   - Deferred QA for onward `3.2.2.1 -> 3.2.3` until focused validation

6. Documentation
   - Add self-install readmes for 3.2.2/3.2.3 media requirements
   - Keep this spec as the authoritative architecture reference

## 10. Summary of corrections

- Established `3.2.2 -> 3.2.2.1` as a verified accepted-source edge; left `3.2.2.1 -> 3.2.3` unresolved.
- Replaced unresolved hotfix language with verified 3.2.2.1 installer facts: prerequisite `Libs/version.library` 47.4, Workbench replacement, `Prefs/Env-Archive/Versions` marker, reboot requirement, and model-selection behavior.
- Replaced 3.2.2.1 hotfix candidate wording with update-from-3.2.2 wording in release taxonomy, manifest fields, upgrade graph, QA, and implementation plan.
- Retained first-class release-manifest architecture, CSV media catalog separation, AcceptedSources distinct from Includes/Supersedes, ROM facts, filename-patterns-not-source-of-truth, and long-project extensibility.

## 11. Remaining unresolved assumptions

- `3.2.2.1 -> 3.2.3` is not established as a directly documented accepted-source edge from the current verified evidence.
- Exact file format/location/name of the first-class release-manifest layer.
- Whether additional CSV columns are needed for media/discovery before the release-manifest layer is implemented.

## 12. Qualification snapshot — 2026-08-29

Baseline: `a7d46a8fed441aa4b9328368df7bc8e10a45df0e`

Status: AmigaOS 3.2.x implementation is qualified through all currently executable layers using real licensed media.

Qualified layers:
- host media recognition: PASS
- run.ps1 State.json generation: PASS
- self-install loose-ADF recognition: PASS
- staging contract: PASS
- AmigaDOS dispatch/source/prerequisite/rejection logic: PASS
- full test suite: 166 passed
- no code change was required during end-to-end qualification

Remaining qualification gap:
- True booted Amiga/UAE runtime execution has not yet been performed.

Missing prerequisites in the current environment:
1. A legally acquired Kickstart 47.x ROM suitable for AmigaOS 3.2.x.
2. A UAE-compatible emulator runtime such as FS-UAE or Amiberry.
3. A display-attached, remotely controllable, or otherwise automatable emulator execution environment.

Important findings:
- The licensed Hyperion AmigaOS 3.2.x archives currently available do not contain a usable Kickstart ROM image.
- This is not a known code defect.
- No 3.2.2.1 -> 3.2.3 upgrade edge should be inferred or added at this time.

Residual risk until true runtime qualification:
- emulator-specific floppy/media handling
- diskcopy/timing behavior
- interactive Workbench/AmigaDOS execution quirks

Evidence:
- PRIVATE_MEDIA_LOCATION

Resume true runtime qualification only when the legal ROM and emulator prerequisites are available.
