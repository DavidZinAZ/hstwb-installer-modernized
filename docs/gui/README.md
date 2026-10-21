# Windows GUI user guide

This guide is for **HstwbDesktop.exe**, the Windows application with tabs. It covers the desktop preview shipped by this repository. The original script-based setup and command-line workflow have their own [CLI documentation](../cli/README.md).

For an offline copy, open **user-guide.html** in this folder. You can also open it from **Settings → Open GUI user guide** in the app. No internet connection is needed to read it.

## Getting started

1. Extract the complete portable ZIP into a folder where you can save files. Do not run the EXE from inside the ZIP.
2. Open the extracted **HstwbDesktop** folder and double-click **HstwbDesktop.exe**. Leave its supporting folders beside it.
3. In **Media & ROMs**, choose your media folder, select the AmigaOS target and Kickstart set, then choose **Scan folders**.
4. In **Image & Emulator**, select a template, an output folder, and your installed emulator.
5. Choose any packages, user packages, and local WHDLoad packs you want to install.
6. In **Review & Install**, choose **Validate & apply settings**. Resolve the listed issues, then choose **Run installation…**.
7. Check the new destination in the confirmation and continue. The app creates a fresh image, opens the emulator, and reports the result.

Every installation uses a new **Install-…** subfolder. An existing image in your output folder is preserved. Do not close the emulator before installation finishes.

## What you need

- Windows with .NET Framework 4.8. The portable app does not require a compiler or development SDK.
- WinUAE or FS-UAE installed separately. The app discovers installed versions or lets you choose the executable.
- Your own licensed AmigaOS installation media and Kickstart ROM files. These are not included in the portable release.
- Enough free space for the uncompressed image and installation working files. A small template ZIP can expand into a disk image many gigabytes in size.
- Internet access for source webpages, online version checks, and package downloads. Local scanning and reading this guide work offline.

The app is a preview and its executable is unsigned. Keep a copy of your original media and any images you want to retain. Creating a new image preserves older images; it does not create a backup of them.

## Find your way around

| Tab | Purpose |
| --- | --- |
| Media & ROMs | Find licensed OS media and ROMs; choose the OS target and ROM set. |
| Image & Emulator | Choose an image template, output location, and emulator. |
| Packages | Download and select standard installer packages. |
| User Packages | Review and select application bundles from your user-package library. |
| Games & Demos | Scan local WHDLoad packs and build their installation lists. |
| Settings | Save/load configurations, read this guide, or open the original setup. |
| Review & Install | Check the complete draft, save installer settings, and run installation. |

The theme controls at the top are available on every tab. The bottom status area reports the current operation. Buttons that would conflict with an operation are disabled until it finishes.

## Media & ROMs

Choose one parent folder containing your AmigaOS media and Kickstart ROMs. Subfolders are scanned, so files can remain in separate OS and ROM directories. Scanning reads the files; it does not move or rename them.

**AmigaOS to install** selects the target. AmigaOS 3.2.1, 3.2.2, 3.2.2.1, and 3.2.3 use the AmigaOS 3.2 media family plus the update media required for that target. A target choice does not mean all its required files are present; validation checks the release plan.

**Kickstart set** chooses the ROM collection for the configuration. The installer also needs a supported ROM to boot the emulator. That boot ROM can come from another detected set in the same media folder. For example, a selected 3.2.3 set can be detected while a supported 3.2 A1200 ROM boots the installer. Review & Install names the boot ROM it will use. A detected ROM is not automatically supported as an installer boot ROM.

Choose **Scan folders** after selecting a folder or changing its files. The table shows:

| Column | Meaning |
| --- | --- |
| Kind | AmigaOS media or Kickstart ROM. |
| Name | Catalog name of the expected file. |
| Set | Collection to which the entry belongs. |
| Status | Whether the last scan detected it. |
| Match | Recognition method, such as an MD5 match. |
| File | Local file found by the scan. |

**Show missing catalog entries** includes undetected rows and unavailable choices in both media dropdowns. Uncheck it to show detected Kickstart sets and OS targets with the required media. Rescan once after updating the app to refresh OS target availability in older remembered scans. The table can show entries for OS versions and machines you are not installing. The overall missing count is not a checklist of everything you must obtain. Use validation for the requirements of your actual selection.

If no compatible boot ROM is found, check the folder includes a catalog-supported A1200/A500 ROM for the selected OS family. Include the correct key file with encrypted media when required. The app does not download ROMs or bypass media recognition.

## Image & Emulator

Select the template you want to use for a fresh installation. Template information describes its declared disk capacity. Choose an **Image output folder** with sufficient space; each run creates a new, uniquely named **Install-…** folder beneath it.

The image-source menu also lets you inspect an existing image folder. Inspection checks its metadata and referenced drives. **Run installation always creates a fresh image from the selected template**, even if an existing image was inspected. The template remains selectable.

**Choose image folder…** selects the output location. A folder can already contain older images or other files because a run uses a new child folder. Basic validation may ask you to approve a nonempty folder; that approval does not authorize replacing its files.

Use **Available emulators (installed versions)** to choose a detected version. **Refresh emulator list** repeats discovery. **Choose emulator…** selects a custom WinUAE or FS-UAE executable when discovery does not find it. The executable path remains visible.

**Validate choices** checks basic image and emulator paths. The final installation check is **Review & Install → Validate & apply settings**. If image creation fails, the separate run folder remains for inspection, with a creation-failure note where possible. The app does not continue installation from an incomplete image.

## Packages

This tab contains standard installer packages. It is separate from User Packages. Package names open their source webpages; the **Install** checkbox selects a package for your installation draft.

Use the search field to filter names. Click column headings to sort. Hover over a shortened Details cell to read its full message. Selecting a row is different from ticking its Install checkbox.

| Control | What it does |
| --- | --- |
| Scan local versions | Checks the local package archives without contacting release servers. |
| Check for updates | Refreshes online release information for checked items, or the whole tab when none are checked. |
| Update selected | Downloads the saved stable releases for checked packages, skipping verified matching versions. |
| Update all in library | Updates packages already downloaded in the local library. It does not select or download every catalog item. |
| Download selected packages | Downloads the saved stable releases for checked packages; equivalent to Update selected on this tab. |
| Clear selection | Clears the installation checkboxes for this tab. It does not delete downloads. |

There is no Select visible button on this tab. A search filter does not clear hidden checkboxes, and update-selected actions still include checked items hidden by the filter.

**Local version** is read from a recognized downloaded archive. **Available version** comes from saved release information until an online check refreshes it. A local scan alone cannot establish the newest release currently online.

Matching verified archives are reused without downloading or rewriting them. A damaged or mismatched archive is not treated as current merely because its filename exists. Standard package downloads are kept in the app's **packages** folder and affect the PC library, not an existing Amiga image.

## User Packages

User packages are application bundles in the **user-packages** folder beside the installed EXE. Its path appears at the top of this tab and follows the app when it is installed in another location. Older saved profiles or native settings cannot redirect this application library to the media folder. Names link to their source webpages when a source is configured.

The **Destination Amiga folder** column shows where the bundle intends to install inside the Amiga system. It is not the Windows library path. This is an information field; the GUI does not provide an editor for it.

Search and heading sorting work as in Packages. **Select all** checks every entry in this tab, including entries hidden by a search filter. **Clear selection** clears the whole tab. Neither action downloads or deletes files.

**Scan local versions** reads local metadata and checks supported payload hashes without contacting release providers. **Check for updates** contacts sources for checked components, or all components when none are checked. **Update selected** checks and updates supported newer releases. **Update all in library** checks entries whose local bundle directory exists. Current or locally newer verified versions are not downloaded again.

Some bundles contain several components. Choosing a component can map to installation of the complete bundle. Review & Install lists the resulting bundles before running.

### PrismRTG and PrismNet

Select **PrismRTG** or **PrismNet** to include its complete upstream installation
files. Their default Amiga drawers are `SYS:Tools/Hardware/PrismRTG` and
`SYS:Tools/Network/PrismNet`. HstWB extracts the files, shows the result and waits
for Enter after each package. It does not launch or check for Amiga Installer.

After HstWB finishes, open the drawer in Workbench and run `Install_PrismRTG` or
`Install_PrismNet` using the standard Amiga Installer. PrismRTG requires Kickstart
3.1+, a 68020+ and supported RTG hardware; its installer manages the existing
Picasso96 setup. PrismNet requires AmigaOS 3.1+, a 68000+ and a suitable network
driver; disable an existing TCP/IP stack's startup before activating it. Complete
hardware setup on the final machine when preparing an image in an emulator.

Both packages report **Compatibility review required** for source updates.
Their inclusion does not enable automatic bundle replacement. See the
[package notes](../additional-user-packages.md) for details.

### More extraction-only applications

NetHarness, NilBBS, AmiFM, NilTerm, AmiDT, SCSIToolbox-Amiga, NoClick, AmiTime
and AmiSSL-Tunnel are independent selections. Each extracts its original files,
shows the next steps and waits for Enter. Existing staged drawers are retained
to protect settings and other data. Follow `ReadMe.txt` and `Upstream-README.txt`
in each drawer after HstWB finishes; some launch directly and others need setup.
The NetHarness PC tools are included as a separate ZIP to transfer to your PC;
AmiSSL-Tunnel requires a separate LAN daemon. Nothing starts automatically.
See [destinations and requirements](../additional-user-packages.md#additional-application-bundles-1617).

AmiFM's archive is supplied separately in public downloads. Obtain
`AmiFM-1.2.lha` from its upstream release and place it in the Windows
`user-packages/AmiFM` folder before installation. Review & Install checks that
the file matches the supported release. A verified local copy may already exist.

### Review and approval

Click a row and choose **Review highlighted package…**, or use its **Review…** action. The dialog shows its local version, available version, destination, PC folder, source, and notes.

- **Open source webpage** lets you examine the original project or release.
- **Open local folder** lets you inspect the local bundle.
- **Recheck source** repeats its online version check.
- **Approve for installation** records your choice to use the local package and checks it for the draft.

Approval does not verify an unknown release or override update restrictions. Changes to the recorded version, source, directory, or destination invalidate the recorded approval.

| Status or label | What to do |
| --- | --- |
| Current / Local version is newer | Keep the verified local payload; no newer download is needed. |
| Local version verified | Local bytes match known metadata. Use Check for updates for an online comparison. |
| Local version unverified | The payload is missing or differs from known metadata. Inspect your files or restore a known bundle before automatic replacement. |
| Manual updates only | This bundle has no automatic update adapter. Follow the source's instructions and review compatibility. |
| Compatibility review required | Automatic replacement is blocked by the adapter's compatibility rules. Installation approval does not remove that restriction. |
| Source check failed / Not verified | Read Details, inspect the source webpage, and retry the check when available. |
| Not versioned | The component has no author version that the app can report. This is not proof that it is missing. |

Supported updates retain backups beneath the user-package library's **.updates** directory. Review any failure message before retrying; the app does not silently approve an unverified payload.

## Games & Demos

This tab manages your existing local WHDLoad game, demo, beta, and magazine archives. It does not download game collections. WHDLoad runtime and ROM-support bundles remain in User Packages.

Choose the **WHDLoad Packs** folder containing the pack subfolders, rather than an individual game archive or Games subfolder. **Use folder from installer settings** restores the game folder derived from the native installer configuration. Choosing an external packs folder does not change the User Packages application library. During a GUI installation the app references the selected collection for that run without copying its archives into the local application library.

1. Choose **Scan local packs** to count local LHA, LZX, and ZIP archives and inspect existing installation lists.
2. Review **Archives**, **Entries in lists**, **Destination Amiga folder**, and **Status**.
3. Choose **Build installation lists** when lists are missing or stale. Earlier generated lists are backed up under the app's user-packages/.updates/games-list-backups folder. Archive payloads are left unchanged.
4. Check **Install WHDLoad Packs bundle (all populated pack folders)** to include the complete bundle in the draft.

**Ready** means the recognized archive paths and installation lists agree. It is not an integrity check of every game archive. Rescan and rebuild after adding, removing, or replacing archives. Choices within a pack are made during Amiga installation; ticking the bundle does not select individual games in the Windows table.

**Open pack folder** opens the highlighted pack, or the packs root when no row is highlighted. **About WHDLoad** opens its website.

## Settings and appearance

Your current draft and theme choices are saved automatically in this app folder. Use **Settings → Save settings…** to keep a named desktop profile, and **Load settings…** to restore one. Desktop profiles use **.hstwb-desktop.json**.

Load settings also accepts supported fields from native **.hstwb-profile.json** profiles or the native installer settings INI. Unsupported native options are not exposed as new GUI controls. The original imported file is not modified, and the current desktop draft is backed up before loading another configuration.

A desktop profile contains choices and paths, not OS media, archives, downloaded applications, or disk images. An unavailable path is retained so a disconnected drive can be reconnected. Review imported paths, refresh local detection when files have changed, and validate before running.

**Existing installer setup** is a separate section in Settings. Its button opens the original configuration interface for advanced legacy options. It is optional for the GUI installation workflow; Run installation is available directly in Review & Install.

Use **Amiga theme** and **Brightness** at the top to select Workbench 1.3 or AmigaOS 3.2 inspired colors in light or dark mode. The theme does not change the OS being installed.

### Remembered scan results

The app restores saved media/ROM scans, pack inventories, and compatible package check results across launches. Media and game summaries show **Last scanned**; package Details identify saved results and their time. These are last-known observations, not live monitoring.

Results are associated with their library folder. Switching media folders clears results from the previous folder and restores a matching saved scan if available. Online package checks are not repeated simply to display remembered information. A fresh local catalog read can discard an incompatible saved package result when the local version has changed.

After changing files, choose the relevant scan or check button. Installation validates the selected OS, Kickstart set, packages, and required installer boot ROM regardless of the remembered display. It checks package dependencies and conflicts within the selection. The installer reuses that fresh validation instead of scanning everything again, and checks for changed files after image creation. Unselected package archives are skipped.

## Review & Install

This tab summarizes the selected OS, ROM set, paths, packages, and user-package bundles. Installation currently uses the native **Install** mode.

**Validate & apply settings** reads only media for the chosen OS and Kickstart sets, plus a compatible installer boot ROM. It uses catalog filenames and remembered paths for renamed media; use **Scan folders** after renaming or moving media. It checks recognized required media, the OS update plan, a compatible installer boot ROM, the image template and destination, the emulator executable, downloaded package availability, advertised OS compatibility, dependencies, dependency cycles, and conflicting package content. A populated WHDLoad pack must have prepared installation lists.

Resolve each issue on its relevant tab and validate again. A checked package must be available locally before installation. If a package needs another package, select and download the named dependency too.

**Validate & apply settings** checks your choices once and writes the valid configuration to native settings and assigns, with backups. If there are issues, it lists them without applying settings. It does not create an image or start installation. Do not mistake an applied configuration for a completed installation. **Run installation…** saves the required configuration as part of running, so you do not have to apply separately first.

### Run an installation

1. Choose **Run installation…**. The app reuses the successful Validate & apply settings check when choices and input files are unchanged. Changed choices or files trigger a fresh validation.
2. Read the confirmation showing the exact new **Install-…** image folder.
3. Continue to create the image from the selected template. Existing images are not reused or overwritten.
4. The app saves installer settings with a backup and starts the emulator. Watch the emulator for the Amiga installation process and any necessary prompts.
5. Leave the app open until it reports completion or failure. The new image path and log are shown on success. A failed run is not reported as completed.

The app prevents closing while its operation is busy. There is currently no GUI cancel button; avoid terminating the app or emulator during disk writes. Each later run gets another new destination. It does not resume a previous partial installation.

## Progress and logs

The bottom status text identifies the current item or phase. Package batches count completed items. Media scans report files, and pack scans report pack folders. Downloads report transferred bytes and a percentage when the source supplies the total size. When the total is unknown, the byte count is meaningful even if the bar cannot estimate a completion percentage.

Image creation reports extracted bytes. During emulation, the app reports that it is waiting for the Amiga installation. The bar describes the host operation or phase; it is not a measurement of every AmigaDOS task inside the emulator. Preparation without a known total has a status message rather than an endlessly looping bar.

Installer-run logs are in **.output/desktop/installation-….log** under the app folder. Failed bridge operations are recorded in **.output/desktop/bridge-errors.log**. When reporting a problem, include the tab, action, selected versions, and relevant error text. Review logs for private file paths before sharing them.

## Troubleshooting

| Problem | Checks and next steps |
| --- | --- |
| EXE does not start | Extract the entire ZIP, retain the support folders, use a writable location, and check that .NET Framework 4.8 is available. The preview EXE is unsigned. |
| Windows cannot find a supporting script or catalog | Re-extract a complete release. Copying only the EXE is insufficient. |
| Downloaded package still appears missing | Use Scan local versions. Check Details for a failed transfer or invalid archive. A filename alone does not establish a valid package/version. |
| GitHub request limit reached | Keep the local version and saved release catalog. Saved standard releases can still be downloaded; retry the online check later. |
| Required media is missing despite a large detected count | Check the selected target's validation issues. Counts cover several supported sets; they do not prove a complete selected release. |
| ROMs are detected but no compatible boot ROM is found | Include a supported boot ROM for the selected OS family in the scanned folder. Read the boot-ROM explanation in Media & ROMs above. |
| Saved results disagree with changed files | Rescan the appropriate folder. Saved results are intentionally not live monitoring. |
| Emulator is missing from the menu | Refresh discovery or choose its supported executable directly. The app does not install emulators. |
| Not enough space for a new image | Choose another output drive or a smaller template, retaining enough space for installation working files. |
| New image destination already exists | Start another run so the app plans a new unique destination. Existing destinations are not overwritten. |
| Game pack lists need rebuilding | Rescan the selected WHDLoad Packs root and build installation lists. Check the displayed library path first. |
| Installation fails or the emulator closes early | Read the displayed message and run log. Retain the separate failed image for investigation; a later run creates a fresh image. |

## Where your files are kept

These locations are relative to the extracted app folder unless you selected an external library or output folder.

| Location | Contents |
| --- | --- |
| settings/desktop.json | Automatically saved desktop draft and appearance choices. |
| settings/desktop-scans.json | Remembered scan and package-check results. |
| settings/desktop-package-catalog.json | Saved standard-package release information. |
| settings/hstwb-installer-settings.ini and settings/hstwb-installer-assigns.ini | Applied native installer configuration. |
| settings/backups/desktop-… | Native settings backups made when applying or running. |
| packages | Downloaded standard package archives. |
| user-packages | Default application and WHDLoad bundle library; an external library can be selected. |
| .output/desktop | Desktop diagnostics and installation logs. |
| Your selected output folder/Install-… | A separate new image for each installation. |

Do not delete settings, libraries, or images merely to update the EXE. To test a newer portable release, extract it into a separate folder, save a named desktop profile in the older app, then load it in the newer app. Check all paths and rescan as needed. The new release has its own local scan cache. External libraries and existing images remain where you placed them.
