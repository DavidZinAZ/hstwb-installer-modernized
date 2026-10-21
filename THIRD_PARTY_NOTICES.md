# Third-party software and redistribution

The installer source is provided under the [original MIT license](LICENSE.txt).
That license does **not** relicense the software, firmware, fonts, icons,
artwork, disk templates or other components distributed with it. Their original
copyright and license notices continue to apply.

See [acknowledgments](ACKNOWLEDGMENTS.md) for creators and project links. Thanks
and source links are attribution, not substitutes for redistribution permission.

## Evidence and outstanding checks

| Component | Evidence retained | Public redistribution review |
|---|---|---|
| KickSmash, xSysInfo, DevTest, SDMAC | Package `LICENSE.txt` and `SOURCE.txt`; BSD notices, release URLs and hashes | Preserve notices; check the exact archive and all included components. |
| A4091 Tools | Package license/source notices and corresponding-source archive | Check each extracted component against its original notices. |
| DOpus5 | Package AROS Public License 1.1 and corresponding-source reference | Verify the exact binary's APL source, notices and distribution requirements; do not assume it uses the same license as other packages. |
| ZZ9000 drivers and firmware | Package licenses, release hashes and corresponding-source references; full GPLv3 text added after the drivers' existing notice during this review | Verify the source matching each binary, build material and separately licensed dependencies. A tag link alone is not a completed compliance review. |
| FastFileSystem patch | `user-packages/FastFileSystem v45.16/FFS4516p.readme` | The notice allows redistribution of the patch archive, while the generated filesystem retains the original OS restrictions. Do not publish a patched filesystem or an installed image on the strength of the patch license. |
| icon.library | `user-packages/IconLib v46.4.555/IconLib_46.4.readme`, Distribution section | Contains version-specific commercial/bundling restrictions. Identify the actual shipped variants and intended distribution. |
| MMULib | `user-packages/MMU Libs v47.1/MMULib.readme`, license section | Includes archive-integrity and distribution conditions; check extracted copies and original-archive retention. |
| xadmaster key files | Original `licenses/xadmaster-key.lha`, package readme stating public transfer to Aminet with Dirk Stoecker's permission, and two installed key copies | Both installed copies were verified byte-identical to the preserved freeware archive on October 20, 2026. Retain the archive/readme as provenance; this does not clear the other XAD binaries. |
| Other legacy utilities, WHDLoad, MUI, libraries and drivers | Package readmes and archives in `licenses/` and `user-packages/` | A complete component-by-component review remains required. Freeware and shareware do not automatically permit every form of redistribution. |
| Fonts, icons, screenshots and themes | `fonts/`, `icons/`, `screenshots/` and package artwork | TopazPlus now has its complete upstream README, revision and verified matching SHA256 in `fonts/`; the author states GPL-FE terms. Preserve this evidence and finish license/source review. Remaining artwork needs its own provenance review. |
| Prepared image templates | Compressed archives in `images/` | Inspect their contents and filesystem payloads before publication; compressed bytes and filenames alone do not establish absence of licensed OS content. |
| Downloaded standard packages | Upstream project notices and local package archives | Not tracked in this repository by default. Audit separately before using a release build that includes downloaded packages. |

These rows are an inventory of review obligations, not a statement that every
listed component is cleared. Do not remove original notices while addressing a
finding. If a component cannot be cleared, prefer an upstream download step or
an installer-only distribution, subject to its terms, rather than bundling it.

## User-supplied media

Commercial AmigaOS, Workbench and Kickstart media, ROM keys, completed installed
images and personal configuration files must not be included in a public release
without specific authorization. Media hashes and installer support do not grant
redistribution rights. Test with your own licensed media privately.

## Corresponding source

For components under the GPL, review the applicable version and distribution
method against the actual binaries. Preserve notices and supply the required
license and corresponding source using a compliant method. For GPLv3 object-code
distribution, see [section 6](https://www.gnu.org/licenses/gpl-3.0.html#section6).
This project has not completed that review for every bundled binary.
