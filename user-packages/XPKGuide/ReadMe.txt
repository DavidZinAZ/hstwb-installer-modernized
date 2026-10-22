XPKGuide 1.9 by Simon Dick

Default Amiga drawer: SYS:Utilities/XPKGuide (customizable).
Category: Files & Archives.

View plain or supported compressed AmigaGuide documents. Requires Kickstart
2.04+ and amigaguide.library V34+ (not included). Workbench 3.x normally
provides amigaguide.library. Decompression uses T: for temporary files;
allow enough memory or disk space there for the expanded document.

After HstWB finishes, open XPKGuide directly. Run the supplied Install script
if you need to install the preferences program, catalogs or decompression
libraries. The archived manual mentions InstallLibs, but this release ships
an installer named Install. Review library versions before accepting copies:
the archive's xfdmaster.library and xpkmaster.library are historical versions.
Keep newer working libraries already installed by other packages.

PowerPacker, lh and XFD support can use the supplied libraries. XPK-compressed
files also need the appropriate compressor sublibrary, which is not supplied.
CrM.library is not included. The 1.9 history says built-in PCompress support
was removed, despite the older Aminet readme; that format needs XFD support.
No decompression libraries, file associations or startup entries are changed
by HstWB. The original executable icons, guide and Install remain available.

Original distribution is Mailware under AFD-COPYRIGHT: the author requests
a message from users. Read XPKGuide.guide's Copyright Information and the
complete AFD terms; HstWB does not send messages on your behalf.

HstWB extracts the complete original archive into this drawer and pauses
for Enter. An existing drawer containing Upstream-README.txt is retained
without overwriting files. Follow upstream instructions for existing setups.
