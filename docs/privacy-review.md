# Publication privacy review — October 17, 2026

The development repository remains private. Its current content has been cleaned of identified maintainer machine paths, but **the existing Git history is not cleared for publication**.

## Work completed

- Replaced private evidence/archive locations in the media reference and historical qualification notes with descriptions that omit machine details.
- Replaced an optional test's fixed private media path with `HSTWB_TEST_MEDIA_DIR`, defaulting to the ignored `test-media` directory.
- Made the media-library example an explicitly illustrative location.
- Reviewed tracked source and reachable historical text objects for private paths, token formats, private-key markers and credential-bearing URLs.
- Checked GitHub repository metadata, pull-request descriptions/comments and release notes available through the repository API. The checked text had no private-path or credential-pattern findings. No actual Git notes references were found locally or on the remote.
- Confirmed local settings, test media, generated images/logs and private working notes are ignored and untracked.
- Retained deliberate public GitHub attribution, original authors' copyright notices, public upstream source URLs, generic platform examples and vendor-supplied example configuration. Public identity/credit is not anonymity.

## History finding

Five historical blob versions across three continuation files contain private local paths: the media reference, version-manifest specification, and optional media test. Removing paths from the latest commit does not remove those historical copies. No token/private-key/credential-URL matches were found in the historical text-pattern scan; that is a scoped finding rather than a guarantee about every possible secret.

Commit metadata also retains contributor identities, GitHub no-reply addresses, and older AI-agent attribution. This review does not rewrite original contributors' history or licensing notices.

## Recommended publication route

Publish a clean snapshot of the sanitized current files in a separate public repository, while retaining this development repository and its full history privately. Keep the original HstWB attribution, source link, license and continuation acknowledgments in that snapshot. A source export contains the current files, not the private development history.

Alternatively, sanitizing this existing repository requires a coordinated history rewrite covering all affected branches/references and checks of GitHub pull-request/cached references. That changes commit IDs and may require fresh clones. It requires a separate maintainer decision; no history has been force-pushed and repository visibility has not changed.

GitHub explains the limitations and cached-reference handling in its [sensitive-data removal documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

## Repeatable current-content check

Run `python tools/audit_public_content.py` before publication. It reports file locations and categories without echoing matching values, checks that private runtime directories are untracked, scans tracked bytes and small ZIP members, and returns a failure status for findings. Large ZIP members are reported as unexpanded; compressed LhA contents are not expanded by this tool. This supplements review and provenance/hash checks of upstream binary assets; it is not a complete credential scanner or a license audit.

Runtime testing still uses privately supplied OS media. This review does not qualify the pending Amiga application installs or hardware operation described in [validation status](validation-status.md).
