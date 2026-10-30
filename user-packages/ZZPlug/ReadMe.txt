ZZPlug 0.8 - USB stack for the MNT ZZ9000

Default drawer: SYS:Tools/Hardware/ZZPlug (customizable).
Category: Hardware & Drivers.

Requires AmigaOS 3.1+, 68020+ and ZZ9000 firmware 2.8+ (USB proxy v2).
Use a USB 2.0 hub for mice, keyboards and game pads. USB sticks can
connect directly. Game pads require lowlevel.library; FAT USB sticks
require CrossDOSFileSystem or fat95. Another USB stack cannot share
this port. Cold-start hubs may need unplugging and reconnecting.

HstWB extracts the original release into the chosen drawer and pauses.
Run Install_ZZPlug manually on the final Amiga. The upstream installer
copies system components, edits S:User-Startup and starts ZZPlug;
it also supports updating and removing the installation. Review README
and Upstream-README.txt before setup. HstWB does not activate the stack.
An existing drawer containing Upstream-README.txt is retained without
replacing files. Use upstream instructions to update an existing setup.

Upstream: https://github.com/lainejones/ZZPlug
License: GPL-3.0-or-later; original notices retained in the archive.
