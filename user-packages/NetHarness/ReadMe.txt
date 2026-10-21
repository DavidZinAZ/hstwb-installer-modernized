NetHarness 1.18

Default Amiga drawer: SYS:Tools/Network/NetHarness (customizable in native user-package assigns).

AmigaOS 3.0+, 68020+, working TCP/IP. PC controller needs Python 3; GUI/screenshots need Pillow (and Tk for the GUI). Set the controller allowlist before starting; no allowlist accepts any connecting host.

Run Execute Install from this drawer; start NetHarness manually afterward.

HstWB extracts the original release files, displays the result and waits for Enter. It does not run application setup, start services, mount devices or edit startup settings. After HstWB completes, follow the upstream instructions in Upstream-README.txt. An existing drawer containing Upstream-README.txt is retained without replacing files, protecting configuration and user data; use the upstream update procedure for an existing installation.
