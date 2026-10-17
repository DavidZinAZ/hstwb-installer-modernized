# Additional user packages in 1.6.5

Select these independently in **Configure user packages → Select user packages**. Point **Change user packages dir** at this installation's `user-packages` directory if settings still reference an older portable copy. Existing selections are not changed automatically.

The installer uses the existing user-package assigns and destination selection. Defaults:

| Selection | Bundled software | Default Amiga destination |
|---|---|---|
| xSysInfo | 0.12.0 | `SYS:Tools/Diagnostics/xSysInfo` |
| KickSmash | 2.0 Amiga utilities | `SYS:Tools/Hardware/KickSmash` |
| DevTest | 1.9 | `SYS:Tools/Diagnostics/DevTest` |
| SDMAC | 1.1 | `SYS:Tools/Diagnostics/SDMAC` |
| A4091 Tools | 42.39 support disk, extracted tools, driver and ROM | `SYS:Tools/Hardware/A4091` |
| ZZ9000 Firmware | 2.8.1, all seven published variants | `SYS:Tools/Hardware/ZZ9000/Firmware` |
| ZZ9000 Drivers | 2.8.1 official installer and payload | `SYS:Tools/Hardware/ZZ9000` |
| DOpus5 | 5.102 OS3 68000 build | `SYS:Utilities/DOpus5` |

Each package retains upstream release URLs, SHA256 hashes, license notices and corresponding-source links in `SOURCE.txt` and `LICENSE.txt`. Payloads come from the official repositories listed below. HstWB supplies the wrapper scripts; it does not claim authorship of these applications.

## Application behavior

- **xSysInfo:** installs the application, catalogs, documentation and bundled library. Installs `identify.library` into the system library directory only if absent. An existing library is retained; use the included upstream `Install` script to review replacement. MUI remains optional. Hardware SCSI checks are not enabled by this wrapper.
- **KickSmash:** copies Amiga utilities and documentation. Does not mount host volumes, change ROM banks, install a ROM module, or flash hardware.
- **DevTest / SDMAC:** copies tools for manual use. Does not run storage writes, register changes, controller resets or diagnostics during installation.
- **A4091 Tools:** copies utilities and guide from the official support ADF, plus the original ADF, device, ROM and exact source archive. The device is not activated and ROM programming remains manual. Its bundled DevTest is the support disk's version; the independent DevTest selection contains the newer standalone release. Disk/RDB modification commands require deliberate manual use.
- **ZZ9000 Firmware:** installs original ZIPs and separate `Variants` drawers. Each contains `BOOT.bin` and a sample `ZZ9000.CFG`. Pick the variant for the actual card/machine using upstream documentation. The wrapper does not flash the card or overwrite its existing configuration.
- **ZZ9000 Drivers:** installs the official `ZZ9000Installer` drawer. On the target machine, open it and double-click **Install ZZ9000**. That installer handles Picasso96, system components, network configuration and CPU-specific options. Reboot afterward. HstWB does not activate hardware drivers while preparing an image in WinUAE.
- **DOpus5:** launch `DirectoryOpus` from its drawer. The OS3 68000 build includes its library and modules. No Workbench replacement or WBStartup entry is installed by the wrapper.

## Updates

**Update apps from sources** checks official GitHub stable releases. xSysInfo, KickSmash, DevTest, SDMAC and DOpus5 support local package updates with baseline hashes, archive-member/file-format validation, preserved custom files and backups. CPU/platform and asset patterns are explicit; DOpus5 remains on the OS3 68000 build.

A4091 and both ZZ9000 bundles report **Compatibility review required**. A4091's extracted tools must be regenerated together with its support disk. ZZ9000 drivers and firmware must remain matched, and firmware board variants must be chosen deliberately. These bundles are not independently replaced by the automatic updater.

## Upstream projects

- [xSysInfo](https://github.com/reinauer/xSysInfo)
- [KickSmash32](https://github.com/cdhooper/kicksmash32)
- [Amiga DevTest](https://github.com/cdhooper/amiga_devtest)
- [Amiga SDMAC Test](https://github.com/cdhooper/amiga_sdmac_test)
- [A4091 software](https://github.com/A4091/a4091-software)
- [ZZ9000 firmware](https://github.com/BlitterStudio/zz9000-firmware)
- [ZZ9000 drivers](https://github.com/BlitterStudio/zz9000-drivers)
- [DOpus5](https://github.com/BlitterStudio/dopus5)

## Validation scope

Host checks cover detection of all eight selections, payload hashes, real LhA/ZIP layouts, LF guest scripts, catalog coverage, and raw/ZIP updater success and rejection paths. These checks do not establish native installation, launch behavior or real-hardware operation. Fresh-image Amiga testing remains required; no firmware flashing or destructive diagnostics were performed.
