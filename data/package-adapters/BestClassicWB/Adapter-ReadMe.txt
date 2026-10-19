BestClassicWB 2.1.12 for HstWB Installer

Upstream: https://github.com/kouts/best-classic-wb
Author: kouts/samplist. Thanks to Bloodwych for ClassicWB, Gulliver for
BestWB and KKR75 for icons. Bundled software retains its original notices.
The HstWB Installer is originally by Henrik Noerfjand Stengaard:
https://github.com/henrikstengaard/hstwb-installer
Adapter by DavidZinAZ with Scout (OpenAI Codex).

Use as an alternative to BestWB, BetterWB and ClassicWB, on a clean system.
Upstream requires an accelerated AGA Amiga with RAM and OS 3.2.2.1.
OS 3.2.3 integration is experimental and native testing is pending.

The adapter installs to SYSTEMDIR: through the normal package flow. It does
not relabel the system volume or run the original interactive BCWB script.
It assigns OS3.2: to SYS: at boot for upstream background/player preferences.
It preserves the selected OS Startup-Sequence and adds FBlit/FText,
TitleShadow and FPPrefs hooks. Upstream user startup is appended once.
Base startup files and icon.library are backed up with .BCWB-Base suffixes.
The supplied upstream startup and installer are retained for reference.

Automatic conversion is pinned to the reviewed 2.1.12 archive SHA256.
Future releases require adapter review before being offered for download.

HstWB adapter revision 2 restores Execute permission on every bundled Amiga
HUNK executable/library after ZIP extraction, including WBDock and the apps
it launches. The upstream ZIP stores these files without Unix execute bits.
Older adapted installations can therefore display the dock but fail to launch
programs. Application file contents have not been removed or replaced.

For an existing installation, copy Repair-Executable-Protection to an Amiga
readable location and run it with the target volume, for example:
  Execute RAM:Repair-Executable-Protection SYS:
The script only changes Execute permission on existing bundled HUNK paths.
It does not reinstall programs, overwrite preferences or modify startup files.
