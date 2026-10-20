# CLI and original setup documentation

This section covers the original script-based installer and its setup/launcher interfaces. Documentation for **HstwbDesktop.exe** is in the separate [Windows GUI user guide](../gui/README.md).

## Starting the original tools

On Windows, **setup.cmd** opens the original configuration menus, **run.cmd** runs the native installer using its saved configuration, and **launcher.cmd** opens the original launcher. Advanced script parameters and supported platforms remain documented alongside the original scripts and support files.

The GUI's Settings tab can open the original setup, but the GUI does not require this step to run an installation. The native scripts and the GUI share the installation engine; their configuration controls and profile formats differ.

## Task guides

- [Configure the media library](../media-library.md): original setup menu instructions for OS and Kickstart folders.
- [Local settings and package updates](../settings-and-package-updates.md): native setup configuration, source updates, backups, and migration.
- [Native settings profiles](../settings-profiles.md): save/load native settings and assigns together.
- [AmigaOS 3.2.x media reference](../amigaos-3.2.x-media-reference.md): required release media and reference information.
- [Additional user packages](../additional-user-packages.md): bundle integration and source information.
- [WHDLoad pack troubleshooting](../whdload-pack-troubleshooting.md): native pack/list investigation.
- [BestClassicWB integration](../bestclassicwb-package.md): package requirements and experimental compatibility notes.
- [Validation status](../validation-status.md): recorded test coverage and remaining installation checks.

These existing guides retain their original paths so links and prior instructions continue to work. References to Configure Installer, Configure media library, or numbered setup menus describe the original setup interface, not the Windows GUI tabs.

## Profiles and image behavior

Native **.hstwb-profile.json** profiles include native settings and assigns. GUI **.hstwb-desktop.json** profiles cover the fields exposed by the Windows app. Importing supported native fields into the GUI does not expose every legacy mode or option.

The native run scripts operate on the image directory in their settings. The GUI's **Run installation** explicitly creates a fresh image for each run. Do not assume the GUI's new-image behavior also applies when invoking **run.cmd** directly.
