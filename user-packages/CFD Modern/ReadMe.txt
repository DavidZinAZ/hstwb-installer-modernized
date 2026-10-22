CFD Modern 20261007

Default Amiga drawer: SYS:Tools/Hardware/CFDModern (customizable).

Modern fork of CFD133. Bundle 20261007 contains compactflash.device 2.1 and ptable.library 2.2. Requires A600/A1200 PCMCIA, OS 2.0+, suitable adapter and Installer 43.3+ for the installer. Install FAT95 Modern separately for FAT media. Both modern packages include ptable.library 2.2: retain matching CPU/flavor versions. Choose either legacy CompactFlash and FAT95 setup or the modern pair; do not run both setups over one another. The upstream Expert installer can edit User-Startup/LoadModule; ROM autoboot is a separate manual operation. Do not force transfer flags without card testing.

Run Install, then Setup from this drawer on the target A600/A1200.

HstWB extracts the original release files, displays the result and waits for Enter. It does not run setup, start services, mount devices or edit startup settings. Follow Upstream-README.txt after HstWB finishes. An existing destination containing Upstream-README.txt is retained without overwriting files; use upstream update procedures for existing installations.
