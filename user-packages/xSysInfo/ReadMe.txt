xSysInfo 0.12.0
Default destination: SYS:Tools/Diagnostics/xSysInfo
Source: https://github.com/reinauer/xSysInfo

This package copies files only. It does not run diagnostics, flash hardware,
replace Workbench, or add startup tasks.

identify.library is copied to system Libs only when absent. Existing copies
are retained; the upstream Install script can review replacements.
