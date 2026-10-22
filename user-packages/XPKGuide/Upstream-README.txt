Short:        An AmigaGuide viewer for crunched files
Author:       sidick@essex.ac.uk (Simon Dick)
Uploader:     sidick essex ac uk (Simon Dick)
Type:         text/hyper
Architecture: m68k-amigaos

Sorry for the delay in releasing this version, but I've been very busy
recently. This will probably be the last version of XPKGuide.

XPKGuide is an AmigaGuide viewer which can view AmigaGuide files which have
been crunched using the following crunchers:

	P-Compress		You don't need any additional library
				files to be able to view files crunched
				using this method.
	CrunchMania		To view CrunchMania files, you need to
				have the CrM.library installed.
	lh.library		(I mean that it supports files crunched
				using LhEncode which was supplied with
				the package on Fish Disk 436). Obviously
				you need the lh.library installed to use
				this (supplied).
	PowerPacker		To view files crunched using PowerPacker,
				you need to have powerpacker.library V35
				or higher installed (supplied).
	Any XPK sublibrary	To view files crunched using XPK, you
				must have both xpkmaster.library (supplied)
				and the appropriate compressor library
				installed.

XPKGuide also uses the xfdmaster.library to decrunch files if it is
available which means that whenever the xfdmaster.library is updated to
support more crunchers then XPKGuide will automatically support them
as well.

XPKGuide is now localised as well, extra catalogs welcome.

I have also written another program called Cruncher which is designed to
complement XPKGuide, it is capable of crunching files using a number of
different crunchers including all of the above crunchers. I have also
written another program called AppDecrunch which can decrunch any files
which have been crunched by the above crunchers.
