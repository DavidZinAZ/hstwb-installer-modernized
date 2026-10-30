AmiPart - prototype 20261018 (ee4c8f7)

Default drawer: SYS:Utilities/AmiPart (customizable).
Category: Storage & Filesystems.
Author: John Hertell. MIT License; see LICENSE.txt.
Previously named DiskPart; unrelated to the Windows diskpart tool.

Requires AmigaOS 2.x / Kickstart 2.04 or later and the standard ROM
Intuition, GadTools and DOS libraries. ASL is optional for Browse.

HstWB extracts the unmodified Amiga LhA release and pauses for Enter.
Launch AmiPart manually from this drawer on the target Amiga using its
Workbench icon or the Shell. HstWB does not run AmiPart or perform
partition, format, disk-write or startup operations.

This is a PROTOTYPE partition editor with RDB support. Back up your data
and partition information before use. Verify the device and unit before
writing; partition changes and formatting can destroy existing data.
Read Upstream-README.txt before use. The native Linux tool and autoboot
ADF are separate upstream assets and are not included in this package.

The bundle is pinned to the archived proto-20261018-ee4c8f7 release.
Updates require manual review; the rolling proto release is mutable and
is not treated as a stable software version. Existing drawers containing
Upstream-README.txt are retained without replacing files.

Upstream: https://github.com/ChuckyGang/AmiPart
