# BestClassicWB package

BestClassicWB appears under **Configure packages → Select packages**, alongside BestWB, BetterWB and ClassicWB. It is a standard package, not a user package. Use **Update packages → Download latest packages** to download and convert the official release, then select **BestClassicWB v2.1.12** and run the installer normally.

## Source and requirements

The reviewed upstream release is [BestClassicWB 2.1.12](https://github.com/kouts/best-classic-wb/releases/tag/v2.1.12), by kouts/samplist. Its [instructions](https://github.com/kouts/best-classic-wb#requirements) specify a clean AmigaOS 3.2.2.1 installation on an accelerated AGA Amiga with additional RAM. The installer package uses the existing `3.2` family filter; this is not a claim that every 3.2 release or machine is qualified. **AmigaOS 3.2.3 integration is experimental and native testing is pending.**

Select this desktop as an alternative to the other Workbench bundles. Its `amigaos` content ID participates in the same selection/conflict handling as BestWB and ClassicWB. Do not combine desktop bundles in an install-all run. Hardware requirements still apply; the family filter does not check the actual Amiga hardware.

## Installation behavior

The original release ZIP has no HstWB manifest. The downloader verifies its SHA256, builds a normal HstWB package and validates it before replacing an existing package. Existing valid packages are retained on failure. The adapter is pinned to the reviewed 2.1.12 archive; future upstream releases need review before conversion. Standard packages from Henrik's repositories keep their existing update behavior.

The adapted package installs to `SYSTEMDIR:`, the selected Amiga system volume. Programs retain the upstream drawer layout. The adapter performs the upstream datatype/commodity adjustments, installs its files, and adds FBlit/FText, TitleShadow and FPPrefs startup hooks. It preserves the selected OS Startup-Sequence instead of copying the older upstream one over it, appends upstream user-startup once, and does not relabel the volume. Base startup files and icon.library use `.BCWB-Base` backup suffixes. Original upstream installer/startup sources and source information remain in the package; help is copied to `Locale/Help/BestClassicWB`.

Use a **fresh bundled hard-disk image for every native test**. Confirm installation completion, reboot, check that the selected OS version remains intact, and exercise the desktop/startup programs before treating the combination as supported. Copying files into a running installation does not replace its staged scripts.

Upstream background and EaglePlayer preferences refer to `OS3.2:`. A boot-time assign maps that name to `SYS:` without renaming the system volume.

## Attribution

Thanks to kouts/samplist for BestClassicWB, Bloodwych for ClassicWB, Gulliver for BestWB and KKR75 for icons. Bundled software retains upstream notices. HstWB Installer was created by [Henrik Nørfjand Stengaard](https://github.com/henrikstengaard/hstwb-installer). The adapter was added by DavidZinAZ with Scout (OpenAI Codex). Upstream payloads are downloaded from their original release and are not committed to this continuation repository.
