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
| PrismRTG | 1.1, upstream interactive installer | `SYS:Tools/Hardware/PrismRTG` |
| PrismNet | 1.0.1, upstream interactive installer | `SYS:Tools/Network/PrismNet` |

Each package retains upstream release URLs, SHA256 hashes, license notices and corresponding-source links in `SOURCE.txt` and `LICENSE.txt`. Payloads come from the official repositories listed below. HstWB supplies the wrapper scripts; it does not claim authorship of these applications.

## Application behavior

- **xSysInfo:** installs the application, catalogs, documentation and bundled library. Installs `identify.library` into the system library directory only if absent. An existing library is retained; use the included upstream `Install` script to review replacement. MUI remains optional. Hardware SCSI checks are not enabled by this wrapper.
- **KickSmash:** copies Amiga utilities and documentation. Does not mount host volumes, change ROM banks, install a ROM module, or flash hardware.
- **DevTest / SDMAC:** copies tools for manual use. Does not run storage writes, register changes, controller resets or diagnostics during installation.
- **A4091 Tools:** copies utilities and guide from the official support ADF, plus the original ADF, device, ROM and exact source archive. The device is not activated and ROM programming remains manual. Its bundled DevTest is the support disk's version; the independent DevTest selection contains the newer standalone release. Disk/RDB modification commands require deliberate manual use.
- **ZZ9000 Firmware:** installs original ZIPs and separate `Variants` drawers. Each contains `BOOT.bin` and a sample `ZZ9000.CFG`. Pick the variant for the actual card/machine using upstream documentation. The wrapper does not flash the card or overwrite its existing configuration.
- **ZZ9000 Drivers:** installs the official `ZZ9000Installer` drawer. On the target machine, open it and double-click **Install ZZ9000**. That installer handles Picasso96, system components, network configuration and CPU-specific options. Reboot afterward. HstWB does not activate hardware drivers while preparing an image in WinUAE.
- **DOpus5:** launch `DirectoryOpus` from its drawer. The OS3 68000 build includes its library and modules. No Workbench replacement or WBStartup entry is installed by the wrapper.

## PrismRTG and PrismNet setup (1.6.15)

Select either package independently. HstWB extracts the complete original release
into its destination drawer, displays the result and pauses after each package
until you press Enter. HstWB does not look for or launch the Amiga Installer.
After HstWB finishes, open the drawer and run `Install_PrismRTG` or
`Install_PrismNet` to complete setup with the standard Amiga Installer.

PrismRTG requires Kickstart 3.1 or newer, a 68020 or better and a supported RTG
card. Its installer manages the Picasso96 backup, board selection, screen mode,
system commands, libraries, monitor launcher and preferences. PrismRTG and
Picasso96 cannot both be active.

PrismNet requires AmigaOS 3.1 or newer and a 68000 or better, with a suitable
network driver. Its installer asks for the connection settings, optional shares
and servers, and startup choices. It installs its libraries and commands into
the system and saves settings in `ENVARC:PrismNet`. Disable an existing TCP/IP
stack's startup before activating PrismNet.

When preparing an image in an emulator, complete hardware setup on the final
machine. Both original installers remain in their drawers.
Source update checks report compatibility review required for these packages;
automatic bundle replacement is disabled pending review of upstream changes.

Upstream: [PrismRTG](https://github.com/lainejones/PrismRTG) and
[PrismNet](https://github.com/lainejones/PrismNet). Release URLs, SHA256 hashes,
corresponding source links and GPL license text are included in each package.

## Missing drawers in Workbench

The wrappers previously created an icon for the final install drawer only.
`MakePath` also created parent drawers such as `Tools/Hardware` and
`Tools/Diagnostics`, without giving those parents `.info` files. Those parents
can hide the applications when Workbench shows icons only. Firmware's `Variants`
and board variant drawers had the same omission.

The updated wrappers add missing parent icons and firmware variant drawer icons,
using the installed default drawer icon when available. Existing icons are kept.
DevTest, SDMAC and A4091 Tools also receive the parent fix because they use the
same locations. Custom destination drawers receive an icon, but custom parent
paths outside the default hierarchy must be checked separately.

For an existing installation, copy `support/Repair-User-Package-Icons` to the
Amiga and run it from Shell, for example:

```text
Execute RAM:Repair-User-Package-Icons
```

This repairs existing hardware and diagnostic drawers at the default locations above,
including firmware variants and the official installer's default
`SYS:Utilities/ZZ9000` drawer. It copies the system default drawer icon, falling
back to `SYS:Tools.info`, and skips icons already present. It does not reinstall
applications or run the ZZ9000 installer. Reopen the Workbench windows afterward.
The script needs no HstWB-specific commands. If neither icon template exists,
it stops without changes.

For immediate access, use Workbench's **Window > Show > All Files** in each
affected parent window. The folder contents can then be reached while their
icons are repaired. This does not create permanent `.info` files.

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

Host checks cover detection of all ten selections, payload hashes, real LhA/ZIP layouts, LF guest scripts, catalog coverage, extract-only Prism behavior and results pauses, and raw/ZIP updater success and rejection paths. These checks do not establish native installation, launch behavior or real-hardware operation. Fresh-image Amiga testing remains required; no firmware flashing or destructive diagnostics were performed.
