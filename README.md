# hstwb-updated

## Download and run

**[Download Windows GUI ZIP](https://github.com/DavidZinAZ/hstwb-installer-updated/releases/download/desktop-preview/hstwb-gui-windows.zip)** · **[Download CLI ZIP](https://github.com/DavidZinAZ/hstwb-installer-updated/releases/download/desktop-preview/hstwb-cli.zip)** · [Release details and checksums](https://github.com/DavidZinAZ/hstwb-installer-updated/releases/tag/desktop-preview)

These links download ready-to-use packages. You do not need to find a build artifact or compile the GUI. This repository is private: sign in to a GitHub account with repository access before downloading. A 404 while signed out does not mean the file has been removed.

### Windows GUI

1. Click **Download Windows GUI ZIP** above and save **hstwb-gui-windows.zip**.
2. Right-click the ZIP and choose **Extract All…** into a writable folder.
3. Open the extracted **HstwbDesktop** folder and double-click **HstwbDesktop.exe**. Keep all supporting folders beside the EXE.
4. Follow the [GUI user guide](docs/gui/README.md). An offline edition opens from **Settings → Open GUI user guide**.

The GUI requires Windows with .NET Framework 4.8. The ZIP includes the compiled EXE, installer runtime, image templates, bundled user packages, and documentation. Each installation creates a fresh image in a new subfolder.

### CLI / original setup

1. Click **Download CLI ZIP** above and save **hstwb-cli.zip**.
2. Extract the entire ZIP into a writable folder and open its **HstwbCli** folder.
3. On Windows, double-click **setup.cmd** to configure the original installer, then **run.cmd** to run the saved configuration. **launcher.cmd** opens the original launcher.
4. Follow the separate [CLI setup documentation](docs/cli/README.md). Native run uses the image directory in its settings; it does not automatically create a fresh image as the GUI does.

The CLI package includes the original scripts and support files; it does not include the Windows desktop EXE. The instructions above describe its Windows entry points.

**For either download:** supply your own licensed AmigaOS media and Kickstart ROMs, an installed WinUAE or FS-UAE emulator, and any personal game/demo collections. Optional standard packages can be downloaded separately. Neither ZIP contains personal settings, commercial media, emulators, or personal game libraries. The GUI is an unsigned preview.

These download links update automatically after a successful build on master. If a build fails, the previous verified downloads remain available. See [Windows desktop builds](https://github.com/DavidZinAZ/hstwb-installer-updated/actions/workflows/windows-desktop.yml) for build progress. Branch and pull-request artifacts are separate testing snapshots.

An independently maintained continuation of **[HstWB Installer](https://github.com/henrikstengaard/hstwb-installer)**, created by **Henrik Nørfjand Stengaard**. Henrik built the original installer, AmigaDOS workflow, prepared image system, package framework, and documentation on which this project depends. Thank you, Henrik, and everyone who contributed to the original project.

This continuation is maintained by **[DavidZinAZ](https://github.com/DavidZinAZ)**. The new modernization work was developed by David with AI assistance, including **Scout (OpenAI Codex)** for code changes, investigation, documentation, and testing. These additions are our responsibility; they do not imply Henrik's involvement in or endorsement of this continuation.

The existing setup, media and ROM selection, bundled image templates, and installation process remain the foundation. See [changes and validation](CHANGELOG.md), [acknowledgments](ACKNOWLEDGMENTS.md), and [current test status](docs/validation-status.md). Internal `hstwb-installer` filenames are retained for compatibility.

See the [publication readiness report](docs/publication-readiness.md) and [privacy review](docs/privacy-review.md) before changing repository visibility. Historical private paths and component redistribution checks remain unresolved. The existing repository is not cleared for public release.

HstWB Installer is an application, which can automate installation of Amiga OS, Kickstarts roms and packages with additional content. 

Creating new harddrive images for Amiga and installing Amiga OS, Kickstart roms, ClassicWB, WHDLoad games and demos properly can be a cumbersome task unless you spend a lot of time figuring out how this is done step by step.

This is where HstWB Installer come to aid and can help simplifying installations and make it possible for almost anyone to do with very little knowledge about Amiga.

## Choose your interface and documentation

| Interface | Start here |
| --- | --- |
| Windows GUI — HstwbDesktop.exe | [Complete GUI user guide](docs/gui/README.md): every tab, fresh-image installation, packages, profiles, saved scans, and troubleshooting. An offline browser edition is included and opens from Settings. |
| Original CLI / script-based setup | [CLI documentation](docs/cli/README.md): original setup menus, launcher/run scripts, native profiles, and advanced workflows. |
| Desktop development and packaging | [Desktop build notes](desktop/README.md): source build, tests, portable ZIP, and automatic GitHub builds. |

The remaining setup instructions below describe the original interface. The GUI has its own controls and always creates a fresh image when using Run installation.

## Original setup basics

Use **Configure media library** in setup to select one parent folder for AmigaOS media and Kickstart ROMs. All subfolders are scanned; existing set/version selection and file views remain available. See [media library setup](docs/media-library.md).

Each installation now keeps its own files in `settings`. **Configure user packages → Update apps from sources** checks Aminet and original software sources for supported newer releases and retains backups. See [local settings and package updates](docs/settings-and-package-updates.md) for migration, version labels, supported behavior, and validation limits.

HstWB Installer comes with prepared image templates partitioned, formatted and ready to use for creating a new installation of Amiga OS. It supports automated installation of Amiga OS 3.2, 3.1.4 and 3.1 from floppy disks or adf files and Amiga OS 3.9 from cd-rom or iso file. 

Kickstart roms for WHDLoad are detected by checking rom file MD5 checksums and installed on Amiga system device along with Cloanto Amiga Forever rom key depending on rom files are encrypted or not. Afterwards additional content can be installed with packages and user packages. 

Packages simplifies installation of Workbench enhancements BetterWB, ClassicWB and HstWB together with demo and game launchers Amiga Games Selector 2, iGame and HstLauncher with screenshots and descriptions for each demo and game. BestClassicWB 2.1.12 is also available through the standard package list; see [requirements and experimental OS 3.2.3 integration](docs/bestclassicwb-package.md).

User packages simplifies installation of EAB WHDLoad demo and game packs and can be used for additional simple installations by copying files from host OS running HstWB Installer to various drawers in Amiga harddrive image.

A minimalistic approach is possible without installing any packages or user packages, which allows own installation of eg. MagicWB or Scalos Workbench enhancements.

HstWB Installer can create new images using install and build self install mode. Install mode installs selected Amiga OS, Kickstart roms, packages and user packages ready for use. Build self install mode builds a self install image with selected packages. 

Running a self install image detects and installs provided Amiga OS and Kickstart roms. Afterwards packages and user packages can be selected and installed making the image ready for use. 

Both install and self install uses the same installation process, which is written in AmigaDOS scripts and uses binaries for 68000 CPU to support as many Amiga models as possible. HstWB Installer uses WinUAE or FS-UAE emulator to run the installation process.

## Licensed files required

Amiga OS and Kickstart roms are licensed property and still sold commercially. Therefore use of HstWB Installer requires Amiga OS and Kickstart roms files, floppy disks or cd-roms, which can be bought legally from Cloanto Amiga Forever, Hyperion Entertainment and online Amiga stores. 

It's also possible to dump required files on a real Amiga using tsgui to dump Amiga OS floppy disks to adf files and grabkick to dump Kickstart roms to rom files. Both tsgui and grabkick can be downloaded from http://aminet.net.

## Background

HstWB Installer started as a Workbench enhancement called HstWB and evolved into an idea about how prepared Amiga harddrive images ready for use could be shared publically for download without licenced Amiga OS and Kickstart roms files. 

This formed a solution similar to ClassicWB, where a prepared Amiga harddrive image can be started and install required Amiga OS files during it's first time startup. 

Within short time this turned into a configurable way of automating installation of Amiga OS 3.1 and Kickstart roms used for WHDLoad. 

To give users the choice of installing additional content on a freshly installed Amiga OS, the packages concept was introduced. Then WHDLoad demo and game launcher packages with screenshot was added together with various versions of the very popular ClassicWB and BetterWB Workbench enhancements.

The original name "HstWB" comes from Henrik Nørfjand Stengaard. The original project's history and authorship are preserved in this continuation; visit [Henrik's original project](https://github.com/henrikstengaard/hstwb-installer) for his work.

# License

The installer source is licensed under the [MIT license](LICENSE.txt).
Bundled third-party software, firmware, fonts and artwork retain their own
licenses; see [third-party notices](THIRD_PARTY_NOTICES.md). The MIT license does
not grant redistribution rights over commercial AmigaOS or Kickstart media.

For contributions and redacted bug reports, see [CONTRIBUTING.md](CONTRIBUTING.md).
For sensitive reports, see [SECURITY.md](SECURITY.md).

# Requirements

The minimum requirements for running and using HstWB Installer are:

* Windows 7, 8, 8.1 or 10.
* WinUAE or FS-UAE Amiga emulator.
* Amiga OS and Kickstart rom files from Cloanto Amiga Forever or own dumps from real Amiga.

The minimum requirements for running self install images are:

* WinUAE, FS-UAE, Amiberry, UAE4ARM or similar Amiga emulator.
* Amiga OS and Kickstart rom files from Cloanto Amiga Forever or own dumps from real Amiga.

# Documentation, installation, quickstarts and tutorials

HstWB Installer GitHub Wiki contains documentation and details about installation, quickstarts and tutorials using HstWB Installer.

Please start by reading [How to use HstWB Installer](https://github.com/henrikstengaard/hstwb-installer/wiki/How-to-use-HstWB-Installer) for a quickstart about how to use HstWB Installer.

## Additional user packages

Version 1.6.5 adds xSysInfo, KickSmash, DevTest, SDMAC, A4091 Tools, ZZ9000 Firmware/Drivers and DOpus5. See [destinations, installation and validation notes](docs/additional-user-packages.md).
