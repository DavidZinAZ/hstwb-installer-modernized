# Commit index through October 18, 2026

This index records all 82 commits reachable from reviewed master 8046156 after
the inherited master baseline 5dfdf48. It includes original upstream development,
continuation work and merges; inclusion is not a claim that the continuation
authored every change. No author email addresses are reproduced here.

The user-facing summary is [CHANGELOG.md](../CHANGELOG.md). Earlier history
remains in Git and the [original project](https://github.com/henrikstengaard/hstwb-installer).
Publication-review changes prepared after 8046156 are summarized in the changelog.

| Date recorded in Git | Commit | Change |
|---|---|---|
| 2022-03-23 | b86fc92 | Add initial fast file system formatter. Fix create rigid disk block dostype and park zone |
| 2022-03-24 | 2d3cfb7 | First working fast file system formatting |
| 2022-03-24 | 632ad30 | Add bitmap extension block to support formatting partitions larger than 50mb |
| 2022-03-26 | 7f9a607 | Refactor fast file system |
| 2022-03-28 | e73ddd2 | Add initial lha reader |
| 2022-04-01 | 6294e0b | Initial port of libarchive, but not working |
| 2022-04-03 | 9558c1d | Lha extract working port of lha for unix with tests |
| 2022-04-04 | f945884 | Add lha crc calculation. Refactor lha |
| 2022-04-11 | 7155ab4 | Fix win32 physical drive get size. Fix wmic reader parser reading physical drive without a size |
| 2022-04-15 | a740016 | Add async to pfs3 code. Implemented remaining code for formatting and fixing runtime errors |
| 2022-04-18 | 60db40d | Pfs3 formatting works runtime, but doesn't create output identical to output on an Amiga |
| 2022-04-19 | 180c378 | Change pfs3 filename size 107 by default. Fix write reserved bitmap block. Fix root block union struct used for small and large idx |
| 2022-04-19 | 3c6f70c | Fix pfs3 date helper write null dates. Fix pfs3 del dir writer and entry date. Fix dir block writer. Fix data sector reader test. Fix rigid disk block writer test. Fix pfs3 root block extension writer |
| 2022-04-19 | 680b152 | Fix root block extension writer |
| 2022-05-03 | 0946559 | Add fast file system mount, list and read files. Add partial implemented pfs3 dir entry reading and do postponed in init. Fix lha unit tests failing periodically due to static variables |
| 2022-05-08 | f5cd1c5 | Add fast file system create and write file |
| 2022-05-12 | 4020c1a | Add directory cache functions, but are untested. Add big endian converter able to work with array offsets for performance |
| 2022-05-13 | 05b1134 | Fix fast file system create dir |
| 2022-05-13 | 3fa587c | Add fast file system rename |
| 2022-05-13 | f87e7d4 | Add remove entry. Update fast file system block writers to seek over unused values. |
| 2022-05-15 | 55d7841 | Add ffs set access and comment |
| 2022-05-16 | d98c5a8 | Add disk object reader to read info files |
| 2022-06-01 | 8c56b89 | Add image data encoder and decoder. Add new icon encoder and decoder |
| 2022-06-06 | ce2eaed | Refactored set first and second image data. Fix minimum icon size to view icons properly with peterk icon library installed. Partially working new icon encoder |
| 2022-06-10 | bc42aa2 | Add fs-uae emulator to raspverry pi |
| 2022-06-10 | 6f5ffcc | Merge branch 'develop' of github.com:henrikstengaard/hstwb-installer into develop |
| 2022-06-20 | 2a36941 | Add new icon ascii encoder supporting 255 color. Update whdload user package to v18.8 |
| 2022-06-21 | 7723dee | Add optimized new icon ascii encoder. Add new icon helper validate method. Clean up new icon tests |
| 2022-06-24 | 15122ba | Add color icon reader |
| 2022-11-20 | 69aa9fc | Fix amiga scripts removing carrier return chars |
| 2022-11-27 | 0132bfd | Fix user package mui install |
| 2022-11-27 | 300c4ad | Add birdie num nums rtg themes and visual prefs user packages |
| 2022-11-28 | b1636fb | Fix install entries wrong arguments error caused by different lha versions. Update lha to v2.15 |
| 2022-11-28 | c82b94b | Rename kickstart roms to kickstart roms for whdload |
| 2026-08-26 | a003d8a | Add AmigaOS 3.2.x release-manifest foundation (HSTWB-08) |
| 2026-08-26 | 3794e66 | Pin release-manifest CLI exit code for malformed JSON (HSTWB-08 QA rework) |
| 2026-08-26 | 6e495db | Add AmigaOS 3.2.x release-manifest foundation (HSTWB-08) |
| 2026-08-26 | c4f8384 | Pin release-manifest CLI exit code for malformed JSON (HSTWB-08 QA rework) |
| 2026-08-27 | d6e4db2 | Add AmigaOS 3.2.x release-manifest host integration (HSTWB-10) |
| 2026-08-28 | 7dc7b7f | Fix PowerShell release manifest loading |
| 2026-08-28 | 8876432 | Add AmigaOS 3.2.x installer release orchestration |
| 2026-08-29 | be484bb | Add AmigaDOS 3.2.x update execution layer |
| 2026-08-29 | 023c624 | Remove unsupported Classes/Modules dispatch from AmigaDOS 3.2.x runner |
| 2026-08-29 | ff9726e | Add host media catalog recognition for AmigaOS 3.2.2, 3.2.2.1 and 3.2.3 |
| 2026-08-29 | 254d419 | Enforce CRLF checkout for AmigaOS 3.2.2/3.2.3 self-install readmes |
| 2026-08-29 | a7d46a8 | Sync self-install helper ADF lists with qualified 3.2.2/3.2.2.1/3.2.3 update disks |
| 2026-08-29 | 4af0045 | Document AmigaOS 3.2.x qualification status |
| 2026-08-29 | b9f015b | Document AmigaOS 3.2.x media facts and corrected ROM prerequisites |
| 2026-10-16 | 2b1d683 | Normalize nested Amiga scripts to LF on Windows |
| 2026-10-16 | 73653c6 | Integrate native-tested AmigaOS 3.2.3 workflow and continuation credits |
| 2026-10-16 | 0a04afd | Merge credited hstwb-updated modernization and native-tested installer workflow |
| 2026-10-16 | f69fb23 | Add shared recursive media library to setup |
| 2026-10-16 | d00a265 | Merge shared recursive OS and Kickstart media library |
| 2026-10-16 | c9481bf | Isolate installation settings and add verified package source updates |
| 2026-10-16 | 7df73cf | Merge installation-local settings and verified package updates |
| 2026-10-17 | 94ab4f7 | Refresh package selection after interrupted downloads and clarify OS target |
| 2026-10-17 | 6cc8d4f | Merge package selection refresh and OS target display |
| 2026-10-17 | 7f732a7 | Set package shell stack and expose WHDLoad extraction progress |
| 2026-10-17 | b47ff96 | Merge WHDLoad stack and extraction diagnostics |
| 2026-10-17 | c37a1cd | Advance installer version and correct package script formatting and assigns |
| 2026-10-17 | 39897cd | Merge 1.6.4 package script corrections |
| 2026-10-17 | c552fea | Add eight Amiga user packages with source metadata and hardware staging |
| 2026-10-17 | a612735 | Merge additional user packages for 1.6.5 |
| 2026-10-17 | 2ad4ab4 | Refresh standard packages from official releases and skip current downloads |
| 2026-10-17 | f1046ad | Merge current standard package releases and download fixes |
| 2026-10-17 | 13aa085 | Sanitize machine paths and document publication privacy review |
| 2026-10-17 | e09a94e | Merge sanitized documentation and publication privacy review |
| 2026-10-17 | be523f2 | Correct package LhA residency and expose WHDLoad pack progress |
| 2026-10-17 | a08770b | Merge WHDLoad Packs archive reliability update |
| 2026-10-17 | 9058423 | Remove two redundant install continuation pauses |
| 2026-10-17 | 394864c | Merge two requested install pause removals |
| 2026-10-17 | 60147e9 | Show WHDLoad Packs progress once per letter group |
| 2026-10-17 | bb6d5f2 | Merge concise WHDLoad Packs progress |
| 2026-10-17 | 0f293ae | Add BestClassicWB standard package adapter |
| 2026-10-17 | 69d8593 | Merge BestClassicWB standard package adapter |
| 2026-10-18 | d15caf3 | Remove package validation continuation pause |
| 2026-10-18 | 1b84673 | Fix media scan hashing large hard disk images |
| 2026-10-18 | ceb4750 | Fix missing Workbench drawer icons for additional user packages |
| 2026-10-18 | a751748 | Add named settings profiles and bump installer to 1.6.11 |
| 2026-10-18 | 8ec1e7d | Merge settings profiles, version 1.6.11 and drawer icon fixes into master |
| 2026-10-18 | 5272103 | Consolidate earlier modernization branch history into master |
| 2026-10-18 | 8046156 | Thank original Amiga software creators and contributors |
