# Acknowledgments and project lineage

## Original project

**Henrik Nørfjand Stengaard** created [HstWB Installer](https://github.com/henrikstengaard/hstwb-installer). This continuation builds directly on his installer architecture, AmigaDOS scripts, prepared hard-drive templates, package and user-package framework, media recognition, emulator integration, and documentation.

Thank you, Henrik, for the years of work that made installing and configuring Amiga systems more accessible. The original project and its contributors deserve credit for that foundation. Existing contributor names, source headers, copyright notices, and Git history remain in place.

- [Original source repository](https://github.com/henrikstengaard/hstwb-installer)
- [Original documentation and tutorials](https://github.com/henrikstengaard/hstwb-installer/wiki)
- [Original MIT license and copyright notice](LICENSE.txt)

## Thank you to the original software creators

HstWB Installer brings together decades of work by Amiga programmers, artists,
hardware developers, documentation writers and community maintainers. Thank
you to the people who created these tools, shared their knowledge and kept
improving them. The installation scripts are only one part of what makes a
working Amiga system possible; the applications and components themselves
deserve their own recognition.

| Software or contribution | Thanks to |
|---|---|
| Workbench distributions and desktop bundles | **Bloodwych** for ClassicWB, **Gulliver** for BestWB and BetterWB, **kouts/samplist** for [BestClassicWB](https://github.com/kouts/best-classic-wb), and their contributors. See the [BestClassicWB attribution notes](docs/bestclassicwb-package.md#attribution). |
| WHDLoad and its individual game/demo installers | **Bert Jahn (Wepl)** for [WHDLoad](https://www.whdload.de/), the authors of its individual installers and patches, and the people maintaining the collections and menus used by the packages. |
| Amiga emulation | The original UAE developers and the developers and contributors behind WinUAE, FS-UAE and the other emulator integrations used by HstWB. |
| Directory Opus | **Jonathan Potter**, **GP Software**, and the Directory Opus 4 and [Directory Opus 5](https://github.com/BlitterStudio/dopus5) open-source contributors. |
| System information and hardware diagnostics | **Stefan Reinauer** and the [xSysInfo contributors](https://github.com/reinauer/xSysInfo), **Chris Hooper** for [DevTest](https://github.com/cdhooper/amiga_devtest) and [SDMAC Test](https://github.com/cdhooper/amiga_sdmac_test), and the Amiga Test Kit and SysInfo authors and contributors. |
| KickSmash and A4091 support | **Chris Hooper** and the [KickSmash contributors](https://github.com/cdhooper/kicksmash32), and **Stefan Reinauer**, **Chris Hooper** and the [A4091 contributors](https://github.com/A4091/a4091-software). |
| ZZ9000 hardware support | The **MNT**, **BlitterStudio** and wider ZZ9000 contributors behind the [drivers](https://github.com/BlitterStudio/zz9000-drivers), [firmware](https://github.com/BlitterStudio/zz9000-firmware), tools and documentation. |
| Libraries, filesystems and everyday utilities | The original authors and maintainers of MUI, MMU libraries, icon.library, Picasso96, PFS3, FAT95, KingCON, archivers, datatypes and the many command-line helpers used throughout the installer and its packages. |
| Icons, artwork and desktop tools | **KKR75** for icons credited by BestClassicWB, and the artists and developers behind the included themes, icon sets, palettes, VisualPrefs, MagicMenu, WBDock, iGame and other desktop additions. |
| AmigaOS, Workbench and Kickstart | The original Amiga hardware and operating-system teams, and the developers and vendors who have continued maintaining and supplying Amiga system software. |

This is a growing acknowledgment, not a complete list of every contributor.
Package readmes, source headers, licenses and upstream project credits provide
the more detailed attribution. Those notices remain with their respective
components; this page supplements them. Additional user-package sources are
listed in the [package notes](docs/additional-user-packages.md#upstream-projects).
If a person or project is missing or miscredited, please open an issue so the
acknowledgments can be corrected.

## This continuation

**DavidZinAZ** maintains hstwb-updated, directs its modernization, supplies the licensed test environment and media, and reviews the resulting behavior.

**Scout (OpenAI Codex)** assisted David with implementation, debugging, repository recovery, documentation, regression checks, and native WinUAE testing. AI is a development tool in this project; responsibility for the continuation remains with its human maintainer. AI assistance is not a claim of authorship over Henrik's original work.

Earlier modernization commits also record **Case (software-engineer)** and **Hannibal (project-planner)** as AI team members. Their recorded contributions include release-manifest and update execution work, media catalogs, planning, and qualification documentation. These names identify development agents, not additional human maintainers.

Other contributors remain credited through the original history and file-level notices. Additional team members will be named when their identities and contributions are documented.

This continuation is independent and does not imply endorsement by Henrik, Hyperion Entertainment, or other original contributors and vendors.

## Software and community

Thanks to the WinUAE developers, the authors of the utilities and packages used by HstWB Installer, the Amiga community, and the vendors who continue supporting Amiga software. Third-party components retain their own attribution and licensing terms. Commercial AmigaOS and Kickstart media must be supplied by the user; this repository update does not include the licensed test media or completed installation disks.
