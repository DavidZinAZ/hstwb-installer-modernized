# Local settings and package updates

## Separate installations

Setup, Run, and Launcher now default to the `settings` folder inside their own installation. Each copy owns `hstwb-installer-settings.ini`, `hstwb-installer-assigns.ini`, and its log. Windows launchers work from their own folder and forward command-line options. An explicit `-settingsDir` still overrides the default.

On first setup, if neither local file exists, Setup offers to copy the previous pair from `%LOCALAPPDATA%\HstWB Installer`. This is a one-time import, not a shared reference. Existing local files are never overwritten. Imported choices retain their configured paths; the media library, image and package folders can be adjusted normally afterward. Without an import, Setup creates fresh settings for this installation.

## Standard packages

**Configure packages → Update packages** checks the packages' official GitHub release repositories. The old website feed was stuck in 2019 and omitted newer packages, including AmigaOS 3.2 fixes. **Update packages list** refreshes all repositories; downloading also refreshes a catalog that has not been checked within the last hour. A failed refresh leaves the existing catalog intact and reports failure.

The stable/prerelease choices remain. When a package has no prerelease, Setup explicitly reports that its stable release is being used. Downloads show received/total megabytes, use connection/read timeouts, and skip an existing readable package whose manifest name and version match the chosen release. The summary reports downloaded and already-current counts. Selecting download again does not transfer the same current packages again.

The downloader creates its actual destination directory, chooses the newest matching release, and validates downloaded ZIP/package metadata before replacement. A missing packages folder is treated as an empty collection. Standard package sources remain Henrik's original repositories; renaming this continuation repository does not change their download URLs.

Failed downloads and invalid packages report failure instead of `Done`. Previously downloaded files remain usable. A successful replacement retains the previous ZIP with a timestamped `.previous` suffix; those backups are excluded from normal ZIP discovery.

After an installer update, close the old Setup/PowerShell window completely and launch `setup.cmd` from the updated installation. A running session retains its loaded scripts and PowerShell classes; copying new files does not update that session.

## User-package applications

Open **Configure user packages → Update apps from sources**:

1. **Check for updates** checks the configured Aminet or original software sources.
2. **View app versions and sources** shows local and available software versions, source links, and reasons an update needs review.
3. **Update selected apps** updates one eligible component or all verified newer releases.

This updates local packages used for future installations. It does not modify an existing Amiga image. Existing installation selections, folder names, helper scripts, and custom preferences are retained.

`data/user-package-updates.json` describes all bundled user packages. It records stable IDs, payload hashes, upstream sources, archive layouts, and numeric **package revisions**. Upstream **software versions** remain separate: `47.11.2`, `1.5n`, and prerelease labels are compared appropriately rather than as decimal numbers. Date-only releases or ambiguous author labels are not assigned invented software versions. They have a numeric package revision and an explicit review status. A component update increments the package revision and records its actual software version in `_update-state.json`.

Aminet readmes and official GitHub releases/websites supply available versions. Stable releases are preferred; checks do not silently switch a legacy compatibility variant to another platform or CPU. The bundled app source catalog is independent of standard packages, which use their original GitHub release repositories.

Before replacement, the updater rechecks the source and local identity, downloads to staging, verifies an upstream SHA256 when published, checks archive structure and required members, and records the downloaded payload hash. Whole previous packages are retained in `user-packages/.updates/backups`. Incompatible or failed updates leave the active package unchanged. Staging files are retained locally for diagnosis. Backups and staging directories are not selectable packages.

Custom/patched bundles, ROM-derived or licensed components, ambiguous versions, CPU-incompatible releases, and unavailable sources show their specific review reason. For example, the newer TextEditor requires a 68020+ and a changed archive layout; it is not automatically substituted into the legacy dependency bundle. An unavailable WBDock author site is reported, not treated as proof that the local version is current. Unknown custom packages are shown as unmanaged until source metadata is added.

## Validation on October 16, 2026

Windows PowerShell tests cover local-setting isolation/import, package-directory creation, newest release selection, invalid/failed download preservation, backups, software-version ordering, app metadata, archive compatibility/path checks, and catalog coverage.

A live standard-package download also successfully downloaded and recognized BestWB 1.2.1. The existing regression suite passed with 171 tests and one skipped.

The October 17 version 1.6.6 check downloaded and recognized all 17 current standard packages using the actual Setup download function. A second pass skipped all 17 without transferring them again. Stable fallback was reported explicitly because these repositories supplied no prereleases. EAB compatibility checks passed for both the older 3.1.2 and current 3.2.0 Games/Demos AGA/OCS scripts.

Live downloads and updates succeeded in disposable copies for Amiga Test Kit 1.21, IconLib 46.4.602, iGame 2.6.1, MMU Libs 47.11.2, and WHDLoad 20.1. Original bundled payloads were left unchanged. These are download, layout, and local-package update checks; native installation and execution of the newly updated apps remain separate qualification work.
