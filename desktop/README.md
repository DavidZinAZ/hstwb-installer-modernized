# HstWB Windows desktop preview

**Using the Windows app? Read the [complete GUI user guide](../docs/gui/README.md), or open [the offline browser edition](../docs/gui/user-guide.html).** It covers the tab-by-tab workflow without requiring command-line setup. The [CLI documentation](../docs/cli/README.md) covers the original tools separately.

This page contains desktop development, build, and packaging notes.

Extract the complete portable ZIP to a writable folder and double-click **HstwbDesktop.exe**. Keep the support folders beside the executable. Windows with .NET Framework 4.8 and an installed WinUAE or FS-UAE emulator are required. Commercial AmigaOS and Kickstart media are supplied separately.

From a source checkout, double-click `desktop.cmd` to compile and open the app using the installed Windows .NET Framework compiler. No additional SDK or package restore is required.

## What is included

- Separate Packages, User Packages, and Games & Demos libraries, source links, versions, sorting, local scans, online update checks, and download progress. Verified current versions are reused.
- Media & ROMs discovery with AmigaOS target and Kickstart selection, present/missing entries, and a compatible installer boot-ROM explanation.
- Workbench 1.3 and AmigaOS 3.2 inspired light/dark themes.
- A Settings tab for saving/loading profiles and opening the original setup when needed.
- Persistent scan results with timestamps, scoped to the selected folders. Saved results are informational; installation rescans before running.
- Review & Install validates media, package dependencies and conflicts, then creates a **fresh image from the selected template for every run**. Each image goes into a separate `Install-...` subfolder. Existing images are preserved. The app launches the emulator and reports completion or failure with a log path.

Installer settings and assigns are backed up before application. Image creation supports HDF and directory drives, including nested template ZIPs, and checks that output paths stay inside the new image folder. A failed creation remains in its own folder for inspection; installation is not started from an incomplete creation.

User-package installation approvals record a local choice; they do not bypass source, checksum, or compatibility restrictions. Component selections can map to complete installer bundles, which are listed during review. WHDLoad list generation uses the maintained builder and backs up generated lists without changing game archives.

The optional PrismRTG and PrismNet user packages extract their original
installation files and pause for Enter after each package. Complete setup later
from their Amiga drawers using the upstream installers. Their system components
and configuration are managed there. See the [package notes](../docs/additional-user-packages.md)
and [creator acknowledgments](../ACKNOWLEDGMENTS.md).

NetHarness, NilBBS, AmiFM, NilTerm, AmiDT, SCSIToolbox-Amiga, NoClick, AmiTime
and AmiSSL-Tunnel use the same extraction-and-pause flow. Their original readmes
describe manual activation and requirements. Existing staged drawers are retained.

## Build a portable release

The desktop app uses the installer version from `modules/version.psm1`. The build reads that shared value for the main heading, window title, and executable version details. Every change must increment `HstwbInstallerVersion` (normally the patch number); rebuilding automatically refreshes the desktop version so both stay in sync.

Commit the source changes first, then run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/build_desktop_release.ps1
```

The builder exports a committed Git revision, compiles the WPF executable, bundles the installer runtime and existing tracked support content, verifies the extracted app layout, and writes a portable ZIP plus SHA-256 checksum under `.release/desktop`. It does not bundle local settings, scan caches, downloaded package libraries, personal WHDLoad collections, commercial media, or emulators. The existing tracked user-package payloads retain their original license notices.

GitHub Actions **Windows desktop build** runs on pushes and pull requests. Its downloadable artifact contains the ZIP and checksum. A manual **Run workflow** is also available once the workflow is on the default branch. This is separate from the older Imager prerelease workflow. A successful master build automatically updates the desktop-preview GitHub prerelease, including GUI and CLI ZIPs and checksums. The main-page download addresses stay the same. Branches and pull requests build artifacts without publishing. Publication runs in a separate job with write permissions, verifies checksums, uploads all files before promoting their permanent names, and restores prior asset names if promotion fails. A build superseded by a newer master commit is skipped.

The EXE is unsigned. This is a portable preview, not a single-file app or MSI installer. A signed installer can wrap this same verified layout later. Native image/emulator installation should still be tested with licensed media before declaring a stable release.

## Validation

The build workflow checks bundled payload versions and hashes with `test_user_package_updates.ps1`, then runs `test_desktop_media.ps1`, `test_desktop_library.ps1`, `test_desktop_games.ps1`, `test_desktop_image_builder.ps1`, and `test_desktop_installer_plan.ps1`, then verifies the packaged WPF application with `--smoke`.

These tests use synthetic media, local download fixtures and a fake installation engine. They verify cache persistence, settings roundtrips, themes, sorting, native settings backups/rollback, boot-ROM fallback, fresh image extraction and preservation, and success/failure reporting. They do not run a real Amiga installation or contact upstream package servers.
