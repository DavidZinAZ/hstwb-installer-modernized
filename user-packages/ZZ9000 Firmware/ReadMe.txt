ZZ9000 Firmware 2.8.1
Default destination: SYS:Tools/Hardware/ZZ9000/Firmware
Source: https://github.com/BlitterStudio/zz9000-firmware

This package copies files only. It does not run diagnostics, flash hardware,
replace Workbench, or add startup tasks.

Variants/ contains each published board variant separately, with BOOT.bin
and sample ZZ9000.CFG. Original ZIPs are retained. Select the correct variant
using upstream documentation. Do not copy every variant to a card.
Use drivers and firmware from the same release. Existing card settings are not changed.
