Amelinium 1.4.0 - browser and Emalinium mail client

Default Amiga drawer: SYS:Tools/Network/Amelinium (customizable).
Category: Network & Communications.

Open Amelinium for the baseline 68000 browser, Amelinium_020 for 68020+,
or Amelinium_020_JS for JavaScript on 68020+. The _040 and _060 variants
require the matching full CPU with FPU and its CPU library; use the _020
build on LC/EC variants without an FPU. Emalinium requires 68020+.
Amelinium_low is the limited OS 1.3 build (no images, downloads or menus).
The complete original archive also contains PPC, MorphOS and AROS builds;
select the program matching your actual platform, not those builds on OS3.

Classic 68k builds require bsdsocket.library V4+ and AmiSSL v5 for HTTPS.
HstWB does not install AmiSSL, change the network stack or launch a browser.
Upstream reports slow operation on 68000 and better usability on 68030+.
JavaScript is disabled by default until enabled for a site.

SECURITY LIMITATION: HTTPS server certificates are NOT verified by this
release. Encryption does not establish the identity of the remote server.
This also affects Emalinium mail passwords. Avoid sensitive logins and mail
credentials. See the complete upstream readme before use.
Some image formats use an external rasterizer; upstream also documents
third-party video search and automatic font/PDF support downloads.

HstWB extracts the original archive, shows the result and pauses for Enter.
Open the chosen executable from this drawer after installation. The archive
has no executable icons: use Workbench Window > Show > All Files, or run
Amelinium (or the CPU-specific filename) from Shell in this drawer. No startup
entries, services, mail accounts or system libraries are configured.
An existing drawer containing Upstream-README.txt is retained without
replacing files; follow upstream update instructions for an existing copy.
