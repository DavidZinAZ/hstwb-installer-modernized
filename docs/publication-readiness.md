# Public release readiness — October 20, 2026

The maintainer approved publication in a new repository,
`DavidZinAZ/hstwb-installer-modernized`, using the cleaned branch and tag history. The original project credits, license and bundled component
notices are retained. This decision does not assert a complete security or legal
audit of every inherited component.

## Completed preparation

- Removed 29 legacy screenshots containing account paths or local network
  details from the published branches and tags, including their history.
- Replaced confirmed private development paths in three historical text files.
  The targeted verification checked 7,395 reachable objects and found none of
  those private path values or removed screenshot paths in the cleaned copy.
- Updated and verified both GitHub branches and the affected tags. Local
  branches were synchronized and existing working files were preserved.
- Deleted an accidentally added, untracked spreadsheet before publication.
- Kept recovery bundles, old exports, local settings, licensed test media and
  detailed review evidence private under ignored directories. Never upload
  `.output`, `.release`, `settings` or `test-media` wholesale.
- Previous reviewed Gitleaks scans found no secrets within their stated scope.
  The content workflow includes a pinned dedicated secret scanner.
- Preserved font provenance and upstream notices. Disabled the unsupported
  legacy imager's prerelease workflow; see the [dependency review](dependency-review.md).
- The maintainer confirmed the released GUI and CLI ZIPs work. Publication
  preparation does not repeat the full functional test suite.

## Retained upstream content and limits

The latest expanded archive review recorded 24 uninspected members: 23 hard-drive
image payloads exceeded its size limit, and one Directory Opus ADF required disk
filesystem inspection. These are inside 20 tracked archives, all present and
unchanged from the inherited 1.6.3 tag before history cleanup. No problem was
identified in those skipped entries. The maintainer chose to retain them with
their upstream notices and record this coverage limit rather than block
publication on exhaustive disk inspection.

The archive review's private-key marker was a NUL-terminated string in DOpus5's
FTP module, not a complete PEM private key. Pattern scanning does not establish
binary safety, image-pixel privacy or universal redistribution permission. See
[third-party notices](../THIRD_PARTY_NOTICES.md) for component-specific terms.
Commercial OS media, ROM keys, installed personal images and settings are not
authorized public content.

History cleanup changes commit IDs. Other existing clones must use the cleaned
history before contributing; merging old history can reintroduce removed data.
GitHub-managed pull-request references, cached pages and old release assets are
outside the branch/tag rewrite. A follow-up check confirmed that retained
pull-request #14 still reaches the five old private text blob versions and all
29 removed screenshot paths. The old development repository remains private. The public repository is
created separately and receives only the cleaned master branch and tags. Old
pull requests, their managed references, app checkpoints and recovery evidence
are not transferred. This avoids exposing the retained old PR history.
Private recovery backups and app checkpoints are not part of the public push.

## Focused publication checks

Check the final current files, including new non-ignored files, before committing:

```text
python tools/audit_public_content.py --include-untracked --summary
git diff --check
```

The broad historical pattern scanner also matches inherited platform examples;
its match count is not a count of leaked secrets. The completed targeted cleanup
was verified against the specific private values and screenshot paths.

Repository security settings and hosted build results should be checked against
their live state. No claim that every optional GitHub security feature is enabled
is implied by publication. Release downloads remain unsigned previews; retain
their corresponding notices and published checksums.
