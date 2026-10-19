# Public release readiness — October 18, 2026

**Status: not cleared to make the existing development repository public.**

Reviewed source baseline: `8046156` (installer 1.6.11). This review covers tracked
working files, reachable local Git history, selected upstream notices and the
release scripts. It is a technical review, not a legal clearance or a claim that
the repository contains no copyrighted material. Copyrighted components are
expected; their distribution must be authorized.

## Findings

| Area | Result | Required next step |
|---|---|---|
| Current privacy pattern scan | 2,141 tracked files and 228 ZIP members scanned; no matches. 23 large ZIP members were not expanded. | Repeat against the final staged publication files, including newly added files. Inspect screenshots and compressed/binary payloads separately. |
| Screenshot sample | Four of the 101 tracked screenshot files were visually inspected. The two sampled legacy Setup screenshots contain a local Windows account path in their pixels. | Review the remaining screenshots and replace or redact path-bearing images before claiming the current tree contains no personal information. The byte-pattern scanner cannot read image text. |
| Reachable Git history | 1,512 commits and 4,886 text blobs scanned. 372 path-pattern matches in 80 historical blob versions across six paths. | Triage historical examples separately from confirmed private development paths. Resolve the confirmed paths before changing this repository's visibility. |
| Historical credentials | No token, private-key or credential-URL patterns matched in scanned historical text. | Run a dedicated secret scanner too; 931 binary blobs and nine large blobs were not expanded/scanned. This does not prove absence of secrets. |
| Local settings and test media | Runtime settings, local test media, generated output and working notes are ignored and untracked at the reviewed baseline. | Keep them outside public exports and release ZIPs. Do not upload the development folder wholesale. |
| Licensing | Original MIT notice and many component notices retained; several legacy components impose separate conditions. | Complete the [third-party review](../THIRD_PARTY_NOTICES.md); resolve corresponding source, key authorization, fonts/artwork and disk-image contents. |
| Bundled archives and dependencies | 104 tracked LhA archives, 31 ZIP archives and 64 NuGet packages identified. | Expand and review component notices and nested payloads; a `licenses/` directory is evidence storage, not a blanket redistribution grant. |
| Changelog | Continuation summary exists through 1.6.11, but was not an exhaustive per-commit history. | Use the revised [changelog](../CHANGELOG.md) and [commit index](commit-history.md); preserve original history privately when exporting a snapshot. |
| Release builder | Replaced original copyright years and omitted continuation documentation. Recursively copied component directories, allowing ignored local files into releases. | Preserve original notices, include public documentation and stage tracked component files only; test complete ZIP/MSI builds before release. |
| GitHub configuration | The connector returned 404; a subsequent read using the existing GitHub login confirmed the repository is private, default branch is master and discussions are disabled. | Keep it private until the blockers are resolved. Branch-protection/ruleset endpoints returned 403; private-reporting/secret-scanning endpoints returned 404. Those settings could not be verified. |
| GitHub discussion/release text | Reviewed 14 PRs and the 14 corresponding issue records; zero comment records, release records or workflow artifacts returned. Title/body pattern checks had no findings. No remote Git notes were returned. | Preserve this scoped result; cached PR Git references and future uploads need separate handling if rewriting history. A metadata scan is not a binary-asset audit. |
| Workflow | Existing manually triggered prerelease workflow builds the inherited imager, not a validated installer release, and references old action versions. | Review/modernize it separately before use; the new content-check workflow does not replace release qualification. |
| Tags | Local inherited tags end at 1.6.3; no local 1.6.11 tag. Remote tag references remain present, but the GitHub releases endpoint returned no release records. | Create a continuation release tag and release notes only after publication gates pass; do not relabel original tags. Include tag history in any cleanup plan. |

Counts are the baseline scan, not promises about later edits. Historical matches
include inherited examples; the count is not a count of leaked secrets. The
earlier review identified five historical versions across three continuation
files with private archive paths. The expanded scan confirms those paths remain
reachable. Detailed redacted results are kept in ignored local output, not
included as a list of personal values here.

## Publication route

The preferred route is a **new, reviewed public snapshot repository**, leaving
the development repository and backups private. Export tracked files only;
preserve the original license, acknowledgments, notices, changelog and upstream
links. A snapshot avoids exposing development history but does **not** resolve
bundled software licensing, binary contents or screenshots by itself.

If retaining this exact repository publicly is required, plan a coordinated
history cleanup covering branches, tags and GitHub references. Changing history
changes commit IDs and may invalidate existing clones and signatures. Deleted
branches do not remove commits reachable from `master`, tags or cached PRs.
Follow [GitHub's sensitive-data removal guidance](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).
No history rewrite, visibility change or public release was performed here.

## Maintainer checklist before publication

- [ ] Resolve the history/publication route and audit the resulting export.
- [ ] Complete component-level redistribution/source review and payload inspection.
- [ ] Review images, screenshots, fonts, artwork and public identity/credit choices.
- [x] Check currently returned issue/PR text, comment/release records and workflow
  artifact count. Recheck before publication; cached Git references remain a
  separate history-cleanup concern.
- [ ] Enable secret scanning/push protection where available, dependency alerts
  and private vulnerability reporting; verify access and branch rules for `master`.
- [ ] Require relevant checks for changes; keep workflow permissions minimal.
- [ ] Review inherited Node/.NET dependencies and release tooling. Dependency
  vulnerability and malware scanning were not performed by this review.
- [ ] Test a fresh clone/export and complete portable/MSI output with private
  licensed test media; inspect the built artifacts, not just the source tree.
- [ ] Create release notes with known limitations, a matching version/tag and
  SHA256 checksums for the exact published artifacts.

GitHub's [repository security quickstart](https://docs.github.com/en/code-security/getting-started/quickstart-for-securing-your-repository)
describes the relevant repository settings. Their availability depends on the
repository and account plan.

## Repeatable checks

```text
python tools/audit_public_content.py
python tools/audit_public_content.py --history --output .output/publication-audit.json
```

The second command should currently fail because of historical path findings.
Reports identify categories, file locations and object IDs without printing
matching values. LhA archives, nested compressed payloads, disk contents, image
pixels, encrypted content and nonstandard secret formats require additional
inspection. Preserve intentional upstream copyright/contact information;
privacy cleanup must not erase attribution.

The new content workflow uses exact commits from the official checkout and
setup-python v7 tags, verified during this review, read-only repository
permissions and no persisted checkout credentials. Scanner regressions cover
redacted reporting, removed historical content, runtime files, untracked files
and ZIP payloads. Release staging tests cover exclusion of ignored local data
and inclusion of notices. Full hosted workflow and ZIP/MSI execution remain
pending; successful local tests do not resolve the publication blockers.

After the preparation edits, the scan including new non-ignored files covered
2,152 files and 740 ZIP/NuGet members, with zero pattern findings and the same
23 large members unexpanded. This broader current-file result does not clear
the screenshot sample or historical findings.
