Short:        Bridgeboard Diagnostic Tools
Author:       Richard 'Shred' Koerber
Uploader:     aminet shredzone de (Richard Koerber)
Type:         util/misc
Version:      0.4
Requires:     AmigaOS 1.2 or higher
Architecture: m68k-amigaos >= 1.2

License:      GNU General Public License v3
Source:       https://codeberg.org/shred/a1060-diag

A small collection of tools for diagnostics of Commodore bridge
boards. It was mainly made for the Commodore A1060 "Sidecar", but
can also be used with the Commodore A2088XT, A2286AT, and A2386SX
bridge boards (experimental).

 - sidestart: Start/Reset the Sidecar
 - sidestatus: Check the content of the status registers
 - sidediag: Check shared memory RAM and other hardware components
 - sidepcload: Loads the pc.boot file into disk buffer RAM

Please see the README.md file of the original repository for further
explanation of the tools:

  https://codeberg.org/shred/a1060-diag

These tools are provided "as-is" without warranty of any kind, either
expressed or implied. Use them at your own risk.

They are intended as a tool to help you pinpoint hardware problems.
However, they won't just run and then tell you exactly what component
need to be replaced. You will still need a deeper understanding of
electronics in general, computer hardware, and how these devices work
internally.

These tools are Open Source Software. The source code is distributed
under the GPLv3 Gnu Public License.
