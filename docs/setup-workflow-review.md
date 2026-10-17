# Setup workflow review and AmigaOS 3.2.x integration

Reviewed October 16, 2026.

For the current acceptance result and remaining limits, see [validation status](validation-status.md). The chronological investigation notes below include superseded attempts.

## Existing user workflow

1. Start `setup.cmd` (or `setup.ps1`).
2. Configure Installer: select Install mode.
3. Configure image: create an image directory from a bundled template, or select an existing prepared image directory. Keep its `hstwb-image.json` and partitioned HDF together.
4. Configure Amiga OS: choose the media directory and OS set.
5. Configure Kickstart: choose the ROM directory and ROM set.
6. Configure packages and user packages as needed.
7. Configure emulator: select the installed WinUAE executable.
8. Run Installer from setup, or subsequently run `run.cmd` using the same settings directory.

Setup saves the selections through `WriteIniFile`. `RunInstaller` passes its settings directory directly to `run.ps1`; the image JSON defines the WinUAE disk mappings. Existing templates, ROM discovery, packages, and Amiga-side installation scripts remain the installation mechanism.

## Gap found and change

The modernization catalog grouped updates under the existing Amiga OS 3.2 set. Setup had no explicit patch-version choice. Runtime selected update state from detected release archives, which did not reflect a user-selected version and missed extracted update ADFs without those archives.

Configure Amiga OS now includes **Select Amiga OS 3.2 version**. It offers fresh-image targets supported by both the manifest and checksum-recognized disks: base 3.2, or base plus 3.2.1, 3.2.2, or 3.2.3. The chosen TargetVersion is saved in the existing settings file and shown in the settings summary. Selecting the 3.2 set or changing its media directory defaults to base 3.2; choose an update explicitly afterward.

Runtime uses the saved target to prepare only the base and chosen update, so other versions in the media directory are not silently installed. The existing 3.2.1 scripts still handle that release; 3.2.2 and 3.2.3 use the existing cumulative update entry point. Host state is written as BOM-free LF JSON for the Amiga-side reader. Settings without TargetVersion retain their prior behavior.

3.2.2.1 is not offered for a fresh image: it requires installed 3.2.2 and version.library 47.4. The current execution layer does not establish a fresh-image 3.2 -> 3.2.2 -> 3.2.2.1 sequence. Do not treat presence of both archives as proof that prerequisite was installed.

## Validation and outstanding acceptance

October 16 follow-up: base 3.2 native installation and Workbench boot now pass with the bundled DOS7 template, English-only media, and Turbo access. Forced LhA PURE residency caused the observed icon archive return failure in this configuration; loading LhA separately allowed both archives to return 0.

Review of the supplied 3.2.3 HowToInstall and Update disk installer confirmed that 3.2.3 accepts installed 3.2, 3.2.1, or 3.2.2. It also requires companion Classes, Extras, DiskDoctor, selected language and (for older ROMs) model modules. The former update-only implementation omitted these. Added checksum catalog rows for the supplied companion ADFs, dispatch through the original Adf-Template mechanism, and model-specific module installation. The selected-target planner now requires the core companion disks for 3.2.3. Other languages remain optional by media presence.

The 3.2.3 Startup-HardDrive is compressed `.Z`; fixed decompression and AmigaDOS quote escaping and preserved the HstWB boot hook. Update execution now returns to the enclosing normal installation for cleanup rather than quitting UAE before Install-Complete. Actual installed file versions are logged in INSTALLDIR:Temp/Update-Installed-Versions.log. Native acceptance of this new update path is in progress; regression checks pass (169 passed, 1 skipped).

Official announcement: https://www.hyperion-entertainment.com/index.php/news/1-latest-news/320-new-update-3-for-amigaos-32-available-for-download

Earlier validation notes below are historical and superseded where stated above.

- Synthetic PowerShell tests exercise the actual setup selector and saved-settings round trip, version-specific media isolation, missing/unverified update rejection, and unsupported fresh-image targets.
- Existing regression suite against changed source: 165 passed, 1 skipped.
- Actual setup menu exercised locally with supplied base media: selected 3.2 and verified persisted TargetVersion, image path, and ROM path. No emulator was started during this setup test.
- A previous local native run using the bundled 4GB template encountered `S-III Write 2 Error 148 on block 2892 + 2`. Its cause is unresolved; native installation/boot acceptance is still outstanding.
- End-to-end update installation and independent acceptance remain unverified. These host/setup checks do not establish successful native installs.
