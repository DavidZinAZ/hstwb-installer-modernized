# HSTWB-03 MEDIA REFERENCE — AmigaOS 3.2.x Licensed Media Layout

Date: 2026-08-29
Evidence sources: privately retained media inventories, archive listings, and vendor instructions. Licensed source media are supplied by the maintainer; machine names and local storage paths are intentionally omitted.

This reference summarizes repository-safe facts about the operator's licensed
Hyperion AmigaOS 3.2.x media set. It does not reproduce Hyperion documentation
wholesale and does not include copyrighted payloads.

## Archive identities

| Release archive | Version role | SHA256 | MD5 |
|-----------------|--------------|--------|-----|
| AmigaOS-3.2-full.lha | base | 67f531e86ed27e79f645d8fd746199ec5b28bc40a4f197e9197c4eb1a2dd8479 | 89ebf1b01a970cc88e114fa21ea388a6 |
| AmigaOS-3.2.1.lha | update | 7913e148373c83f1117e4077b840d4ae69bdc04ca78e2692c937458c2a4367c8 | 0f69c17125c9dfba37e2901835abbe33 |
| AmigaOS-3.2.2.lha | update | 2dc19a27190e49f51bbf66bd67310e722474161978c151541386ba2b397df281 | fa6fc2c7ff94d42b307f13cc7db36717 |
| AmigaOS-3.2.2.1-Hotfix.lha | update | 5e27885fbbceb306d0dfe5364027e736e5dfbbc9f1ac72b07c4da4546968c0c0 | 18e144ddfbc409980ea306885a12afd2 |
| AmigaOS-3.2.3.lha | update | 41fadb27d74536fbd10b4fac2996c0841881167d4db8ba1083e4f950a3910cfc | f5bf7b0cbcf84d30204ab9182a003c63 |

## Where install/update content lives

- AmigaOS 3.2 base outer archive contains:
  - AmigaOS3.2CD.iso
  - Install3.2.adf
  - Modules ADFs for A1200, A2000, A3000, A4000D, A4000T, A500, A600, CD32
  - Overview3.2.txt and ReadMe1st.txt
- The base outer LHA does not contain a top-level ROMs/ directory.
- Licensed package documentation states the AmigaOS 3.2 CD-ROM contains the
  necessary floppy and ROM images for a complete installation.
- Update archives expose their install content under:
  - Update3.2.1/ADFs/
  - Update3.2.2/ADFs/
  - Update3.2.3/ADFs/
- Update documentation/overview text files also include:
  - Update3.2.x/ChangeSummary
  - Update3.2.x/HowToInstall

## Where ROMs live

| Release | ROM directory inside archive | Notes |
|---------|------------------------------|-------|
| 3.2 | AmigaOS3.2CD.iso | Base package provides ROM images on the CD image; the outer LHA does not list ROM members directly. |
| 3.2.1 | Update3.2.1/ROMs/ | Contains model-specific ROM images. |
| 3.2.2 | Update3.2.2/ROMs/ | Contains model-specific ROM images. |
| 3.2.2.1 | Update3.2.2/ROMs/ | Hotfix bundle reuses the 3.2.2 ROM set. |
| 3.2.3 | Update3.2.3/ROMs/ | Contains model-specific ROM images. |

## ROM versions by release

| Release | Kickstart version |
|---------|-------------------|
| 3.2 | 47.96 |
| 3.2.1 | 47.102 |
| 3.2.2 | 47.111 |
| 3.2.2.1 | 47.111 |
| 3.2.3 | 47.115 |

## Model families represented

The ROM sets include model-specific images for:
- A1200
- A3000
- A4000
- A4000T
- CDTV / A500 / A600 / A2000 combined image

## .rom versus .bin intended use

Licensed Hyperion update documentation consistently states:
- `.bin` files are provided for physical ROM burning.
- `.rom` files should be used for other purposes such as MapROM/emulator use.

This applies to 3.2.1, 3.2.2, and 3.2.3 update packages that include both
`hi.bin`, `lo.bin`, and `.rom` variants.

## Cumulative-update semantics

- 3.2.2 cumulative update contains all 3.2.1 updates.
- 3.2.3 cumulative update contains all 3.2.1 and 3.2.2 updates.
- Cumulative status is taken from Hyperion ChangeSummary documents and does
  not imply automatic source-edge modeling in HstWB beyond what is verified.

## Supported source-version evidence

Qualified accepted-source edges in this project's evidence:
- 3.2 -> 3.2.1
- 3.2 -> 3.2.2
- 3.2.1 -> 3.2.2
- 3.2.2 -> 3.2.2.1
- 3.2.2 -> 3.2.3
- 3.2.1 -> 3.2.3
- 3.2 -> 3.2.3

Not established as a documented edge:
- 3.2.2.1 -> 3.2.3

## 3.2.2.1 packaging behavior

- 3.2.2.1 does not introduce a new Kickstart ROM version.
- The 3.2.2.1 bundle contains the existing 3.2.2 ROM set plus Update3.2.2.1.adf.
- Installation prerequisite remains installed 3.2.2 with `Libs/version.library` 47.4.

## Licensed-media handling rules

- Keep archive identities, filenames, paths, versions, and derived metadata in
  project documentation.
- Do not commit ROM files, ADF files, ISO contents, LHA contents, or extracted
  copyrighted Hyperion documentation into Git.
- Treat operator media directory contents as authoritative evidence for
  recognition and qualification work only.
- Preserve operator-controlled access boundaries for licensed media.
