Short:        VirusZ III 1.04ß - Antivirus Software
Author:       virusz_xvs@gmx.de (Georg Wittmann)
Uploader:     virusz_xvs gmx de (Georg Wittmann)
Type:         util/virus
Version:      1.04ß
Requires:     util/libs/ReqToolsUsr.lha; util/libs/ReqToolsLib.lha (required on AmigaOS4.x); util/virus/xvslibrary.lha; util/pack/xfdmaster.lha; util/arc/xadmaster.lha (recommended); dev/debug/SegTracker.lha (recommended, only classic AmigaOS); util/libs/DisLib.lha (optional)
Architecture: m68k-amigaos >= 2.0.4

============================================================================
                                 VirusZ III
             Copyright © 1991-1999/2002-2021 by Georg Wittmann
                   Copyright © 1999-2001 by Dirk Stöcker
============================================================================

VirusZ is the last one of the classic antivirus programs for Amiga computers
that still gets updated (from time to time;-).

This  is  the first version that works on classic AmigaOS, MorphOS, AROS and
AmigaOS 4.x, but due to some limitations it's still a beta-release.

This archive no longer contains any of the required libraries, so please get
them from Aminet (locations are mentioned in the header of this textfile).

To  ensure  that you have downloaded an original version of VirusZ and not a
fake, you can use my PGP key (attached to the VirusZ.doc file) together with
the  signatures  included  in  the  archive  for verification.  You can also
download a 100% safe copy of my PGP key from the homepage of Virus Help Team
Denmark (www.vht-dk.dk).

Additionally,  you should compare the file size of your VirusZ copy with the
one  displayed  in the programs 'About' information.  They MUST match if you
didn't modify VirusZ yourself (eg.  with a file compressor).

For  any  comments, bug reports, snapshots and/or if you have found some new
virus, contact the author at the following e-mail address:

virusz_xvs@gmx.de

============================================================================

 1.04ß Changes/Additions since 1.03ß:
	- Not a new author, just a new name: After marriage some years ago,
	  my family name is no longer Hörmann, but Wittmann.
	- Added full recognition of AmigaOS 3.1.4, 3.2, 4.0 and 4.1 and
	  recognition of AROS to startup code and fixed self-test.
	- Fixed several problems in (background) vector check:
	  a. Handles the two 512 kB ROMs correctly when running on AROS.
	  b. Handles the Kickstart modules area of AmigaOS 4.x correctly.
	  c. Uses FindTrackedAddress() instead of SegTracker when running
	     on AmigaOS 4.x for display and snapshots.
	  d. No more accesses to zeropage of m68k processors on AmigaOS 4.x
	     as there seems to be no way to do so without Grim Reaper.
	  e. Added support for special m68k library functions emulator code
	     of AROS and AmigaOS 4.x.
	- Fixed problem in memory monitor: As there exist restricted memory
	  areas under AmigaOS 4.x, you can only have a look at regions that
	  are either registered in FindTrackedAddress() or located inside
	  Kickstart modules.
	- Some preferences of vector check and memory monitor are disabled
	  when running on AmigaOS 4.x as they don't make sense then.
	- Fixed bug in device scanner that lead to wrong results with not
	  disk-based devices when running on AmigaOS 4.x.
	- Added recognition of new AROS and AmigaOS system patches to the
	  vector check (at least for my configurations, feel free to send
	  snapshots of your non-standard vectors).
	- Updated some stuff inside the internal GUI support code:
	  a. Calculation of window border sizes happens in a way compatible
	     with old OS versions and AROS / AmigaOS 4.x now.
	  b. Fixed size calculation of listview gadgets for both AROS and
	     AmigaOS 4.x as they differ a view pixels to older OS versions.
	- Removed SegTracker 45.1 archive from distribution, get the latest
	  release (currently 46.1 written by Thomas Richter) from Aminet
	  instead.
