# Dependency review — October 20, 2026

OSV was queried for 1,262 exact dependency versions: 1,176 npm and 86 NuGet.
Advisories were returned for 78 versions (77 npm, one NuGet), referencing 150
distinct advisory identifiers. Identifiers can describe related issues; this
is not a count of independent exploitable vulnerabilities. The query used
public names and versions only. The redacted local review evidence is ignored.

All queried package sources are under the inherited `src/` imager tree.
The maintained desktop/CLI packaging scripts do not stage that tree. This
does not audit Windows/.NET Framework, emulator installations, native Amiga
payloads, or their libraries (including bundled AmiSSL). No resolved .NET
lockfile was available: NuGet coverage is direct references and preserved
`.nupkg` archives, not the full transitive restore graph.

The legacy imager prerelease workflow is disabled and the source is marked as
unsupported pending dependency modernization and testing. The current desktop
ZIP remains as confirmed working by the maintainer. No automatic dependency
upgrades were applied to the legacy imager during publication cleanup.

## Affected exact versions

| Ecosystem | Package | Version | OSV advisories |
| --- | --- | --- | --- |
| NuGet | SixLabors.ImageSharp | 2.1.1 | [GHSA-2cmq-823j-5qj8](https://osv.dev/vulnerability/GHSA-2cmq-823j-5qj8), [GHSA-5x7m-6737-26cr](https://osv.dev/vulnerability/GHSA-5x7m-6737-26cr), [GHSA-63p8-c4ww-9cg7](https://osv.dev/vulnerability/GHSA-63p8-c4ww-9cg7), [GHSA-65x7-c272-7g7r](https://osv.dev/vulnerability/GHSA-65x7-c272-7g7r), [GHSA-g85r-6x2q-45w7](https://osv.dev/vulnerability/GHSA-g85r-6x2q-45w7), [GHSA-gwg2-r3hj-4w44](https://osv.dev/vulnerability/GHSA-gwg2-r3hj-4w44), [GHSA-j3p4-wp97-rph4](https://osv.dev/vulnerability/GHSA-j3p4-wp97-rph4), [GHSA-j9gm-c75j-xc9q](https://osv.dev/vulnerability/GHSA-j9gm-c75j-xc9q), [GHSA-jjfr-hcj7-qf5w](https://osv.dev/vulnerability/GHSA-jjfr-hcj7-qf5w), [GHSA-qxrv-gp6x-rc23](https://osv.dev/vulnerability/GHSA-qxrv-gp6x-rc23), [GHSA-rxmq-m78w-7wmc](https://osv.dev/vulnerability/GHSA-rxmq-m78w-7wmc), [GHSA-wmxv-xphr-5c9g](https://osv.dev/vulnerability/GHSA-wmxv-xphr-5c9g) |
| npm | @babel/core | 7.16.12 | [GHSA-4x5r-pxfx-6jf8](https://osv.dev/vulnerability/GHSA-4x5r-pxfx-6jf8) |
| npm | @babel/helpers | 7.16.7 | [GHSA-968p-4wvh-cqc8](https://osv.dev/vulnerability/GHSA-968p-4wvh-cqc8) |
| npm | @babel/plugin-transform-modules-systemjs | 7.16.7 | [GHSA-fv7c-fp4j-7gwp](https://osv.dev/vulnerability/GHSA-fv7c-fp4j-7gwp) |
| npm | @babel/runtime | 7.16.7 | [GHSA-968p-4wvh-cqc8](https://osv.dev/vulnerability/GHSA-968p-4wvh-cqc8) |
| npm | @babel/runtime-corejs3 | 7.16.8 | [GHSA-968p-4wvh-cqc8](https://osv.dev/vulnerability/GHSA-968p-4wvh-cqc8) |
| npm | @babel/traverse | 7.16.10 | [GHSA-67hx-6x53-jw92](https://osv.dev/vulnerability/GHSA-67hx-6x53-jw92) |
| npm | @tootallnate/once | 1.1.2 | [GHSA-vpq2-c234-7xj6](https://osv.dev/vulnerability/GHSA-vpq2-c234-7xj6) |
| npm | ajv | 6.12.6 | [GHSA-2g4f-4pwh-qvx6](https://osv.dev/vulnerability/GHSA-2g4f-4pwh-qvx6) |
| npm | ajv | 8.9.0 | [GHSA-2g4f-4pwh-qvx6](https://osv.dev/vulnerability/GHSA-2g4f-4pwh-qvx6) |
| npm | async | 2.6.3 | [GHSA-fwr7-v2mv-hh25](https://osv.dev/vulnerability/GHSA-fwr7-v2mv-hh25) |
| npm | body-parser | 1.19.1 | [GHSA-qwcr-r2fm-qrc7](https://osv.dev/vulnerability/GHSA-qwcr-r2fm-qrc7), [GHSA-v422-hmwv-36x6](https://osv.dev/vulnerability/GHSA-v422-hmwv-36x6) |
| npm | brace-expansion | 1.1.11 | [GHSA-3jxr-9vmj-r5cp](https://osv.dev/vulnerability/GHSA-3jxr-9vmj-r5cp), [GHSA-6j4f-fj2g-mc7p](https://osv.dev/vulnerability/GHSA-6j4f-fj2g-mc7p), [GHSA-f886-m6hf-6m8v](https://osv.dev/vulnerability/GHSA-f886-m6hf-6m8v), [GHSA-mh99-v99m-4gvg](https://osv.dev/vulnerability/GHSA-mh99-v99m-4gvg), [GHSA-q2hr-2g5m-vwhr](https://osv.dev/vulnerability/GHSA-q2hr-2g5m-vwhr), [GHSA-qhr7-859c-m2p7](https://osv.dev/vulnerability/GHSA-qhr7-859c-m2p7), [GHSA-rgw5-rvv9-x895](https://osv.dev/vulnerability/GHSA-rgw5-rvv9-x895), [GHSA-v6h2-p8h4-qcjw](https://osv.dev/vulnerability/GHSA-v6h2-p8h4-qcjw) |
| npm | braces | 3.0.2 | [GHSA-grv7-fg5c-xmjg](https://osv.dev/vulnerability/GHSA-grv7-fg5c-xmjg), [GHSA-vfj7-8cjw-p6xm](https://osv.dev/vulnerability/GHSA-vfj7-8cjw-p6xm) |
| npm | browserslist | 4.19.1 | [GHSA-73wf-gq98-2v4g](https://osv.dev/vulnerability/GHSA-73wf-gq98-2v4g), [GHSA-c83g-rgw3-j3cx](https://osv.dev/vulnerability/GHSA-c83g-rgw3-j3cx) |
| npm | colord | 2.9.2 | [GHSA-2wm5-q62r-hmrv](https://osv.dev/vulnerability/GHSA-2wm5-q62r-hmrv) |
| npm | compression | 1.7.4 | [GHSA-vc2v-76pw-4v95](https://osv.dev/vulnerability/GHSA-vc2v-76pw-4v95) |
| npm | cookie | 0.4.1 | [GHSA-pxg6-pf52-xh8x](https://osv.dev/vulnerability/GHSA-pxg6-pf52-xh8x) |
| npm | cross-spawn | 6.0.5 | [GHSA-3xgq-45jj-v275](https://osv.dev/vulnerability/GHSA-3xgq-45jj-v275) |
| npm | cross-spawn | 7.0.3 | [GHSA-3xgq-45jj-v275](https://osv.dev/vulnerability/GHSA-3xgq-45jj-v275) |
| npm | ejs | 3.1.6 | [GHSA-ghr5-ch3p-vcr6](https://osv.dev/vulnerability/GHSA-ghr5-ch3p-vcr6), [GHSA-phwq-j96m-2c2q](https://osv.dev/vulnerability/GHSA-phwq-j96m-2c2q) |
| npm | eventsource | 1.1.0 | [GHSA-6h5x-7c5m-7cr7](https://osv.dev/vulnerability/GHSA-6h5x-7c5m-7cr7) |
| npm | express | 4.17.2 | [GHSA-qw6h-vgh9-j6wx](https://osv.dev/vulnerability/GHSA-qw6h-vgh9-j6wx), [GHSA-rv95-896h-c2vc](https://osv.dev/vulnerability/GHSA-rv95-896h-c2vc) |
| npm | flatted | 3.2.4 | [GHSA-25h7-pfq9-p65f](https://osv.dev/vulnerability/GHSA-25h7-pfq9-p65f), [GHSA-rf6f-7fwh-wjgh](https://osv.dev/vulnerability/GHSA-rf6f-7fwh-wjgh) |
| npm | follow-redirects | 1.14.7 | [GHSA-cxjh-pqwp-8mfp](https://osv.dev/vulnerability/GHSA-cxjh-pqwp-8mfp), [GHSA-jchw-25xp-jwwc](https://osv.dev/vulnerability/GHSA-jchw-25xp-jwwc), [GHSA-pw2r-vq6v-hr8c](https://osv.dev/vulnerability/GHSA-pw2r-vq6v-hr8c), [GHSA-r4q5-vmmm-2653](https://osv.dev/vulnerability/GHSA-r4q5-vmmm-2653) |
| npm | form-data | 3.0.1 | [GHSA-fjxv-7rqg-78g4](https://osv.dev/vulnerability/GHSA-fjxv-7rqg-78g4), [GHSA-hmw2-7cc7-3qxx](https://osv.dev/vulnerability/GHSA-hmw2-7cc7-3qxx) |
| npm | http-proxy-middleware | 2.0.2 | [GHSA-4www-5p9h-95mh](https://osv.dev/vulnerability/GHSA-4www-5p9h-95mh), [GHSA-64mm-vxmg-q3vj](https://osv.dev/vulnerability/GHSA-64mm-vxmg-q3vj), [GHSA-9gqv-wp59-fq42](https://osv.dev/vulnerability/GHSA-9gqv-wp59-fq42), [GHSA-c7qv-q95q-8v27](https://osv.dev/vulnerability/GHSA-c7qv-q95q-8v27) |
| npm | ip | 1.1.5 | [GHSA-2p57-rm9w-gvfp](https://osv.dev/vulnerability/GHSA-2p57-rm9w-gvfp), [GHSA-78xj-cgh5-2h22](https://osv.dev/vulnerability/GHSA-78xj-cgh5-2h22) |
| npm | js-yaml | 3.14.1 | [GHSA-2883-xcg3-v3hh](https://osv.dev/vulnerability/GHSA-2883-xcg3-v3hh), [GHSA-52cp-r559-cp3m](https://osv.dev/vulnerability/GHSA-52cp-r559-cp3m), [GHSA-5p4m-2wfm-xmqj](https://osv.dev/vulnerability/GHSA-5p4m-2wfm-xmqj), [GHSA-h67p-54hq-rp68](https://osv.dev/vulnerability/GHSA-h67p-54hq-rp68), [GHSA-mh29-5h37-fv8m](https://osv.dev/vulnerability/GHSA-mh29-5h37-fv8m) |
| npm | js-yaml | 4.1.0 | [GHSA-2883-xcg3-v3hh](https://osv.dev/vulnerability/GHSA-2883-xcg3-v3hh), [GHSA-52cp-r559-cp3m](https://osv.dev/vulnerability/GHSA-52cp-r559-cp3m), [GHSA-5p4m-2wfm-xmqj](https://osv.dev/vulnerability/GHSA-5p4m-2wfm-xmqj), [GHSA-h67p-54hq-rp68](https://osv.dev/vulnerability/GHSA-h67p-54hq-rp68), [GHSA-mh29-5h37-fv8m](https://osv.dev/vulnerability/GHSA-mh29-5h37-fv8m) |
| npm | json5 | 1.0.1 | [GHSA-9c47-m6qq-7p4h](https://osv.dev/vulnerability/GHSA-9c47-m6qq-7p4h) |
| npm | json5 | 2.2.0 | [GHSA-9c47-m6qq-7p4h](https://osv.dev/vulnerability/GHSA-9c47-m6qq-7p4h) |
| npm | loader-utils | 1.4.0 | [GHSA-3rfm-jhwj-7488](https://osv.dev/vulnerability/GHSA-3rfm-jhwj-7488), [GHSA-76p3-8jx3-jpfq](https://osv.dev/vulnerability/GHSA-76p3-8jx3-jpfq), [GHSA-hhq3-ff78-jv3g](https://osv.dev/vulnerability/GHSA-hhq3-ff78-jv3g) |
| npm | loader-utils | 2.0.2 | [GHSA-3rfm-jhwj-7488](https://osv.dev/vulnerability/GHSA-3rfm-jhwj-7488), [GHSA-76p3-8jx3-jpfq](https://osv.dev/vulnerability/GHSA-76p3-8jx3-jpfq), [GHSA-hhq3-ff78-jv3g](https://osv.dev/vulnerability/GHSA-hhq3-ff78-jv3g) |
| npm | loader-utils | 3.2.0 | [GHSA-3rfm-jhwj-7488](https://osv.dev/vulnerability/GHSA-3rfm-jhwj-7488), [GHSA-hhq3-ff78-jv3g](https://osv.dev/vulnerability/GHSA-hhq3-ff78-jv3g) |
| npm | lodash | 4.17.21 | [GHSA-f23m-r3pf-42rh](https://osv.dev/vulnerability/GHSA-f23m-r3pf-42rh), [GHSA-r5fr-rjxr-66jc](https://osv.dev/vulnerability/GHSA-r5fr-rjxr-66jc), [GHSA-xxjr-mmjv-4gpg](https://osv.dev/vulnerability/GHSA-xxjr-mmjv-4gpg) |
| npm | micromatch | 4.0.4 | [GHSA-952p-6rrq-rcjv](https://osv.dev/vulnerability/GHSA-952p-6rrq-rcjv) |
| npm | minimatch | 3.0.4 | [GHSA-23c5-xmqv-rm74](https://osv.dev/vulnerability/GHSA-23c5-xmqv-rm74), [GHSA-3ppc-4f35-3m26](https://osv.dev/vulnerability/GHSA-3ppc-4f35-3m26), [GHSA-7r86-cg39-jmmj](https://osv.dev/vulnerability/GHSA-7r86-cg39-jmmj), [GHSA-f8q6-p94x-37v3](https://osv.dev/vulnerability/GHSA-f8q6-p94x-37v3) |
| npm | minimist | 1.2.5 | [GHSA-xvch-5gv4-984h](https://osv.dev/vulnerability/GHSA-xvch-5gv4-984h) |
| npm | moment | 2.29.1 | [GHSA-8hfj-j24r-96c4](https://osv.dev/vulnerability/GHSA-8hfj-j24r-96c4), [GHSA-wc69-rhjr-hc9g](https://osv.dev/vulnerability/GHSA-wc69-rhjr-hc9g) |
| npm | nanoid | 3.2.0 | [GHSA-28wg-ghj8-5hjv](https://osv.dev/vulnerability/GHSA-28wg-ghj8-5hjv), [GHSA-2v37-7h3g-55p8](https://osv.dev/vulnerability/GHSA-2v37-7h3g-55p8), [GHSA-mwcw-c2x4-8c55](https://osv.dev/vulnerability/GHSA-mwcw-c2x4-8c55), [GHSA-xwg4-73v4-xw9w](https://osv.dev/vulnerability/GHSA-xwg4-73v4-xw9w) |
| npm | node-forge | 1.2.1 | [GHSA-2328-f5f3-gj25](https://osv.dev/vulnerability/GHSA-2328-f5f3-gj25), [GHSA-2r2c-g63r-vccr](https://osv.dev/vulnerability/GHSA-2r2c-g63r-vccr), [GHSA-554w-wpv2-vw27](https://osv.dev/vulnerability/GHSA-554w-wpv2-vw27), [GHSA-5gfm-wpxj-wjgq](https://osv.dev/vulnerability/GHSA-5gfm-wpxj-wjgq), [GHSA-5m6q-g25r-mvwx](https://osv.dev/vulnerability/GHSA-5m6q-g25r-mvwx), [GHSA-65ch-62r8-g69g](https://osv.dev/vulnerability/GHSA-65ch-62r8-g69g), [GHSA-86w9-cpqp-85rv](https://osv.dev/vulnerability/GHSA-86w9-cpqp-85rv), [GHSA-cfm4-qjh2-4765](https://osv.dev/vulnerability/GHSA-cfm4-qjh2-4765), [GHSA-ppp5-5v6c-4jwp](https://osv.dev/vulnerability/GHSA-ppp5-5v6c-4jwp), [GHSA-q67f-28xg-22rw](https://osv.dev/vulnerability/GHSA-q67f-28xg-22rw), [GHSA-x4jg-mjrx-434g](https://osv.dev/vulnerability/GHSA-x4jg-mjrx-434g) |
| npm | nth-check | 1.0.2 | [GHSA-rp65-9cf3-cjxr](https://osv.dev/vulnerability/GHSA-rp65-9cf3-cjxr) |
| npm | on-headers | 1.0.2 | [GHSA-76c9-3jph-rj3q](https://osv.dev/vulnerability/GHSA-76c9-3jph-rj3q) |
| npm | path-to-regexp | 0.1.7 | [GHSA-37ch-88jc-xwx2](https://osv.dev/vulnerability/GHSA-37ch-88jc-xwx2), [GHSA-9wv6-86v2-598j](https://osv.dev/vulnerability/GHSA-9wv6-86v2-598j), [GHSA-rhx6-c78j-4q9w](https://osv.dev/vulnerability/GHSA-rhx6-c78j-4q9w) |
| npm | path-to-regexp | 1.8.0 | [GHSA-9wv6-86v2-598j](https://osv.dev/vulnerability/GHSA-9wv6-86v2-598j) |
| npm | picomatch | 2.3.1 | [GHSA-3v7f-55p6-f55p](https://osv.dev/vulnerability/GHSA-3v7f-55p6-f55p), [GHSA-c2c7-rcm5-vvqj](https://osv.dev/vulnerability/GHSA-c2c7-rcm5-vvqj) |
| npm | postcss | 7.0.39 | [GHSA-6g55-p6wh-862q](https://osv.dev/vulnerability/GHSA-6g55-p6wh-862q), [GHSA-7fh5-64p2-3v2j](https://osv.dev/vulnerability/GHSA-7fh5-64p2-3v2j), [GHSA-fxqj-rqcc-2cmp](https://osv.dev/vulnerability/GHSA-fxqj-rqcc-2cmp), [GHSA-qx2v-qp2m-jg93](https://osv.dev/vulnerability/GHSA-qx2v-qp2m-jg93), [GHSA-r28c-9q8g-f849](https://osv.dev/vulnerability/GHSA-r28c-9q8g-f849) |
| npm | postcss | 8.4.5 | [GHSA-6g55-p6wh-862q](https://osv.dev/vulnerability/GHSA-6g55-p6wh-862q), [GHSA-7fh5-64p2-3v2j](https://osv.dev/vulnerability/GHSA-7fh5-64p2-3v2j), [GHSA-fxqj-rqcc-2cmp](https://osv.dev/vulnerability/GHSA-fxqj-rqcc-2cmp), [GHSA-qx2v-qp2m-jg93](https://osv.dev/vulnerability/GHSA-qx2v-qp2m-jg93), [GHSA-r28c-9q8g-f849](https://osv.dev/vulnerability/GHSA-r28c-9q8g-f849) |
| npm | postcss-selector-parser | 6.0.9 | [GHSA-rj75-hqrm-r3gf](https://osv.dev/vulnerability/GHSA-rj75-hqrm-r3gf) |
| npm | proxy-addr | 2.0.7 | [GHSA-jqcg-44mw-7w3h](https://osv.dev/vulnerability/GHSA-jqcg-44mw-7w3h) |
| npm | qs | 6.9.6 | [GHSA-4mjr-xmp4-gh2g](https://osv.dev/vulnerability/GHSA-4mjr-xmp4-gh2g), [GHSA-6rw7-vpxm-498p](https://osv.dev/vulnerability/GHSA-6rw7-vpxm-498p), [GHSA-hrpp-h998-j3pp](https://osv.dev/vulnerability/GHSA-hrpp-h998-j3pp), [GHSA-w7fw-mjwx-w883](https://osv.dev/vulnerability/GHSA-w7fw-mjwx-w883) |
| npm | rollup | 2.66.1 | [GHSA-gcx4-mw62-g8wm](https://osv.dev/vulnerability/GHSA-gcx4-mw62-g8wm), [GHSA-mw96-cpmx-2vgc](https://osv.dev/vulnerability/GHSA-mw96-cpmx-2vgc) |
| npm | semver | 5.7.1 | [GHSA-c2qf-rxjj-qqgw](https://osv.dev/vulnerability/GHSA-c2qf-rxjj-qqgw) |
| npm | semver | 6.3.0 | [GHSA-c2qf-rxjj-qqgw](https://osv.dev/vulnerability/GHSA-c2qf-rxjj-qqgw) |
| npm | semver | 7.0.0 | [GHSA-c2qf-rxjj-qqgw](https://osv.dev/vulnerability/GHSA-c2qf-rxjj-qqgw) |
| npm | semver | 7.3.5 | [GHSA-c2qf-rxjj-qqgw](https://osv.dev/vulnerability/GHSA-c2qf-rxjj-qqgw) |
| npm | send | 0.17.2 | [GHSA-m6fv-jmcg-4jfg](https://osv.dev/vulnerability/GHSA-m6fv-jmcg-4jfg) |
| npm | serialize-javascript | 4.0.0 | [GHSA-5c6j-r48x-rmvq](https://osv.dev/vulnerability/GHSA-5c6j-r48x-rmvq) |
| npm | serialize-javascript | 6.0.0 | [GHSA-5c6j-r48x-rmvq](https://osv.dev/vulnerability/GHSA-5c6j-r48x-rmvq), [GHSA-76p7-773f-r4q5](https://osv.dev/vulnerability/GHSA-76p7-773f-r4q5), [GHSA-qj8w-gfj5-8c6v](https://osv.dev/vulnerability/GHSA-qj8w-gfj5-8c6v) |
| npm | serve-static | 1.14.2 | [GHSA-cm22-4g7w-348p](https://osv.dev/vulnerability/GHSA-cm22-4g7w-348p) |
| npm | shell-quote | 1.7.3 | [GHSA-395f-4hp3-45gv](https://osv.dev/vulnerability/GHSA-395f-4hp3-45gv), [GHSA-w7jw-789q-3m8p](https://osv.dev/vulnerability/GHSA-w7jw-789q-3m8p) |
| npm | source-map-js | 1.0.2 | [GHSA-68fv-2mgg-jv7q](https://osv.dev/vulnerability/GHSA-68fv-2mgg-jv7q) |
| npm | sprintf-js | 1.0.3 | [GHSA-hp3w-g68c-fv3c](https://osv.dev/vulnerability/GHSA-hp3w-g68c-fv3c) |
| npm | svgo | 1.3.2 | [GHSA-2p49-hgcm-8545](https://osv.dev/vulnerability/GHSA-2p49-hgcm-8545), [GHSA-4vpr-x523-8j87](https://osv.dev/vulnerability/GHSA-4vpr-x523-8j87), [GHSA-w27v-7q3p-w38r](https://osv.dev/vulnerability/GHSA-w27v-7q3p-w38r) |
| npm | svgo | 2.8.0 | [GHSA-2p49-hgcm-8545](https://osv.dev/vulnerability/GHSA-2p49-hgcm-8545), [GHSA-4vpr-x523-8j87](https://osv.dev/vulnerability/GHSA-4vpr-x523-8j87), [GHSA-w27v-7q3p-w38r](https://osv.dev/vulnerability/GHSA-w27v-7q3p-w38r), [GHSA-xpqw-6gx7-v673](https://osv.dev/vulnerability/GHSA-xpqw-6gx7-v673) |
| npm | terser | 5.10.0 | [GHSA-4wf5-vphf-c2xc](https://osv.dev/vulnerability/GHSA-4wf5-vphf-c2xc) |
| npm | tough-cookie | 4.0.0 | [GHSA-72xf-g2v4-qvf3](https://osv.dev/vulnerability/GHSA-72xf-g2v4-qvf3) |
| npm | url-parse | 1.5.6 | [GHSA-8v38-pw62-9cw2](https://osv.dev/vulnerability/GHSA-8v38-pw62-9cw2), [GHSA-hgjh-723h-mx2j](https://osv.dev/vulnerability/GHSA-hgjh-723h-mx2j), [GHSA-jf5r-8hm2-f872](https://osv.dev/vulnerability/GHSA-jf5r-8hm2-f872) |
| npm | uuid | 8.3.2 | [GHSA-w5hq-g745-h8pq](https://osv.dev/vulnerability/GHSA-w5hq-g745-h8pq) |
| npm | webpack | 5.67.0 | [GHSA-38r7-794h-5758](https://osv.dev/vulnerability/GHSA-38r7-794h-5758), [GHSA-4vvj-4cpr-p986](https://osv.dev/vulnerability/GHSA-4vvj-4cpr-p986), [GHSA-8fgc-7cc6-rx7x](https://osv.dev/vulnerability/GHSA-8fgc-7cc6-rx7x), [GHSA-hc6q-2mpp-qw7j](https://osv.dev/vulnerability/GHSA-hc6q-2mpp-qw7j) |
| npm | webpack-dev-middleware | 5.3.0 | [GHSA-g84c-rxfj-3j2c](https://osv.dev/vulnerability/GHSA-g84c-rxfj-3j2c), [GHSA-wr3j-pwj9-hqq6](https://osv.dev/vulnerability/GHSA-wr3j-pwj9-hqq6) |
| npm | webpack-dev-server | 4.7.3 | [GHSA-4v9v-hfq4-rm2v](https://osv.dev/vulnerability/GHSA-4v9v-hfq4-rm2v), [GHSA-79cf-xcqc-c78w](https://osv.dev/vulnerability/GHSA-79cf-xcqc-c78w), [GHSA-9jgg-88mc-972h](https://osv.dev/vulnerability/GHSA-9jgg-88mc-972h), [GHSA-f5vj-f2hx-8m93](https://osv.dev/vulnerability/GHSA-f5vj-f2hx-8m93), [GHSA-m28w-2pqf-7qgj](https://osv.dev/vulnerability/GHSA-m28w-2pqf-7qgj), [GHSA-mx8g-39q3-5c79](https://osv.dev/vulnerability/GHSA-mx8g-39q3-5c79) |
| npm | websocket-driver | 0.7.4 | [GHSA-mp7j-qc5w-4988](https://osv.dev/vulnerability/GHSA-mp7j-qc5w-4988), [GHSA-xv26-6w52-cph6](https://osv.dev/vulnerability/GHSA-xv26-6w52-cph6) |
| npm | word-wrap | 1.2.3 | [GHSA-j8xg-fqg3-53r7](https://osv.dev/vulnerability/GHSA-j8xg-fqg3-53r7) |
| npm | ws | 7.5.6 | [GHSA-3h5v-q93c-6h6q](https://osv.dev/vulnerability/GHSA-3h5v-q93c-6h6q), [GHSA-96hv-2xvq-fx4p](https://osv.dev/vulnerability/GHSA-96hv-2xvq-fx4p) |
| npm | ws | 8.4.2 | [GHSA-3h5v-q93c-6h6q](https://osv.dev/vulnerability/GHSA-3h5v-q93c-6h6q), [GHSA-58qx-3vcg-4xpx](https://osv.dev/vulnerability/GHSA-58qx-3vcg-4xpx), [GHSA-96hv-2xvq-fx4p](https://osv.dev/vulnerability/GHSA-96hv-2xvq-fx4p) |
| npm | yaml | 1.10.2 | [GHSA-48c2-rrv3-qjmp](https://osv.dev/vulnerability/GHSA-48c2-rrv3-qjmp) |

## Repeatable review

Run from the repository root with Python 3 and network access:

```text
python tools/audit_dependencies.py --output .output/dependency-audit.json
```

The command returns a failure status when advisories are present, or raises
an error if the query cannot complete. It follows OSV pagination. A clean
result would cover the stated inventory only, not binary safety or malware.
New advisories can change these results. See the [OSV API documentation](https://google.github.io/osv.dev/post-v1-querybatch/).
