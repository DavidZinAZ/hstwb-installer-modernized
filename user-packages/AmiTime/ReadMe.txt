AmiTime 1.1.1

Default Amiga drawer: SYS:Tools/Network/AmiTime (customizable in native user-package assigns).

AmigaOS 2.0+, 68000+, working TCP/IP and reachable NTP server. Configure timezone and startup manually. Package 1.1.1 contains a binary reporting version 1.1. Avoid duplicate time-sync startup tasks if your stack already sets the clock.

Run Execute Install from this drawer to configure network time.

HstWB extracts the original release files, displays the result and waits for Enter. It does not run application setup, start services, mount devices or edit startup settings. After HstWB completes, follow the upstream instructions in Upstream-README.txt. An existing drawer containing Upstream-README.txt is retained without replacing files, protecting configuration and user data; use the upstream update procedure for an existing installation.
