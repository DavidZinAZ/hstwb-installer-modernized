# Publication privacy review — updated October 18, 2026

The existing Git history is **not cleared for publication**. On October 18,
an authenticated GitHub read confirmed that the development repository is still
private. The connected API initially returned 404; the follow-up used the
repository's existing GitHub login. See the
[current readiness report](publication-readiness.md).

## October 18 follow-up

The expanded reachable-history scan covered 1,512 commits and 4,886 text blobs.
It found 372 path-pattern matches across 80 historical blob versions in six
paths. This includes inherited examples, not just private maintainer data; the
five previously identified continuation blob versions with private archive
paths remain reachable. Deleting the feature branches did not remove their
history after merging it into master.

The baseline current-content scan covered 2,141 tracked files and 228 ZIP members
without a pattern match. It did not expand 23 large ZIP members. No token,
private-key or credential-URL patterns matched in the historical text scan;
931 binary blobs and nine large blobs were not expanded/scanned. These limits
prevent a blanket claim that all content is free of personal information.

The repository also intentionally preserves public contributor names, upstream
contact/copyright notices and Git commit identities. Privacy cleanup must not
erase those credits. Screenshots, image contents, LhA payloads and dependencies
still require their own review. This is separate from
[redistribution clearance](../THIRD_PARTY_NOTICES.md).

A visual sample of four legacy screenshots found local Windows account paths
in the two Setup screenshots examined. Only four of the 101 screenshot files
were inspected; do not extend the zero pattern-match result to image pixels.
Replacing or redacting those images and completing the visual review remains
part of publication preparation.

The authenticated GitHub follow-up reviewed 14 PRs and their 14 corresponding
issue records, with no title/body privacy-pattern matches. No issue/PR/commit
comments, release records or workflow artifacts were returned, discussions are
disabled and no remote Git notes were found. Branch rules/protection and secret
scanning/private vulnerability reporting could not be verified (403/404); those
responses are not a claim that every security feature is enabled or disabled.

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

Run `python tools/audit_public_content.py` before publication. Add
`--include-untracked` to check new non-ignored files before staging. For history,
run `python tools/audit_public_content.py --history --summary --output .output/publication-audit.json`.
The history command currently fails on the known findings. Reports contain
locations/categories without matching values, and check that private runtime
directories, settings profiles and history backups are not tracked. ZIP and
NuGet members up to 2 MiB are scanned; larger members are counted as unexpanded.
Compressed LhA contents are not expanded. The automatic content workflow checks
current tracked files only: a passing result does not clear history or licensing.
This supplements review of upstream binary assets; it is not a complete
credential scanner or a license audit.

Runtime testing still uses privately supplied OS media. This review does not qualify the pending Amiga application installs or hardware operation described in [validation status](validation-status.md).
