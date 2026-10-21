# Publication privacy review — October 20, 2026

The maintainer approved publication after removing the identified private
development paths and screenshots from branch and tag history.

## Completed cleanup

- Sanitized private paths in historical versions of the media reference,
  version-manifest specification and optional media test: three text files.
- Removed 29 legacy screenshots containing account paths or local network
  details throughout the published branch and tag histories.
- Verified the cleaned copy across 7,395 reachable objects against the exact
  private values and removed screenshot paths, then verified the GitHub refs.
- Synchronized the local branches while preserving existing working files.
- Removed an accidental untracked spreadsheet from the publication files.
- Kept local settings, licensed media, private review evidence and recovery
  backups outside the tracked publication files.

The earlier 372 historical pattern matches included repeated versions and
inherited examples. They were not 372 separate private files. Earlier reports
describing the confirmed private paths and screenshots as still present in
branch/tag history are superseded by this cleanup.

Public contributor identities, original copyright notices and upstream credits
are intentionally retained. Privacy cleanup is not removal of authorship.

## Scope and limits

Previous reviewed Gitleaks scans found no secrets within their stated scope.
Pattern checks do not inspect every image pixel, disk filesystem, binary or
nonstandard secret format. The maintainer accepted retaining unchanged inherited
disk templates and the Directory Opus disk archive with these limits recorded.
See the [readiness report](publication-readiness.md) and
[third-party notices](../THIRD_PARTY_NOTICES.md).

The rewrite covers published branches and tags. A follow-up check confirmed
GitHub's retained pull-request #14 reference still reaches all five identified
private text blob versions and the 29 removed screenshot paths. These remain
outside the branch/tag cleanup. Cached pages and old release assets are also
not deleted by that action. Repository publication is pending an explicit
maintainer decision about this remaining exposure or removal by GitHub.
Local recovery bundles and app checkpoints remain private and must not be
uploaded. Contributors using older clones should start from cleaned history;
merging old commits can reintroduce removed content.

## Repeatable current-content check

```text
python tools/audit_public_content.py --include-untracked --summary
```

Reports use categories and locations rather than matching private values.
The general history scan includes inherited platform examples and local app
references; use the specific cleaned publication refs when verifying this
targeted history removal. Functional testing with privately supplied licensed
media is separate from this privacy review.
