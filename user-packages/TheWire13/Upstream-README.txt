Short:        lightweight TCP/IP stack
Author:       aminet@jaehne.tk (Marcel JÃ¤hne)
Uploader:     aminet jaehne tk (Marcel JÃ¤hne)
Type:         comm/tcp
Version:      1.9.0
Replaces:     comm/tcp/TheWire13.lha
Architecture: m68k-amigaos => 1.3
Distribution: Aminet

TheWire13 is the world first lightweight TCP/IP stack for Amiga OS1.3
=====================================================================

The project was written specifically for low-level AmigaOS networking
experiments and real hardware usage on systems without modern TCP/IP
stacks available (OS1.3).

The stack is intended to provide a lightweight and OS1.3-compatible
networking environment for custom tools and applications.

If you like my work feel free to spend me a coffee: paypal.me/mytubefree

:-)

_________________
## Current Status

TheWire13 is still under active development and internal structures,
network behavior, and APIs may change between releases.
________________
## Requirements

* AmigaOS >=1.3
* SANA-II compatible network driver
* at least 68000 CPU (>=68020 recommended)
* enough free RAM for networking buffers
__________________
## Installation
copy TheWire13 to C:
copy bsdsocket.library to LIBS:
copy thewire13.conf to S:
copy amitcp13.hosts to S:
copy all mini_* programs to C: (e.g. mini_ping)

For Zorro-LAN-IDE-CP Card:
copy enc62413.device DEVS:networks

__________________
## Configuration

The stack currently uses the configuration file:
S:thewire13.conf
_________________
## Starting

Start the stack from Shell:

TheWire13

or just in background with
run >NIL: C:/thewire13


Expected startup banner:

TheWire13 v1.8.2 by Marcel Jähne (c)2026
Stack running...
_________________
## Notes

* The stack binary itself is intentionally kept lightweight and avoids
  large stdio/newlib runtime dependencies.
* DHCP support is integrated.
* bsdsocket.library support is still incomplete and evolving.

## History
1.9

 - Socket compatibility
 - Nonblocking TCP connect reports EINPROGRESS, repeated pending connects
   report EALREADY, and already-connected sockets report EISCONN.
 - Datagram connects complete synchronously.
 - select() and WaitSelect() preserve the caller's interest sets while polling
   and on errors, validate descriptors and timeouts, and expose nonblocking
   connect success or failure through write readiness.
 - SO_ERROR returns and consumes the pending socket error only after output
   arguments have been validated. Terminal connection failures remain available
   to subsequent I/O.
 - Explicitly requested WaitSelect() signals return normally with the received
   mask; unrequested configured interrupt signals return EINTR. Blocking library
   send/receive waits also check the configured interrupt mask.
 - send() and recv() support MSG_DONTWAIT and null buffers for zero-length
   calls, reject unsupported flags explicitly, and preserve partial sends.
 - Internal errno and byte/word/long caller errno pointers remain supported.
 - Stack IPC propagates socket errors and supports consuming pending errors.
 - Preserve ECONNREFUSED, ECONNRESET, and ETIMEDOUT after PCB cleanup.
 - Detach closed socket references before PCB slots are reused and release
   RX storage when unused sockets are closed or sockets are aborted.
 - Report exhausted SYN, data, and persist retries as failures instead of
   silently discarding unacknowledged data.
 - Allow sends after remote FIN and defer local FIN until queued data is
   acknowledged. Ordinary EOF/errors use read/write readiness, not exceptfds.

1.8.2
 - Added SetSockOpt() support for:
     - SO_REUSEADDR
     - SO_KEEPALIVE
     - SO_DONTROUTE
     - SO_BROADCAST
     - SO_OOBINLINE
     - TCP_NODELAY
 - Added explicit ENOPROTOOPT handling for unsupported socket options.
 - Added GetHostName() using the active TheWire13 configuration.
 - Added AmiTCP-compatible hostname truncation and guaranteed NUL termination.
 - Added per-client interrupt, I/O, and urgent masks through SetSocketSignals().
 - Added the classic CTRL-C default interrupt mask.
 - Configured interrupt signals can now abort WaitSelect() with EINTR.
 - I/O and urgent masks are retained for future asynchronous event support.

1.8.1
 - Improved compatibility with third-party SANA-II network devices.
 - Fixed local hostname resolution for localhost.
 - Added local handling for 127.0.0.0/8 loopback addresses.
 - Added local ICMP echo replies for the configured host IP address.
 - Local loopback traffic no longer uses ARP or the SANA-II device.
 - Fixed binary TCP data corruption affecting FTP transfers.
 - Improved reliable uploads and downloads through bsdsocket.library.
 - Updated EAGAIN and EWOULDBLOCK to the Amiga-compatible errno value 35.
 - Fixed applications incorrectly failing when non-blocking sockets
   temporarily return EWOULDBLOCK.
 - Improved partial and deferred socket-write handling in compatible applications.

1.8
 - Added passive TCP connection handling required by server applications such as MiniFTPD.
 - Added getsockname() support for determining local socket addresses and passive FTP endpoints.
 - Improved WaitSelect() handling for Amiga Exec signals.
 - Added reliable Ctrl-C handling for network server applications.
 - Fixed RAW ICMP ping responses for the locally configured IP address.
 - Fixed TCP partial-send handling to prevent corrupted or non-repeatable binary transfers.
 - TCP now acknowledges only data that has actually entered retransmission-safe transmit storage.

1.7.4
 - Added TCP server socket support.
 - Implemented bind(), listen(), and accept().
 - Added blocking and non-blocking accept() handling.
 - Extended WaitSelect() support for pending incoming connections.
 - Added new IPC commands for server socket operations.
 - Updated bsdsocket.library from version 4.2 to 4.3.
 - Updated TheWire13?s library compatibility check.
 - Preserved existing client-side TCP, UDP, and ICMP behavior.

1.7.3
 - localhost is resolved internally to 127.0.0.1.
 - Pings to 127.0.0.0/8 are answered locally.
 - Pings to the configured local IP address are also answered locally.
 - Neither ARP nor SANA-II is used for these local requests.
 - External ICMP, TCP, and UDP paths remain unchanged.
 - The gethostbyname() regression test has been extended.

1.7.2
Bugfix: S:thewire13.conf was not found

1.7
 - Updated mini_wget HTTPS support to require AmiTLS13 v2+.
 - Updated AmiTLS13 headers/API:
      - AMITLS13_VERSION changed from 1 to 2
      - added AmiTLS13_StartTLS() API/stub entry
 - Added streaming performance configuration:
      - streaming_mode=1
      - socket_rx_buffer=65535
      - sana_rx_requests=64
      - tcp_window=65535
 - Reworked TCP receive buffering to use a ring buffer:
      - removes memmove() from the TCP receive hot path
      - reduces CPU load during streaming/downloads
      - improves continuous stream handling for programs such as MASRadio
 - Disabled periodic performance logging by default.
 - Disabled RX diagnostic logging by default.
 - Moved SANA TX console logging behind a compile-time switch and disabled it by default.

1.6.2
 - A send(to) Bug in bsdsocket.library was fixed
 - Added a startup version check in TheWire13 for bsdsocket.library.
 - TheWire13 now prints a warning if bsdsocket.library is missing.
 - TheWire13 now prints a warning if the installed bsdsocket.library version does not match
   the expected version.
 - Fixed blocking UDP sendto() behavior so transient ARP resolution no longer immediately
   returns EWOULDBLOCK / errno 35.
 - Added ARP retry handling for blocking datagram sockets.

1.6.1
  - Mini_wget now supports SSL/TLS by AmiTLS13.library

1.6
  - DHCP can now send the configured hostname.
  - DHCPNAK is detected and handled cleanly.
  - DHCP now accepts multiple DNS servers.
  - If DHCP fails, TheWire13 automatically uses the static IP settings from the same config.
  - Added a small TTL-based DNS resolver cache.
  - DNS resolver can retry/fail over across multiple DNS servers.
  - Optional local hosts file support: S:amitcp13.hosts.
  - Removed low-level options config, packettype_ip, and packettype_arp from user config.
  - Startup now prints IP, netmask, gateway, and DNS.


1.5
  - multiclient support
  - performance improvements

1.4

  - separate client context per Exec task
  - separate IPC request/reply port per task
  - separate errno/h_errno, hostent buffers, fd state, nonblocking state
  - closing one program?s library context no longer corrupts another program?s sockets
  - TCP RX buffers are dynamically allocated instead of bloating BSS
  - RX buffer target is now up to 65535 bytes
  - Fast/Slow RAM is preferred for TCP RX buffers, with public memory fallback
  - unread RX data is dropped on close, but the RX buffer stays until PCB cleanup so late FIN/ACK handling
    remains stable
  - default AMITCP13_TCP_REASS_MAX raised to 32
  - reassembly pressure counters available in TCP PERF logs
  - window clamping when reassembly is full or nearly full
  - app-drain window update threshold lowered
  - better recovery when apps drain data in 2048-byte chunks
  - IPC payload stays conservative at 2048
  - TCP MSS stays conservative at 536
  - TCP TX segment stays conservative at 512
  - RX buffering/reassembly/read windows were increased instead of making TX more aggressive
  - enc62413-specific active IP read target increased to 128
  - SANA RX packet buffers allocated dynamically
  - private enc62413 maintenance poll rounds retained for bounded servicing
  - bsdsocket.library remains 4.1.1
  - a314eth behavior preserved
  - no bsdsocket ABI offset change

    enc62413.device v0.6

      - Baxnet-style INTB_PORTS IRQ wakeup is now default
      - ISR only clears ENC EIE.INTIE and signals the device task
      - frame copy/drain remains in task context, not interrupt context
      - Z2v2 LAN IRQ gate now uses base + 0x4000
      - matches the card developer?s hardware information
      - ENC62413_PERIODIC_POLL=0
      - IRQ-only operation tested better for DHCP, MiniFTP, mini_wget, mini_nslookup, MajaRadio, and multitasking
      - periodic polling can still be built for diagnostics
      - packet/full IRQ path
      - avoids RX-abort interrupt storms
      - INTIE is re-enabled only after task-side drain logic
      - private IP/ARP staging increased from 8 to 64 slots
      - staging buffers are dynamically allocated
      - helps absorb bursts when no matching SANA read is immediately available
      - driver now builds its own internal buffer-management structure from OpenDevice callbacks
      - supports S2_CopyToBuff16 / S2_CopyFromBuff16
      - falls back to classic S2_CopyToBuff / S2_CopyFromBuff
      - optional full chip reset remains disabled by default
      - MAC is explicitly written during init
      - bounded PHY/link readiness waits retained
      - ENC RX flags cleared after RX enable
      - removing the periodic fast poller greatly reduces CPU load
      - GUI responsiveness improved while transfers remain fast

1.3
  - bsdsocket.library public ID bumped to 4.1.1.
  - EAGAIN / EWOULDBLOCK now uses classic Amiga/AmiTCP errno value 35 instead of 11.
  - Improved compatibility with OS3/AmiTCP-style bsdsocket programs.
  - TCP active-open handling improved to avoid stale socket/port reuse.
  - TCP RX buffers are preserved longer during close cleanup.
  - Added TCP timer diagnostics for enc62413 stall investigation.
  - enc62413 RX path received multiple stability fixes:
      - improved burst recovery polling
      - stabilized RX preamble reads
      - moved private SRAM usage away from TX buffer area
      - guarded stale RX-ready states
      - relaxed stale-ready handling where needed
      - avoided RX reset on stale status
  - enc62413 hybrid interrupt RX wakeup was implemented experimentally, then disabled by default for safety.
  - Added enc62413 live debug control tool.
  - Added gateway TCP diagnostic test tool.
  - Added baxnet comparison notes/work around enc62413 RX behavior.
  - MiniFTP and MiniIRC were split out into separate repositories, reducing TheWire13 tree scope.
  - TheWire13 trace ring remains disabled by default from the stable v1.2 base.

1.2
- TCP throughput tuning.
- TCP bulk download stabilization restored.
- Silent TheWire13 trace ring added.
- TCP window updates tuned.
- SANA RX serviced during IPC bursts.
- SANA RX burst servicing throttled.
- TCP RX buffers moved to dynamic AllocMem().
- TCP RX buffers released on socket close.
- TCP write readiness fixed for uploads.
- TCP partial-send handling added.
- Deferred TCP FIN fixed after upload drain.

    MiniFTP 0.9

  - Local directory navigation added.
  - Public name changed to MiniFTP v0.7.
  - Port field added, MiniFTP v0.8.
  - Transfer redraws reduced.
  - Downloads now validate against FTP SIZE, so short/incomplete transfers no longer show false ?Download complete?.

    enc62413.device 0.5 / SANA RX

  - RX liveness debug builds added.
  - Poll process startup hardened.
  - RX drain improved during private polls.
  - RX ring recovery hardened.
  - RX flow control tested/enabled.
  - SANA RX polling added during WaitSelect().
  - TX register ordering fixed.
  - RX length derived from ring distance.
  - SANA RX read depth increased and later restored to 32.
  - SANA reads refilled before driver polling.
  - Double-buffered TX added.
  - RX frames held until SANA reads are ready.
  - RX status validation, byte order, and EtherType handling adjusted.
  - RX polling interval and budget tuned repeatedly.
  - Silent enc62413 stall counters added.
  - Dynamic RX buffering for enc62413 bursts added.
  - Staged RX reads drained directly.

1.1
- Added AMITCP13_SOCKET_CLEANUP_DEBUG=1, which enables socket cleanup/pool diagnostics.
- Added fd/socket/TCP/UDP/RAW pool summaries behind debug builds.
- Hardened TCP cleanup for stuck CLOSED, FIN_WAIT_1, FIN_WAIT_2, CLOSING, and LAST_ACK PCBs.
- Cleaned failed initial SYN send path without prematurely reusing the socket wrapper.

1.0
- Added central limits in include/amitcp13/socket_limits.h.
- Increased core/IPC socket slots from 8 to 16.
- Increased TCP PCB pool from 8 to 12.

0.9.1
* Improved RX speed on enc62413.device by factor 10
* Bumped Mini_FTP_Gui to v0.4
  - mini_ftp_gui now tracks the PASV data socket with a single g_data_fd.
  - Before every new PASV data connection, any previous data socket is closed.
  - LIST/GET/PUT close data sockets on success and error paths, then wait for final 226/250 replies where appropriate.
  - Ambiguous transfer failures now close the control session and show reconnect-required status.

0.9 Alpha
* Improved stability
* Introduce the new enc62413.device
* Reduced debug output

0.8 Alpha

* Public runtime renamed to TheWire13
* DHCP support added
* ICMP support added
* TCP throughput improvements
* Reduced memory footprint / stdio-free runtime
* Improved network recovery stability
* Expanded bsdsocket.library compatibility

##License

TheWire13 is freeware
This software may be freely used, copied, and redistributed in unmodified
form.
The software is provided "as is" without warranty of any kind. Use at your
own risk.

Copyright (c)2026 Marcel Jähne
