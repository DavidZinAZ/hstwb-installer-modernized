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

## Dock icons do not launch applications

Installer 1.6.12 introduces adapter revision 2 for the same upstream 2.1.12
release. A read-only examination of an affected installed image found Execute
permission disabled on WBDock, SnoopDos, Directory Opus, iGame and other bundled
programs. Their bytes still matched the payload. The upstream files are stored
with Unix mode 0644; the previous adapter restored Execute permission on only
FBlit, FText and FPPrefs after ZIP extraction.

The revised adapter generates a permission-repair script from the actual HUNK
headers in the pinned archive and executes it after extraction. It covers
1,042 bundled HUNK program/library files, adding Execute permission only to
paths that exist. It does not mark configuration or text files executable.
The downloader recognizes the adapter revision and replaces revision 1 even
though the upstream version is unchanged.

For an existing image, copy
`support/Repair-BestClassicWB-Executables` to a location readable inside the
Amiga, for example `RAM:`, then run in Amiga Shell:

```text
Execute RAM:Repair-BestClassicWB-Executables SYS:
```

Reboot and retest the dock. The script changes only Execute permission on the
known existing payload paths, preserving programs, preferences and startup
files. Updated installs also retain it at
`SYS:Locale/Help/BestClassicWB/Repair-Executable-Protection`.

Host checks cover permission-script coverage, payload preservation and refresh
of old adapter revisions. On October 19, 2026, the maintainer reported that the
corrected test installation works. This records resolution of the reported
launcher issue in that test; broader application and hardware qualification
remains outstanding.

## Attribution

Thanks to kouts/samplist for BestClassicWB, Bloodwych for ClassicWB, Gulliver for BestWB and KKR75 for icons. Bundled software retains upstream notices. HstWB Installer was created by [Henrik Nørfjand Stengaard](https://github.com/henrikstengaard/hstwb-installer). The adapter was added by DavidZinAZ with Scout (OpenAI Codex). Upstream payloads are downloaded from their original release and are not committed to this continuation repository.
