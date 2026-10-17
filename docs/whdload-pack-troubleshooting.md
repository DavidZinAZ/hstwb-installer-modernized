# WHDLoad Packs installation progress

Installer 1.6.7 updates the shared `InstallEntry` script used by generated WHDLoad Packs. The WHDLoad application package has a separate install script.

The reported stall was at **EAB WHDLoad Magazines → Installing 0-9, AGA, EN**. The first selected archive, `42Issue1_v1.0_Talent_AGA.lha`, passed a complete host-side archive integrity check. This does not prove the native installation succeeds or establish the cause of the stall.

Each entry now displays its archive name before listing, its free-space check, its extraction destination and a completion message. LHA and LZX extraction no longer suppress progress. LHA uses the installer's bundled executable explicitly, with a 65,536-byte stack. Failed archive listing/extraction stops the current pack and prevents the wrapper from starting subsequent packs. ZIP extraction also drops an incorrect exclude switch.

Package startup still forced LhA into PURE residency, although the OS installation path had already removed this after native archive operations failed to return. The same correction now covers package startup, self-install and the older OS 3.9 startup/Boing Bag paths. This is a concrete recurrence of the earlier configuration risk; it remains a hypothesis for this particular stall until native retesting.

The Windows pack builder now discovers `*.zip` files and removes their suffix when parsing entry names. A fixture with LHA, LZX and ZIP filenames passed all three generated selection sets with LF guest scripts.

## Retest

Close the previous installer and start Setup from the updated installation. Extract a fresh copy of the bundled hard-disk image for the test. Select WHDLoad Packs normally; the existing pack layout and selection menus remain.

The old running emulator uses its previously staged scripts. Copying an update does not change that run. If the fresh run stalls, record the final **Checking archive**, **Checking free space**, or **Extracting** message and any archive-tool output. Native resolution remains unverified until this retest completes.
