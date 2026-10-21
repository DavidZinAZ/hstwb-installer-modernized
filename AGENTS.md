# Project instructions

- For every change, increment the shared application/installer version in `modules/version.psm1` (normally the patch number, once per change set).
- Keep desktop and installer versions identical. Desktop UI and executable metadata must derive from `HstwbInstallerVersion`; do not maintain a separate desktop version.
- When updating the installed app at `C:\HstwbDesktop`, preserve settings, media, downloaded libraries, and other user data.
