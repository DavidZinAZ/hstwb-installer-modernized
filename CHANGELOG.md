# Continuation changelog

This records modernization work by DavidZinAZ with AI assistance, including Scout (OpenAI Codex). The underlying installer and earlier history come from [Henrik Nørfjand Stengaard's HstWB Installer](https://github.com/henrikstengaard/hstwb-installer).

## Unreleased — October 17, 2026

- Version 1.6.7 removes remaining forced LhA PURE residency in package, self-install and OS 3.9 paths, matching the earlier OS-install correction. Show per-archive WHDLoad Packs progress and stop on archive errors; correct ZIP extraction/discovery. First magazine archive integrity and three-format builder checks passed. Native stall resolution awaits a fresh-image retest.

- Update validation notes through 1.6.6, remove identified local machine paths from documentation/tests, make optional licensed-media test paths configurable, and add a current-content privacy check. Review GitHub notes and historical content; keep the history/publication limitation explicit.
- Version 1.6.6 replaces the stale 2019 standard-package feed with direct official GitHub release discovery. Refresh stale catalogs before downloading, show byte progress/timeouts, skip matching current ZIPs, and explain stable fallback when no prerelease exists. Live-tested all 17 current packages and a repeat pass with zero downloads. Extend EAB assign compatibility to the newer Beta-menu assigns.
- Version 1.6.5 adds eight independent user-package selections: xSysInfo, KickSmash, DevTest, SDMAC, A4091 Tools, ZZ9000 Firmware, ZZ9000 Drivers and DOpus5. Retain upstream payloads, hashes, notices and source references; preserve manual hardware activation and standalone DOpus behavior. Extend source updating with raw Amiga binaries and validated ZIP archives. Native/hardware qualification remains pending.
- Advance the maintained installer version to 1.6.4. Correct Amiga WHDLoad script line endings, invoke the bundled archiver explicitly, and display its version. Prevent redundant EAB Games/Demos AGA/OCS assign confirmations for matching paths and use configured paths automatically on fresh OS installs; retain conflict confirmation on existing installations. Native WHDLoad resolution remains pending retest.
- Set an explicit 64 KiB stack in the package-installation shell and WHDLoad user package. Show WHDLoad/SKick extraction progress for diagnosis. The reported WHDLoad 18.7 stall is awaiting a fresh-image user retest; this change does not establish its cause or resolution.
- Keep settings, assigns, and logs in each installation's own `settings` folder. Update Windows launchers and preserve explicit settings-directory overrides. Offer a one-time, non-overwriting import of previous shared settings.
- Repair standard package download-directory creation, newest-version selection, and empty-folder handling. Validate downloads and package-list JSON, retain previous ZIPs, and report failures accurately.
- Add source-based user-package app checking and selective updates, catalog metadata for all bundled packages, numeric package revisions distinct from author software labels, full-package backups, source/local-identity rechecks, archive-layout validation, and explicit compatibility/manual-review statuses. Verify five real app updates in disposable copies; native app-installation qualification remains outstanding.

- Add a shared media library folder, recursive OS/ROM discovery, rescan and scan summary. Preserve explicit set/version choices and existing installation switches and file views. Keep optional separate folder overrides and support nested encrypted ROMs with their key paths. Unwanted media belongs outside the scanned tree; there is no exclusion list.

- Identify the continuation as hstwb-updated, with prominent original-project attribution and links. Preserve the MIT license, original notices, and compatible internal filenames.
- Integrate an explicit AmigaOS 3.2 target-version choice into the existing setup menu and saved settings. Prepare the base and selected update without silently including other update versions.
- Build on the earlier release manifest, checksum catalogs, host orchestration, and Amiga-side update work for the 3.2 family. Keep unsupported fresh-image 3.2.2.1 selection blocked because it requires an installed 3.2.2 source.
- Add checksum recognition and installation dispatch for 3.2.3 companion Classes, Extras, DiskDoctor, language, and model-module disks. Require the core companion disks when selecting 3.2.3.
- Correct 3.2.3 compressed startup handling and preserve the HstWB boot hook.
- Replace incompatible AmigaDOS JSON-reader quoting with the bundled Search/sed tools' simpler syntax; handle Windows PowerShell JSON spacing and check state before installation.
- Block normal completion when an update reports failure. Return from update execution to the normal installer cleanup instead of exiting the emulator prematurely.
- Avoid forced LhA PURE residency, which stalled icon archiving in native testing. Add archive progress and return-code diagnostics.
- Enforce LF checkout for nested Amiga text files to prevent Windows CRLF startup failures.
- Set A1200 and A500 WinUAE template floppy speed to Turbo (`0`), matching the existing PPC templates.
- Add a local test runner that extracts a fresh bundled image for each installation attempt, isolates settings and logs, checks write access and Turbo speed, and prevents a second installation launch on the same test disk.
- Exclude local media, generated images, recovery/session records, and test artifacts from this update. English-only test media uses the existing skip behavior for absent optional language disks.

Validation: 171 regression tests passed, one skipped; PowerShell setup selection and settings round-trip checks passed. Native base 3.2 and base-to-3.2.3 A1200 installation and Workbench boot were observed. See [validation status](docs/validation-status.md) for scope and outstanding work; these results do not establish every release, model, ROM combination, or self-install path.
# Setup display and package refresh fixes

- Show the selected Amiga OS target separately from the base media set.
- Refresh downloaded packages when opening their selection screen and after a failed batch; show the local package count and folder.

