# Additional user packages

Select these independently in **Configure user packages â†’ Select user packages**. Point **Change user packages dir** at this installation's `user-packages` directory if settings still reference an older portable copy. Existing selections are not changed automatically.

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

## Additional application bundles (1.6.17)

These selections use the same extraction-only flow as the Prism packages. HstWB
copies the original release files into the chosen Amiga drawer, displays setup
instructions and waits for Enter after each package. Application setup, startup
entries, services, library replacement and device operations remain manual.
If a destination already contains `Upstream-README.txt`, HstWB retains that drawer
without overwriting it; use the original project's update procedure for an
existing installation. Each bundle includes the full upstream readme, release
hashes, source links and retained license/attribution notices.

| Package | Release | Default Amiga drawer |
|---|---|---|
| NetHarness | 1.18 | `SYS:Tools/Network/NetHarness` |
| NilBBS | 1.5.2 | `SYS:Tools/Network/NilBBS` |
| AmiFM | 1.2 | `SYS:Utilities/AmiFM` |
| NilTerm | 1.5.1 | `SYS:Tools/Network/NilTerm` |
| AmiDT | 1.0 | `SYS:Tools/Hardware/AmiDT` |
| SCSIToolbox-Amiga | 1.8.2 | `SYS:Tools/Hardware/SCSIToolbox` |
| NoClick | 1.0.1 | `SYS:Tools/Hardware/NoClick` |
| AmiTime | 1.1.1 | `SYS:Tools/Network/AmiTime` |
| AmiSSL-Tunnel | 2.0.1 | `SYS:Tools/Network/AmiSSL-Tunnel` |

- **NetHarness:** OS 3.0+, 68020+ and TCP/IP. Run `Execute Install` in its drawer,
  then start it manually. The original `NetHarness-1.18-PC.zip` is copied beside
  the Amiga files; transfer it to the controlling PC and follow its Python/Tk/
  Pillow instructions. Configure `NetHarness.allow` before starting the listener:
  without an allowlist, any connecting host is accepted.
- **NilBBS:** OS 3.1+, 68020+ and TCP/IP. Run `Install_NilBBS`; configure your
  sysop account, port and access settings before starting the BBS. The upstream
  installer manages existing BBS settings, users and messages on updates.
- **AmiFM:** Workbench 3.0+. Open `AmiFM` directly. Optional features need
  MultiView/datatypes, an editor, XAD tools or LhA; HstWB does not install these
  helpers automatically. Upstream v1.2 has no explicit redistribution license;
  its included notice records that limitation rather than assigning a license.
  Public downloads include its wrapper and instructions, with the archive
  supplied separately: download `AmiFM-1.2.lha` from the upstream release and
  place it in the Windows `user-packages/AmiFM` folder before building an image.
  Your local copy may already contain the verified archive.
- **NilTerm:** run `Install_NilTerm` or open `NilTerm/NilTerm`. Configure TCP/IP
  or serial/modem settings for the intended connection. NilBBS includes a separate
  NilTerm copy; both bundles are independent. Retain its IBM VGA font credits.
- **AmiDT:** OS 3.0+, 68020+. Run `Install_AmiDT` to choose picture datatypes and
  review existing system/RTG compatibility. Its installer handles backups and
  removal; reboot after replacing active system datatypes.
- **SCSIToolbox-Amiga:** CLI/sharedfs need OS 2.04+; the GUI tools need OS 3.5+
  ReAction V44 classes. The supplied programs target 68000+. Configure your SCSI
  device/unit and compatible BlueSCSI V2 or ZuluSCSI before use. Mounting volumes,
  copying a handler into `L:` and hardware operations are manual.
- **NoClick:** Kickstart 2.0+. Follow `README.md` to copy the Shell command to
  `C:` and optionally add it to startup. HstWB does not run it or edit startup.
- **AmiTime:** OS 2.0+, 68000+, TCP/IP and a reachable NTP server. Run
  `Execute Install`; choose the timezone and startup behavior. Its 1.1.1 package
  contains a binary reporting 1.1. Avoid duplicate clock-setting startup tasks
  if PrismNet or another stack already sets your time.
- **AmiSSL-Tunnel:** OS 2.04+, 68000+ and TCP/IP, plus a Python 3 daemon on a
  separate LAN computer. Follow `README.md` and then run `Installer Install`.
  Upstream setup backs up/replaces AmiSSL libraries. The Amiga-to-daemon hop is
  plaintext; use a trusted LAN. HstWB does not start or install the host daemon.

Source checks report **Compatibility review required** for these bundles.
This does not prevent selecting the local bundle for installation; it prevents
automatic replacement of its files with an unreviewed upstream layout.

## Network and filesystem additions (1.6.20)

Six independently selectable bundles use the extraction-only flow and existing-drawer protection described above. Setup remains manual on the target Amiga. Each bundle retains its original archive, SHA256, upstream readme, source links and license notices. Source updates require compatibility review.

### AmiNetXDuo

Default Amiga drawer: SYS:Tools/Network/AmiNetXDuo (customizable).

Release candidate. OS 2.04+, 68000+, 1 MB RAM and a SANA-II network driver. Choose Full, Minimal or Micro using the upstream installer. Disable the startup of PrismNet, Roadshow, AmiTCP or another stack before activating this stack. Configure networking on the final machine. WebDAV, web server, browser Shell and remote screen services are optional; review access settings before enabling them.

Run Install-AmiNetXDuo from this drawer.

### AmiNFSv3

Default Amiga drawer: SYS:Tools/Network/AmiNFSv3 (customizable).

Beta. OS 2.04+, 68000+ and a TCP/IP stack providing bsdsocket.library V4. Configure the Linux/NAS NFSv3 export, server address, export path and UID/GID before mounting. Start with a test share and verify read/write behavior. Keep the example DOSDriver in Storage until configured. Files up to 4 GB; some AmigaDOS programs misreport sizes above 2 GB.

Follow AmiNFSv3.doc to install the handler and configure NFS0.

### TheWire13

Default Amiga drawer: SYS:Tools/Network/TheWire13 (customizable).

Specialist OS 1.3 networking option. OS 1.3+, 68000+ (68020 recommended), a SANA-II driver and RAM for network buffers. Socket compatibility is incomplete and evolving. Disable any other TCP/IP stack before activation; do not overwrite its bsdsocket.library blindly. This archive includes thewire13.conf and mini_ntp.conf, but no amitcp13.hosts despite the upstream copying instructions.

Follow Upstream-README.txt for manual copying and configuration.

### CFD Modern

Default Amiga drawer: SYS:Tools/Hardware/CFDModern (customizable).

Modern fork of CFD133. Bundle 20261007 contains compactflash.device 2.1 and ptable.library 2.2. Requires A600/A1200 PCMCIA, OS 2.0+, suitable adapter and Installer 43.3+ for the installer. Install FAT95 Modern separately for FAT media. Both modern packages include ptable.library 2.2: retain matching CPU/flavor versions. Choose either legacy CompactFlash and FAT95 setup or the modern pair; do not run both setups over one another. The upstream Expert installer can edit User-Startup/LoadModule; ROM autoboot is a separate manual operation. Do not force transfer flags without card testing.

Run Install, then Setup from this drawer on the target A600/A1200.

### FAT95 Modern

Default Amiga drawer: SYS:Tools/Hardware/FAT95Modern (customizable).

Modern fork of fat95. Bundle 20261007 contains fat95 4.1 and ptable.library 2.2. OS 1.3+ (2.0+ for full functionality), a suitable block device, and Installer 43.3+ for the installer. ptable.library is required for partition auto-detect; explicit geometry does not need it. Shared library guidance: see CFD Modern; choose matching CPU/flavor versions. Keep the legacy CompactFlash and FAT95 package as an alternative. The Expert installer can edit LoadModule startup. Raw disk tools such as dd and boot95 remain manual; use test media when evaluating read/write behavior.

Run Install from this drawer; use Language to change the installed language.

### ODFileSystem

Default Amiga drawer: SYS:Tools/Hardware/ODFileSystem (customizable).

OS3 release v0.8.0; keep the 68000 and 68020 variants and follow the upstream CPU guidance. Read-only optical filesystem, not a writable hard-disk filesystem. Configure device and unit for the actual drive. Preserve existing CD0 settings and use only one active DOSDriver per device name. No handler is copied into L: and no CD volume is mounted by HstWB. ROM/test binaries are supplied for manual use only.

Follow README.md to install L:ODFileSystem and create a DOSDriver.

### Amelinium (1.6.24)

Amelinium 1.4.0 is independently selectable under Network & Communications.
Default drawer: `SYS:Tools/Network/Amelinium`. The complete original archive,
including Emalinium and all platform builds, uses the standard extraction-only
flow, existing-drawer protection and Enter pause. No separate download is needed.
Open the executable for your CPU after HstWB finishes. Classic builds require
bsdsocket.library V4+ and AmiSSL v5 for HTTPS; 040/060 variants require an FPU.

This release does **not verify TLS server certificates**, including mail
connections. Avoid sensitive credentials. The package description, installation
message and ReadMe retain this limitation. No explicit application redistribution
license was found; LICENSE.txt records this without assigning a license and
retains references to the bundled third-party notices. Source updates require
compatibility review.

Upstream: [Amelinium](https://aminet.net/package/comm/www/Amelinium).

## XPKGuide (1.6.29)

Select **XPKGuide** under **Files & Archives**. The complete original 1.9
archive is bundled and extracted to `SYS:Utilities/XPKGuide`, with the usual
Enter pause and protection for an existing drawer. Launch `XPKGuide` directly;
use its original `Install` script for optional setup. HstWB does not copy its
historical libraries into LIBS: or change document associations.

Requires Kickstart 2.04+ and amigaguide.library V34+. Decompressed documents
need temporary space in T:. XPK formats require the matching compressor
sublibrary; CrM.library is not supplied. Retain newer working XFD/XPK libraries.
The upstream guide's 1.9 history removes built-in PCompress support despite
the older Aminet readme; XFD support is needed for that format. The manual
also names InstallLibs, while the actual archive supplies `Install`.

The original unmodified archive and AFD-COPYRIGHT are retained. It is Mailware:
the author requests a message from users; no messages are sent by HstWB.
Version 1.9 is verified from the executable. Since the Aminet readme has no
Version field, updates are manual. [Upstream XPKGuide](https://aminet.net/package/text/hyper/XPKGuide).

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
- [PrismRTG](https://github.com/lainejones/PrismRTG), by Laine Jones, Stefan Reinauer and contributors
- [PrismNet](https://github.com/lainejones/PrismNet), by Laine Jones and contributors, using the lwIP networking core
- [NetHarness](https://github.com/lainejones/NetHarness)
- [NilBBS](https://github.com/lainejones/NilBBS)
- [AmiFM](https://github.com/lainejones/AmiFM)
- [NilTerm](https://github.com/lainejones/NilTerm)
- [AmiDT](https://github.com/lainejones/AmiDT)
- [SCSIToolbox-Amiga](https://github.com/lainejones/SCSIToolbox-Amiga), a fork of Paul Hill's BlueSCSI-toolbox-Amiga
- [NoClick](https://github.com/lainejones/NoClick)
- [AmiTime](https://github.com/lainejones/AmiTime)
- [AmiSSL-Tunnel](https://github.com/lainejones/AmiSSL-Tunnel)

## Validation scope

Host checks cover detection of all twenty-seven maintained additions, payload hashes, real LhA/ZIP layouts, LF guest scripts, catalog coverage, extract-only Prism behavior and results pauses, and raw/ZIP updater success and rejection paths. These checks do not establish native installation, launch behavior or real-hardware operation. Fresh-image Amiga testing remains required; no firmware flashing or destructive diagnostics were performed.
