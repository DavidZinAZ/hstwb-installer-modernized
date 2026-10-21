# Validation status — October 21, 2026

## Observed results

- Installer 1.6.17 adds nine extraction-only application bundles and the
  NetHarness PC companion. Published release hashes, LhA/ZIP members, catalog
  discovery, guest line endings, result pauses and the existing-drawer guard
  are checked on the host. These checks do not establish native app execution,
  BBS/network operation, hardware access or manual installer behavior. Native
  testing of these new bundles remains pending.

- Versions 1.6.14–1.6.15 add PrismRTG 1.1 and PrismNet 1.0.1. The maintainer's
  Amiga screenshot confirms successful PrismRTG extraction in 1.6.14 and the
  missing Amiga Installer message. Version 1.6.15 removes automatic setup and
  the Installer lookup, and adds an Enter pause after each Prism package.
  Windows PowerShell checks pass for package discovery, release hashes, archive
  members, LF scripts, extraction-only behavior, pause placement and source-update
  preservation. The installed 1.6.15 desktop startup check passed. Native testing
  of the new pauses and manual Prism setup remains pending.
- Version 1.6.16 updates the README, GUI/offline and CLI guides, package/update
  notes, creator acknowledgments and third-party inventory to describe this flow.

- Installer 1.6.12: read-only examination of an affected BestClassicWB image
  found Execute disabled on WBDock and several launcher targets, while compared
  payload bytes were unchanged. Adapter revision 2 adds a generated permission
  repair for 1,042 bundled HUNK files and refreshes older adapted packages.
  Host conversion/coverage/replacement checks passed. On October 19, 2026, the
  maintainer reported that the corrected test installation works, resolving
  the reported launcher issue in that test. Broader qualification remains
  outstanding. See [package notes](bestclassicwb-package.md).

- Installer 1.6.11 adds named settings/assigns profiles and additional-package drawer icon repairs. Windows PowerShell profile round-trip, overwrite, invalid input rejection, backup, cancellation, failure recovery, real discovery/UI refresh and INI persistence checks passed, as did the existing local-settings/package regression. Interactive file-picker testing and native Amiga drawer-icon validation remain pending.

- Installer 1.6.10 adds a reviewed BestClassicWB 2.1.12 adapter to the normal standard-package flow. Official live download, conversion, package detection, normal Run staging/execution generation, startup exclusion, repeat-download skip and invalid-upstream preservation passed. Native installation/boot and OS 3.2.3 compatibility remain pending; see [package notes](bestclassicwb-package.md).
- Installer 1.6.7 adds WHDLoad Packs archive progress/error handling and corrects ZIP discovery in the Windows pack builder. The first magazine archive passed a host integrity check; a three-format builder fixture passed. The reported native stall remains unresolved pending a fresh-image retest; see [WHDLoad Packs troubleshooting](whdload-pack-troubleshooting.md).
- Installer version: 1.6.6. Standard-package catalog discovery checks official GitHub releases; all 17 current packages downloaded and were recognized, followed by a repeat pass with zero downloads. Prerelease-to-stable fallback was reported explicitly.
- All 31 user packages are detected, including the eight additions in 1.6.5. Their payload/layout and source-update tests passed; native qualification is still pending below.
- EAB assign compatibility tests passed for Games/Demos AGA/OCS versions 3.1.2 and 3.2.0, including the new Beta-folder assigns.
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
