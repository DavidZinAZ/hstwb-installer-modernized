# Contributing

Use issues for reproducible bugs and focused pull requests for changes. Include
the installer version, operating system, emulator or Amiga model, expected
behavior, actual behavior and the checks you performed. Separate host test
results from native Amiga and hardware results.

Do not upload ROMs, commercial OS media, personal settings profiles, installed
disk images, passwords, keys or unredacted logs. Replace personal paths and
device identifiers with examples. Report security issues using
[SECURITY.md](SECURITY.md).

Preserve upstream credits and licenses. For a new bundled component, document
its official source, exact version, checksum, authors, redistribution terms,
notices and any corresponding-source obligations. See
[third-party notices](THIRD_PARTY_NOTICES.md).

Before submitting, run `python tools/audit_public_content.py` and the relevant
tests in `tests/`. Windows PowerShell tests include
`tests/test_settings_profiles.ps1` and `tests/test_local_settings_packages.ps1`.
Keep Amiga scripts in LF format. Update the changelog for user-visible changes.
Do not claim native compatibility from a host-only test.

Publication requires the separate [readiness checklist](docs/publication-readiness.md).

Publication checks also include a redacted Gitleaks scan using `.gitleaks.toml`,
the [dependency review](docs/dependency-review.md), and archive inspection.
Do not broadly suppress secret rules to obtain a passing result. Preserve a
finding's location privately, verify it, and limit any exception to the exact
non-secret value and applicable files. Do not paste secret values into issues.
