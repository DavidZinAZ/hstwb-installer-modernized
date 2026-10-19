# Named settings profiles

In Setup, select **1: Configure Installer**, then **Save settings profile** or
**Load settings profile**. Choose a name such as `A1200 ZZ9000` in the file picker.
Settings and assigns are saved together in one `.hstwb-profile.json` file.
The default folder is `settings/profiles` inside this installation; you can
choose another folder to keep profiles across installer updates.

Profiles include installer mode, image and media paths, OS and Kickstart
selections, package and user-package selections, emulator configuration, and
global and package assigns. They contain configuration only, not disk images,
ROMs, firmware or application payloads.

Loading refreshes package availability and media details, then saves the loaded
configuration as the current settings. It does not run the installer. Review
the summary before starting an installation. Unavailable packages are reported
and left unselected; the original profile remains unchanged. Missing paths are
retained and reported so disconnected drives can be reconnected or the paths
changed in Setup. Paths are not automatically translated for another computer.

Before loading, Setup saves the previous configuration to a dated
`before-load-*.hstwb-profile.json` file in `settings/profiles`. Load that backup
to undo a profile change. Invalid profiles and cancellation leave the current
configuration untouched. The normal Save file picker asks before replacing an
existing profile.
