# Shared media library

In setup, select **Configure media library → Choose media folder** and choose the parent folder containing your licensed AmigaOS disks and Kickstart ROMs. Setup scans that folder and every subfolder. Files are recognized by the existing catalogs; they do not need to be moved or renamed.

Example:

```text
C:\hstwb-data\
  Amiga OS 3.2\
    ADF\
    Roms\
  Update3.2.1\
  Update3.2.2\
  AmigaOS-3.2.3\
```

**Rescan media** finds newly added files and clears old detection results. **View scan results** summarizes the recognized OS and ROM sets. Use the existing **Configure Amiga OS** and **Configure Kickstart** menus to select sets, select the OS target version, view individual files and missing requirements, or switch installation on/off. Scanning does not change an explicit set or OS version selection.

The shared folder is saved as `[Media] Dir`. Setup also saves it in the original OS and Kickstart directory settings, so existing installer modes continue using the same settings and workflow. Existing installations with separate folders continue to work.

Each OS/ROM menu has a separate folder override and **Use media library folder** to return that category to the shared folder. The settings summary shows the library and identifies active overrides.

Keep unwanted files **outside** the selected library folder. A directory named `disabled` or `archive` inside it is still scanned. There is no exclusion list. Discovery makes files available; the selected OS version and ROM set determine what installation uses.

For encrypted Amiga Forever ROMs, retain `rom.key` beside the encrypted ROMs. A key at the selected Kickstart scan root is also supported. Setup retains the recognized key path for installation and emulator use. Archives are not automatically extracted by this change.
