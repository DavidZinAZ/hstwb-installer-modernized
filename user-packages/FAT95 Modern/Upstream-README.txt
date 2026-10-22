Short:        fat12/16/32 filesystem handler
Author:       jaroslav.pulchart@gmail.com (Jaroslav Pulchart), based on work by Torsten Jager
Uploader:     jaroslav pulchart gmail com (Jaroslav Pulchart)
Type:         disk/misc
Version:      20261007
Replaces:     disk/misc/fat95.v20260930.lha
Requires:     AmigaOS 1.3+ (2.0+ for full functionality), a block device such as compactflash.device, ptable.library for auto-detect
Architecture: m68k-amigaos
Kurz:         fat12/16/32 Dateisystem-Handler

fat95 - FAT12/16/32 filesystem handler for AmigaOS. Fork of disk/misc/fat95.lha.

COMPONENTS IN THIS RELEASE
==========================
- fat95 4.1 (30.09.2026)
- install95 3.20 (04.10.2026)
- dd 2.7 (03.10.2026)
- debug95 3.19 (25.01.2026)
- SetFileSize 1.1 (25.01.2026)
- boot95 3.19 (25.01.2026)
- lsfsres 1.3 (03.10.2026)
- ptable.library 2.2 (03.10.2026)
- lsptres 1.2 (03.10.2026)

WHAT'S NEW (07.10.2026)
=======================

Install:

* New Installer and Language scripts.
* Language folders replaced by locale/ files.
* Reworked icon positions.

ptable.library 2.2, lsptres 1.2:

* Synced with amigaos-ptable, ptable.library ships in small and full
  variants.

Tools 'dd 2.7', 'lsfsres 1.3':

* Improved paging.

Purpose
--------

"fat95" is a DOS handler to mount and use FAT12/16/32 volumes just as if
they were AMIGA volumes.

System requirements
===================

* every AMIGA, OS 1.3+ (OS 2.0+ for full functionality)
* a suitable device file for low level disk access, like the
  mfm.device for floppies, compactflash.device for CF in PCMCIA
* ptable.library (bundled, install to LIBS:) for partition auto-detect,
  explicit-geometry mountlist entries do not need it
* Installer 43.3 or newer for Install (without it, see Installation in
  fat95.guide)

Installation
============

* Double-click Install. It detects the CPU tier, copies L:fat95 and
  ptable.library (small variant, full in Expert mode), writes the
  chosen language into L:fat95, and offers the tools and the floppy
  mountlists MS0 and MS1.

  In Expert mode it also adds a LoadModule L:fat95 line at the top of
  S:User-Startup. cfd and fat95 share one LoadModule line. Adapt that
  line to your system as needed.

  I recommend putting fat95 and ptable.library in ROM as resident
  modules instead of LoadModule.

* Double-click Language to change the language of an installed L:fat95.

Features
========

See fat95.guide for full documentation.

* Workbench and applications support
* Diskchange autosense
* Format type autosense: FAT12, FAT16 and FAT32
* MBR, GPT, and flat (whole-disk FAT) partition support
* Simple LINUX style partition selection or manual definition
* Up to 4 GBytes of partition size for FAT16
* Large harddisk support via TD64 or direct SCSI
* Long filenames (up to 104 chars for now)
* Inquiry, read, write, and maintenance access
* Built-in error check utility
* Disk formatting using the OS 2.0+ format command
* MS-DOS 8.3 downward compatibility
* User definable language and code page
* Date range Jan 1st, 1980 through Dec 31st, 2107
* Extended datestamp support: creation date and time, last accessed date
  (readable as file comment text; off by default, Control "+d+D" enables)
* Volume serial number as name for unnamed volumes
* Automatic directory optimization
* Installer script for automated installation (Installer 43.3 or newer)

SOURCE CODE
===========
Source code available at: https://github.com/pulchart/fat95

Licensed under GNU LGPL v2.1

SUPPORT
--------
The improvements to this driver are developed in my free time.
If you'd like to support ongoing maintenance and experimentation,
you can do so on Ko-fi: https://ko-fi.com/jaroslavpulchart

HISTORY
--------
See docs/changes.guide for release notes and original fat95 history.
Online version: https://github.com/pulchart/fat95/blob/master/docs/changes.md

CHECKSUMS
=========
l/68080/fat95 4.1 (30.09.2026) (29940 bytes):
  MD5:    edc9ff65996f08212e20f5df0d4ba740
  SHA256: 598225d795fe4b07e5709a91a1f18f64b83997f037fdb554d94bc9f38620b85a

l/68020/fat95 4.1 (30.09.2026) (29972 bytes):
  MD5:    7120da4df5104e3e46a4006c87e7a36e
  SHA256: 3f817386703503c77e64971ef1cf64db752f8f8e12449b1ba5a50af14284f887

l/68000/fat95 4.1 (30.09.2026) (30148 bytes):
  MD5:    0e593be6c463f31583d5cb0d1b56768b
  SHA256: cab84f92af01e86b7a21d9e3da992890085f45e04305c6928287d33e8951d88f

install95 3.20 (04.10.2026) (2928 bytes):
  MD5:    bdd234385a3c62a627b8a58d6ca93f65
  SHA256: a118f61b78640613477a4b42bb902d2ef882362fb077789f713a71f53e42abc1

dd 2.7 (03.10.2026) (11044 bytes):
  MD5:    71a8464372b2b63a4ed5308bb6f3ea4b
  SHA256: d7c6d1e281d50f27f225875e07ee4049063784a7229cf4974ee400749e655aaa

debug95 3.19 (25.01.2026) (520 bytes):
  MD5:    de2f9b6fb8de8a8935f99ccb6639f4b1
  SHA256: 40b45a8ce812168fe77437772944f97202e84b27808f2e55c82593678d1a6559

SetFileSize 1.1 (25.01.2026) (888 bytes):
  MD5:    9ed3250c0d37a6253ef222fbfa822d48
  SHA256: 54b054d094139b7be01220a42b5a05cee18a1cc511387fa201338dcad069b808

boot95 3.19 (25.01.2026) (2512 bytes):
  MD5:    2feb11a7b50845ea12a4d8fdd16370cc
  SHA256: f8279bdca5bfd632598f2d734475e11aa992ef27a30f1df161991aa18bc5d81d

lsfsres 1.3 (03.10.2026) (2116 bytes):
  MD5:    a64b200800c6f106d22da7ae72b49a48
  SHA256: 650c4de2cf8e0a3a9b096ba99b902dfb0631ba6bd688017ce36c67469f2a0172

libs/small/68020/ptable.library 2.2 (03.10.2026) (9884 bytes):
  MD5:    a712189c33b106c8b60067733b30dc1f
  SHA256: bafbc3c2350a6f9afb7b5fad5e86d0105e1d44673a866a891bcf71f8e6fd5330

libs/small/68000/ptable.library 2.2 (03.10.2026) (9952 bytes):
  MD5:    7d84ff5982336761fd77588ea1afa590
  SHA256: f9ff4b2c94d8d210c97a99ecbd02db8976574923210b5e35885c97075ea3658f

libs/full/68020/ptable.library 2.2 (03.10.2026) (11928 bytes):
  MD5:    ab54e49754484d0e71f7cddd511a5f3f
  SHA256: 3bc8e42df2d787e18fc066ca1d0c4b1f8a47971a438e4c97f8a36a218326be31

libs/full/68000/ptable.library 2.2 (03.10.2026) (11996 bytes):
  MD5:    7cac89d1c267c1ab6a9a32d707b090a0
  SHA256: e73c55b304495147861b4ab27ebede5f8ac8154e763d7a42e328e5d026bf11db

lsptres 1.2 (03.10.2026) (14180 bytes):
  MD5:    c72d743750046076d8ab56f0c104313d
  SHA256: 4718c271ee58742627b785470546e11faaddc42468e8651dd5205ccd6fd7fd81



CONTENTS
========
fat95/Install            - Installer script
fat95/Language           - Change the language of L:fat95
fat95/docs/fat95.guide   - FAT95 filesystem handler documentation
fat95/docs/changes.guide - Release notes and original fat95 history
fat95/docs/dd.guide      - dd raw block transfer tool documentation
fat95/docs/lsfsres.guide - lsfsres FileSystem.resource lister documentation
fat95/docs/lsptres.guide - lsptres partition.resource lister documentation

fat95/l/68080/fat95 - Filesystem handler, Apollo 68080 CPU tier
fat95/l/68020/fat95 - Filesystem handler, 68020+ CPU tier
fat95/l/68000/fat95 - Filesystem handler, 68000+ CPU tier
fat95/l/install95 - Locale installer tool (read/write locale files)
fat95/c/dd - Raw block transfer tool
fat95/c/debug95 - Debug information tool
fat95/c/SetFileSize - File size modification utility
fat95/c/boot95 - Boot partition creation tool
fat95/c/lsfsres - FileSystem.resource entry lister
fat95/c/lsptres - partition.resource entry lister (from ptable.library)

fat95/libs/<small|full>/68020/ptable.library - partition scan/automount library, 68020+
fat95/libs/<small|full>/68000/ptable.library - partition scan/automount library, 68000+

fat95/DOSDrivers/ - Mount list examples

fat95/src/ - Full source code

fat95/locale/ - Localization texts and code pages per language

fat95/LICENSE - GNU LGPL v2.1
