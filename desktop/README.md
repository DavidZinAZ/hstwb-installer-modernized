# HstWB Windows desktop preview

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

## Build a portable release

Commit the source changes first, then run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/build_desktop_release.ps1
```

The builder exports a committed Git revision, compiles the WPF executable, bundles the installer runtime and existing tracked support content, verifies the extracted app layout, and writes a portable ZIP plus SHA-256 checksum under `.release/desktop`. It does not bundle local settings, scan caches, downloaded package libraries, personal WHDLoad collections, commercial media, or emulators. The existing tracked user-package payloads retain their original license notices.

GitHub Actions **Windows desktop build** runs on pushes and pull requests. Its downloadable artifact contains the ZIP and checksum. A manual **Run workflow** is also available once the workflow is on the default branch. This is separate from the older Imager prerelease workflow. Pushing source alone does not publish a GitHub Release; a downloadable Actions artifact is produced after the build succeeds.

The EXE is unsigned. This is a portable preview, not a single-file app or MSI installer. A signed installer can wrap this same verified layout later. Native image/emulator installation should still be tested with licensed media before declaring a stable release.

## Validation

The build workflow runs `test_desktop_media.ps1`, `test_desktop_library.ps1`, `test_desktop_games.ps1`, `test_desktop_image_builder.ps1`, and `test_desktop_installer_plan.ps1`, then verifies the packaged WPF application with `--smoke`.

These tests use synthetic media, local download fixtures and a fake installation engine. They verify cache persistence, settings roundtrips, themes, sorting, native settings backups/rollback, boot-ROM fallback, fresh image extraction and preservation, and success/failure reporting. They do not run a real Amiga installation or contact upstream package servers.