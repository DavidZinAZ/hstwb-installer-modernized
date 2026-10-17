# Validation status — October 16, 2026

## Observed results

- Regression suite: 171 passed, one skipped, using an isolated Linux snapshot of the changed source.
- Windows PowerShell: actual setup selector and saved-settings round trip passed, including rejection of missing or unverified selected update media.
- Native WinUAE 6.0.3: base AmigaOS 3.2 installation completed and booted to Workbench.
- Native WinUAE 6.0.3: base 3.2 followed by the selected 3.2.3 update completed through the normal installer and booted to Workbench. Installed files include TextEdit 47.72, DiskDoctor 2.194, and Startup-Sequence 47.25; the installed version.library checksum matches the supplied 3.2.3 media.

Native tests used an A1200, the original bundled 2GB DOS7 image template, the selected base 47.96 ROM, Turbo floppy speed, and English-only media. Each installation attempt extracted a new image. Boot checks used a separate copy of a completed image, preserving the original result.

## Remaining qualification

- Version 1.6.5's eight additional user packages passed host detection, payload/layout and updater checks, but native installation/application launches and hardware behavior remain unqualified. ZZ9000's official installer and firmware activation are manual target-machine steps; see [additional package notes](additional-user-packages.md).

- The source-based application updater passed local update/layout checks for five real releases in disposable package copies. Native installation and execution of those updated applications are not yet qualified; see [settings and package update validation](settings-and-package-updates.md).

- Native acceptance for 3.2.1 and 3.2.2, other models and ROM combinations, and package/self-install paths.
- Independent verification of every installed 3.2.3 module and locale file; a successful desktop boot alone does not establish complete module coverage.
- Investigation of intermittent Windows sharing locks that can cause WinUAE to open an image read-only. Exclusive-write preflight reduces failed launches but does not establish the competing process or eliminate the underlying issue.
- The older 3.2.2 and 3.2.2.1 update-only paths still need companion-media review. Do not describe them as fully qualified releases.

The supplied 3.2.3 vendor instructions accept an installed 3.2, 3.2.1, or 3.2.2 as a source. A fresh-image selection installs the base first. The 3.2.2.1 hotfix is not offered as a fresh-image target.

No commercial OS media, ROMs, or completed installation images are included in this source update.
