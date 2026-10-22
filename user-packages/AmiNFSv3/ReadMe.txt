AmiNFSv3 0.2b2

Default Amiga drawer: SYS:Tools/Network/AmiNFSv3 (customizable).

Beta. OS 2.04+, 68000+ and a TCP/IP stack providing bsdsocket.library V4. Configure the Linux/NAS NFSv3 export, server address, export path and UID/GID before mounting. Start with a test share and verify read/write behavior. Keep the example DOSDriver in Storage until configured. Files up to 4 GB; some AmigaDOS programs misreport sizes above 2 GB.

Follow AmiNFSv3.doc to install the handler and configure NFS0.

HstWB extracts the original release files, displays the result and waits for Enter. It does not run setup, start services, mount devices or edit startup settings. Follow Upstream-README.txt after HstWB finishes. An existing destination containing Upstream-README.txt is retained without overwriting files; use upstream update procedures for existing installations.
