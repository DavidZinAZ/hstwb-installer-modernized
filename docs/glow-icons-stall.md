# Glow Icons archive stall — October 16, 2026

## Fresh-run result

Run `20261016-033059-1ea87149` completed the native AmigaOS 3.2 installation after removing forced LhA PURE residency. Classic archiving added 195 files and returned 0; Glow archiving added 199 files and returned 0. MMULibs and finalization followed. The final completion prompt appeared, WinUAE exited through the installer, and the host runner exited 0 at 03:40:52. This verifies the workaround for this A1200, English-only, bundled DOS7 baseline; other targets still need native acceptance.

The first subsequent boot check encountered the previously observed intermittent Workbench write-protection request. Windows continued reporting a sharing lock after WinUAE closed. Preserved the completed original and copied its HDF into this run's `boot-check` directory; the copy passed sustained exclusive-write preflight and booted successfully to Workbench with Workbench and Work volumes visible. Boot output is captured in `logs/boot-stdout.txt`. The host sharing-lock cause remains unresolved.

Run: `.output/local-tests/20261016-031154-e45170d7`.
Fresh bundled 2GB DOS7 image; AmigaOS 3.2, A1200 selected, English-only locale media, Turbo floppy speed. Optional Glow Icons replacement was declined.

## Confirmed evidence

The native installation reached Glow Icons after copying the base OS disks. The host-mounted progress log contains:

```
Starting icon cleanup
Icon cleanup returned
Starting classic icon archive
Classic icon archive returned
Starting Glow Icons archive
```

At 03:19–03:21 local time the screen still showed `Glow Icons: archiving Glow Icons...`, and the HDF timestamp remained 03:17:59. Emulated CPU activity continued. No completion marker was present.

The last command entered is:

```
Lha -q -e -r -x a "SYSTEMDIR:Icons/GlowIcons/GlowIcons.lha" "$amigaosdisk:" #?.info
```

`$amigaosdisk` is the installer's virtual FF0 disk. The classic archive command against SYSTEMDIR returned; the equivalent Glow Icons command against FF0 has not returned. This isolates the observed stall to that archive command, but does not yet distinguish compression cost, a specific input file, or virtual-disk traversal behavior.

Declining Glow Icons only skips extracting the new icons over the installed system. The existing script still builds both icon archives for later switching. No bypass has been introduced.

## Next fresh-run diagnostics

The detailed run `20261016-032242-6d6fad3d` narrowed the failure further. Classic archiving returned code 0 with 195 files OK. Glow archiving reported 199 files OK and `Operation successful.` in its output, but the following return-code log line never executed. Thus the observed problem is after compression, while the command has not returned; it is not established as a damaged input file.

`amiga/install/S/Start-Install` force-loaded LhA with `Resident ... PURE`. Next experiment removes that forced residency so each invocation loads a fresh executable through the existing C: search path. This is a hypothesis under test, not a confirmed fix. Archive commands and contents are preserved.

The source now removes LhA's quiet flag for archive creation and redirects its detailed output to host-mounted files:

- `INSTALLDIR:Temp/ClassicIcons-Archive.log`
- `INSTALLDIR:Temp/GlowIcons-Archive.log`

It also records each archive's return code immediately upon return in `GlowIcons-Progress.log`. These changes apply only to a future fresh-image test; the current staged script is unchanged. Inspect the last archived filename and any warnings before deciding on a compression or virtual-floppy workaround. Do not mark installation accepted while this command has not completed.
