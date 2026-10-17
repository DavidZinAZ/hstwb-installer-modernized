# Continuation changelog

This records modernization work by DavidZinAZ with AI assistance, including Scout (OpenAI Codex). The underlying installer and earlier history come from [Henrik Nørfjand Stengaard's HstWB Installer](https://github.com/henrikstengaard/hstwb-installer).

## Unreleased — October 16, 2026

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
