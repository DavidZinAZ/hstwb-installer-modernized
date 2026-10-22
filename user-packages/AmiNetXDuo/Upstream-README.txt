Short:        Open-source IPv4+IPv6 TCP/IP stack
Author:       Tinic Uro
Uploader:     tinic tinic net (Tinic Uro)
Type:         comm/net
Version:      1.0.0-rc1
Replaces:     comm/net/AmiNetXDuo-1.0.0-beta8.lha
Requires:     68000+, 1 MB RAM, a SANA-II network card driver
Architecture: m68k-amigaos >= 2.0.4
Distribution: Aminet
URL:          https://github.com/tinic/AmiNetXDuo

AmiNetXDuo is a free, open-source TCP/IP stack for the classic Amiga.  It
provides the bsdsocket.library that Amiga network programs already use, and
reaches the network through your card's ordinary SANA-II driver, so
programs written for bsdsocket.library keep working; ssh, NFS mounts and
ixemul programs included.

It speaks IPv4 and IPv6.  On a network with an IPv6 router the Amiga gets an
address by itself, with nothing to configure.  Underneath is Eclipse ThreadX
NetX Duo, an embedded industrial TCP/IP stack, ported to Exec.  Its interface
files use Roadshow's format.

It is MIT licensed.  This is the release candidate for 1.0.0: if nothing
serious turns up, 1.0.0 follows with the same code.


New in 1.0.0-rc1
----------------

  * NetSwitch, a Workbench window that lists your interfaces and takes one
    online or offline with a click.
  * ShowTasks and WatchTasks list Exec tasks and DOS processes, and show
    each one's CPU and memory use live in a Shell.
  * NetWireless shows the Wi-Fi state and signal as an AppIcon.
  * ssh converts between UTF-8 and your character set, so umlauts and
    accents survive; codesets.library 6.22 is included.  httpd uses UTF-8
    for WebDAV names, so non-ASCII file names work there too.
  * A new installer that needs less memory.  It installs on an A500 with
    Kickstart 2.04 and 1 MB, finds ROM and PCMCIA drivers by itself, can
    migrate from another stack, and keeps a copy of everything it replaces.
  * The network commands follow the AmigaDOS Command Reference: QUIET
    everywhere, more ConfigureNetInterface keywords (ALIASADDR adds a
    second address), and the standard arp template.  The old
    "arp <address> SET <mac>" form is gone; scripts using it need updating.
  * NetMeter started from a Shell draws a full-window display.
  * The X-Surf 100 can be forced to 10 Mbit/s with LINKSPEED=10.

The full list is in CHANGELOG.md on GitHub.


Features
--------

  - bsdsocket.library (AmiTCP/Roadshow API), usergroup.library
  - IPv6: SLAAC, DHCPv6, neighbour discovery, duplicate address detection
  - DHCP, DNS, .local names (mDNS), IPv4 multicast, a packet filter
  - tls.library for https: and other encrypted connections, CA roots
    included
  - ssh and scp clients
  - httpd: your volumes over HTTP and WebDAV, a Shell in the browser, and
    the Amiga's screen in the browser with mouse, keyboard and clipboard
  - For the Workbench: NetPrefs (edits interface definitions, keeps your
    comments), NetMeter, NetSwitch and NetWireless
  - ping, traceroute, nslookup, netstat, ShowNetStatus, fetch, telnet,
    tftp, sntp, iperf, NetCapture (writes .pcap files for Wireshark),
    ShowTasks, WatchTasks, CheckNetConfig and CheckNetDevice when
    something does not work
  - Three stacks to choose from at install time: Full, Minimal without
    IPv6 and encryption, and Micro for small machines

Drivers included:

  anxnet.device     A2065, Ariadne, Ariadne II, AmigaNet, LAN Rover,
                    X-Surf, X-Surf 100, X-Surf 500, NE2000-compatible and
                    D-Link DL10019 PC Cards, 3Com 3C589
  anxgenet.device   Raspberry Pi 4/CM4 Ethernet, PiStorm32 with Emu68
  anxwifipi.device  Raspberry Pi 4 Wi-Fi, PiStorm32 with Emu68 (experimental)
  Xircom PCMCIA driver and pccard.library

Any other SANA-II driver works as well.


How fast
--------

Measured with iperf or AmiSpeedTest on 1.0.0-beta8, receive / send:

  A1200 PiStorm32 Lite, GENET, anxgenet.device         900 / 580 Mbit/s
  A1200 PiStorm32 Lite, Wi-Fi, anxwifipi.device     34-36 / 52-61 Mbit/s
  A1200 PiStorm32 Lite, D-Link DFE-670TXD            9.4 / 9.1 Mbit/s
  A3000 68060/50, X-Surf 100, anxnet.device         22.5 / 11.8 Mbit/s
  A3000 68030/25, X-Surf 100, anxnet.device          3.8 / 3.3-3.7 Mbit/s

The PiStorm32 Lite figures were taken on a Raspberry Pi 4; a CM4 differs.


What it does not do (yet)
-------------------------

  - It is tested on the machines above and installed in emulation on
    Kickstart 2.04, 3.0, 3.1 and 3.2, but not on everything.
  - A first https: connection on a plain 68000 takes a minute or two; a
    resumed one is quick.
  - The Wi-Fi driver is experimental and needs WirelessManager (included)
    to join a network.


Installing
----------

Unpack the archive anywhere and double-click Install-AmiNetXDuo.  The
installer finds your card's driver, writes the interface definition, and
puts the stack in the system directories or in a drawer of its own.  The
ReadMe in the archive lists every file it installs; Docs/AmiNetXDuo.guide is
the manual.


Licence
-------

MIT.  A few parts keep their own licences (ThreadX and NetX Duo MIT,
NetBSD's NE2000 core BSD, Dropbear's ssh, Mozilla's CA roots, the Wi-Fi
driver MPL 2.0 and codesets.library LGPL); the archive's documentation lists
them.


Reports from real hardware are the most useful thing you can send: the
machine, the card, the Kickstart, and what happened.  Source and issues:

  https://github.com/tinic/AmiNetXDuo
