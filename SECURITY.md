# Security reporting

Security fixes are considered against the current maintained source on `master`.
Older tags and inherited tools are not promised ongoing security support.

If GitHub's **Security > Report a vulnerability** option is available, use it to
report sensitive findings privately. Private reporting must be enabled by the
maintainer; this document does not confirm that it is enabled. If it is absent,
open an issue asking for a private reporting channel **without including the
vulnerability details or sensitive files**.

Never post access tokens, private keys, ROM keys, licensed media, personal paths
or installed disk images in a public issue. Include only the minimum redacted
information needed to establish the problem. Rotate any exposed credential
promptly; removing a file or Git branch does not revoke the credential.

The automated privacy check is a limited pattern scan. It is not a complete
security audit, malware scan or license review. See the
[publication review](docs/publication-readiness.md) for current limits.

The inherited .NET/Electron imager under `src/` has known dependency advisories
and is not the maintained desktop/CLI release. Its prerelease workflow is
disabled. See the [dependency review](docs/dependency-review.md) for scope and
affected versions. Do not treat source publication as imager qualification.
