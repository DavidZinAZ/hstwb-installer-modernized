ODFileSystem 0.8.0

Default Amiga drawer: SYS:Tools/Hardware/ODFileSystem (customizable).

OS3 release v0.8.0; keep the 68000 and 68020 variants and follow the upstream CPU guidance. Read-only optical filesystem, not a writable hard-disk filesystem. Configure device and unit for the actual drive. Preserve existing CD0 settings and use only one active DOSDriver per device name. No handler is copied into L: and no CD volume is mounted by HstWB. ROM/test binaries are supplied for manual use only.

Follow README.md to install L:ODFileSystem and create a DOSDriver.

HstWB extracts the original release files, displays the result and waits for Enter. It does not run setup, start services, mount devices or edit startup settings. Follow Upstream-README.txt after HstWB finishes. An existing destination containing Upstream-README.txt is retained without overwriting files; use upstream update procedures for existing installations.
