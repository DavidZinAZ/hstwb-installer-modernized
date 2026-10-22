Short:        Web browser with JS + HTML mail client
Author:       Juen/APX+NAH+R3D (Pawel Nowak)
Uploader:     biuro cdlabel info (Pawel Nowak)
Type:         comm/www
Version:      1.4.0
Architecture: m68k-amigaos; ppc-amigaos; ppc-morphos; ppc-powerup; ppc-warpup; i386-aros

Amelinium 1.4.0 - web browser AND mail client for classic Amiga
===============================================================

Support me: http://juen.in/support

Always new version here: http://juen.in

A browser AND a mail client. The archive holds two programs that share one
rendering engine, so a message with HTML and CSS looks the same in your inbox
as a page does in the browser:

  Amelinium  - the web browser
  Emalinium  - the mail client (POP3 / IMAP / SMTP). It is not a plain-text
               reader: a message is laid out by the SAME engine as a web page.

Requirements:
- bsdsocket.library v4+ (works with IMPBOX bsdsocket.library!)
- AmiSSL v5 for HTTPS support (without that still http:// sites works fine)
- On AROS you need NEITHER of the two: the AROS builds carry their own TCP
  through the system and TLS 1.2 / 1.3 built into the executable, so HTTPS
  works with nothing else installed.
- On AmigaOS 4 (PowerPC) it is the same as on 68k: bsdsocket from the system
  and AmiSSL v5 for HTTPS.
- On a PPC card in a classic Amiga (Blizzard PPC / CyberStorm PPC under OS 3.x)
  the PowerUP (_PUP) and WarpOS (_WOS) builds carry their own TLS 1.2 / 1.3,
  like the AROS ones, so HTTPS needs no AmiSSL. The PowerUP builds set up
  their own stack. The WarpOS builds cannot, and need a BIGGER STACK than
  the shell gives by default:

      stack 600000        (from Shell, once per shell)
      STACK=600000        (in the icon's Tool Types, for Workbench)

  With less than 256 KB a WarpOS build says so and exits instead of stopping
  halfway through a deep page.


  The AROS builds (all four: i386, i386 ABI v0, x86_64 and aarch64) need NO
  extra library at all - not AmiSSL, and nothing to copy into LIBS:. Only the
  AROS system itself and its bsdsocket.library. Their TLS (1.2 and 1.3) is
  BUILT INTO the executable, so the download is one file and there is no
  library drawer to install.

  Why: AmiSSL has no AROS release at all. What ships for Amiga is m68k HUNK
  code, and an AROS system loads ELF - so the choice was a built-in TLS
  or no https at all on that machine.

Third-party code in the AROS and PPC-card builds:
  Mbed TLS 3.6.7 (https://www.trustedfirmware.org/projects/mbed-tls/) is
  compiled into the AROS, PowerUP (_PUP) and WarpOS (_WOS) executables,
  unmodified. It is dual-licensed Apache-2.0 OR GPL-2.0-or-later - you may
  take it under either. The full text is in mbedtls-LICENSE.txt next to this
  readme. The 68k and AmigaOS 4 builds do not contain it; they use AmiSSL.

!! HTTPS is encrypted but the server's CERTIFICATE IS NOT VERIFIED - i do not
   check who is on the other end. Treat it as protection against passive
   eavesdropping, not against an attacker who can redirect your traffic. The
   same applies to Emalinium's mail passwords.

Builds:
- Amelinium           - 68000 (works on all Amigas, slowest)
- Amelinium_020       - 68020+
- Amelinium_040       - 68040 WITH FPU (not 68EC040/68LC040)
- Amelinium_060       - 68060 WITH FPU, fastest (not 68EC060/68LC060)
- Amelinium_low       - AmigaOS 1.3 (Kickstart 34+). No images, no downloads
                        and NO MENU BAR - so no settings, bookmarks, tabs or
                        About.
- Amelinium_020_JS    - 68020+ with built-in JavaScript
- Amelinium_040_JS    - 68040 WITH FPU, with built-in JavaScript
- Amelinium_060_JS    - 68060 WITH FPU, with built-in JavaScript
- Emalinium           - the mail client (any 68020+)

  The 040 and 060 builds use the maths coprocessor, so they need a full
  68040 or 68060. On a 68EC040, 68LC040, 68EC060 or 68LC060 - the versions
  sold without a coprocessor - use Amelinium_020 or Amelinium_020_JS, which
  never use one. This only changes how fast JavaScript runs; page layout
  uses no floating point at all. Like any 68040/68060 program, they also
  need the CPU's own 68040.library or 68060.library in LIBS: - it supplies
  the instructions the chip leaves to software.
- Amelinium_AROS_i386 - AROS on i386 (32-bit x86 PC), with JavaScript
- Amelinium_AROS_x86_64 - AROS on x86_64 (64-bit PC, ABI v11), with JavaScript
- Amelinium_AROS_aarch64 - AROS on 64-bit ARM (Raspberry Pi 3/4/5), with
                        JavaScript
- Amelinium_AROS_i386_v0 - AROS ABI v0 on i386 - the classic 32-bit line
                        from axrt.org, with JavaScript. ABI v0 and ABI v1
                        are DIFFERENT systems: take the file that matches
                        the AROS you installed.
- Emalinium_AROS_i386 - the mail client on AROS i386 (ABI v1)
- Emalinium_AROS_x86_64 - the mail client on AROS x86_64 (ABI v11)
- Emalinium_AROS_aarch64 - the mail client on AROS 64-bit ARM
- Emalinium_AROS_i386_v0 - the mail client on AROS ABI v0 (i386)
- Amelinium_OS4       - AmigaOS 4.x on PowerPC
- Emalinium_OS4       - the mail client on AmigaOS 4.x (PowerPC)
- Amelinium_PUP       - PowerUP: a PPC card in a classic Amiga (Blizzard PPC /
                        CyberStorm PPC under OS 3.x). With JavaScript and
                        HTTPS. Needs no AmiSSL - TLS is built in.
- Emalinium_PUP       - the mail client on the same PowerUP cards
- Amelinium_MOS       - MorphOS (PowerPC), with JavaScript and HTTPS. Needs no
                        AmiSSL - TLS is built in. A young target, so it may
                        not be perfect yet.
- Emalinium_MOS       - the mail client on MorphOS
- Amelinium_WOS       - WarpOS on the same PPC cards (Blizzard PPC /
                        CyberStorm PPC under OS 3.x). With JavaScript and
                        HTTPS. Needs no AmiSSL - TLS is built in. A young
                        target, so it may not be perfect yet.
- Emalinium_WOS       - the mail client on WarpOS

Known issues:
- JavaScript: in the _JS builds. DOM scripting works, and so do jQuery,
  Prototype, script.aculo.us and Lightbox - including a jQuery packed with
  the Dean Edwards packer. Very heavy applications (youtube.com, the
  Cloudflare "checking your browser" page) load but can take minutes, and
  the Cloudflare check does not complete yet. A page whose scripts do a
  great deal of work will be slow: the interpreter is not fast, and that is
  the honest limit.
- <canvas>: scripts can draw on it (shapes, lines, text, gradients,
  shadows, pictures) and read its pixels back, but the canvas itself is not
  shown on the page yet - its space stays empty.
- rotate() / skew() / matrix() are parsed but not drawn (translate() and
  scale() are)
- Some pages may still render incorrectly - please report them
- Slow on 68000, usable on 68030+ (faster from cache)

If the browser will not start after an update:
  The update keeps the previous program next to it as <name>.old, so rename
  that back over <name> and you are running the old version again. Up to
  1.1.1 an update download that stalled could be installed even though it
  was incomplete, which leaves a file the system cannot load; from 1.1.2 the
  download is checked and a broken one is refused.

Command line:
  Amelinium [URL] [options]

  -screen WxH[xD]  open an own screen of that size, skipping the mode
                   requester - e.g. `-screen 1024x768x24` on an RTG card or
                   `-screen 1280x512` on AGA. Picks the deepest mode the size
                   offers when D is left out. This is the quickest way to a
                   usable window on a big screen.
  -aga             640x512 8-bitplane PAL screen, no requester
  -wb              open on the Workbench screen
  -js              run page scripts everywhere, ignoring the per-site list.
                   By default scripts are OFF until you allow a site, because
                   one advertising bundle can exhaust the machine's memory.
  -ttf             use TrueType fonts, downloading them first if they are not
                   in PROGDIR:ttfonts yet. Same as the `ttf` toolbar button,
                   but usable from a script or an icon.
  -proxy-host H
  -proxy-port P    send everything through an HTTP proxy

The same settings are available from the icon's Tool Types: URL, PROXYHOST,
PROXYPORT, AGA, WB.

Keyboard shortcuts:
- Up/Down       - scroll
- Shift+Up/Down - page scroll (a few lines)
- Space         - page down (most of the visible area)
- Backspace     - page up
- PageUp/PageDown - page up / down (PC-style keyboards)
- Home/End      - top / bottom of page
- Ctrl+Up/Down  - top / bottom of page (keyboards without Home/End, A600)
- Amiga = / -   - zoom in / out (also on the Page menu)
- Esc           - stop loading / stop a runaway script / close
- F5            - reload
- Amiga-C/X/V   - copy / cut / paste: the form field you are typing in, the
                  text you selected on the page, or the URL bar
- Amiga-T / W   - new tab / close tab (also on the Tabs menu)
- Ctrl+click    - open link in a background tab
- Middle-click  - open link in a background tab (3-button mouse)
- Shift+click   - open link in a new tab and go there
- Amiga-B / F   - back / forward
- Amiga-H       - home page
- Amiga-L       - jump to the address bar (selects what is there, so you can
                  just type the next address)
- Amiga-G       - go to the address in the bar
- Amiga-S       - save this page
- Amiga-/       - find on page
- Amiga-.       - random page
- Amiga-?       - about

Pictures:
  GIF, JPEG, PNG, BMP and ICO are decoded on the Amiga, by the browser
  itself. Decoded pictures are cached on disk, so a second visit paints
  them without decoding again.

  !! SVG, WebP and AVIF FILES cannot be decoded here - there is no code on
  this machine that reads them. (An <svg> written directly into the page is
  different: Amelinium draws that itself and nothing leaves the machine.)
  Those files go out to a PUBLIC RASTERISER
  (images.weserv.nl), which converts them to PNG and sends that back. The
  address of the picture therefore leaves your machine and reaches a third
  party, which is worth knowing: it is the price of seeing an icon set that
  a modern site ships as SVG. Everything else is fetched straight from the
  site. Turning images off in the Settings menu stops both.

Video:
  In the 040 and 060 builds and in the AROS, AmigaOS 4 and PPC-card builds, a
  <video> with an MP4 file (H.264 picture, AAC sound) plays: click the picture
  or the triangle on the player bar to start, click again to pause, click the
  groove to jump. Sound goes through Paula, or through AHI when chosen in
  Settings -> Sound output. The picture is decoded in the
  background and shown as often as the machine manages - Settings -> Video
  playback chooses how often it tries, and "Key frames only" (the default)
  costs least. The 68000 and 020 builds do not play video.

  A YouTube watch address (youtube.com/watch?v=..., youtu.be/...) opens in
  Amelinium's own player page, because the player on youtube.com itself is
  far too heavy to be usable here. Settings -> Video quality chooses 144p (the default),
  240p, 360p or sound only; a smaller picture decodes much faster. In the
  builds with JavaScript, 144p and 240p play in full, fetched the way
  YouTube's own embedded player fetches them - this runs YouTube's player
  code, which is downloaded once (about 2 MB) and again whenever YouTube
  changes it. Without JavaScript (Amelinium_040, Amelinium_060) a long film
  comes as 360p whatever you choose, and the page says so. The page links
  back to the original youtube.com page as well.

  WWW -> Video -> "YouTube search (Invidious)" opens a search page that renders
  without JavaScript. Opening one of its videos asks whether to play it in
  Amelinium's own player.

  !! Playing a YouTube video asks YouTube's servers for the stream, and the
  search page is run by a third party (inv.nadeko.net) - so what you look for
  and what you watch reaches them. Nothing is sent until you open such a page.

PDF:
  In the builds with JavaScript a PDF file opens in a built-in viewer, like
  in Firefox: a toolbar with Previous / Next, the page number, zoom and
  Download stays at the top, and pages are drawn as you scroll to them. The
  viewer is pdf.js and lives in the pdfjs drawer next to the program. If
  that drawer is missing (for example after "Install now" updated only the
  program), the browser downloads it by itself from juen.in the first time
  you open a PDF (about 1.4 MB, once). In the builds without JavaScript, or
  when that download fails, a PDF is saved to disk instead (the status bar
  says why).
  WWW -> PDF lists Amiga user guides (A500 to A4000, CD32) from Aminet.
  A PDF page is drawn by JavaScript, so it takes a while on a slow machine.

Fonts:
  Amelinium reads TrueType fonts ITSELF - it opens the .ttf file, reads the
  glyph outlines and rasterises them with its own scanline renderer. That
  path needs no FPU, no maths libraries and no external library at all, so
  TrueType text works on every Amiga from a plain 68000 upwards. It is on by
  default whenever the font files are present; the TT button turns it off.
  The AA button switches edge smoothing, which needs a truecolor screen -
  on a palette screen there is nothing to blend with, so the button is greyed.

  A site's own fonts are used too, when it offers them as TrueType through
  @font-face - that is how icon fonts draw real symbols instead of empty
  boxes. Each file is fetched once into the ttfonts drawer and reused on
  later visits. Web fonts are frequently SUBSETS: a font served for a Latin
  page often carries no Greek, no Cyrillic and no Polish letters, so any
  character the site's font does not have is taken from a built-in face
  instead of being left blank. Only that character changes face, the rest of
  the word keeps the site's font.

Acknowledgments:
  Liberation Fonts (Red Hat, SIL OFL 1.1) - metric-compatible Arial /
    Times / Courier replacements.
  DejaVu Sans (DejaVu Fonts project, Bitstream Vera license) - used
    when CSS names Verdana or Tahoma; matches their wider metrics
    where Liberation Sans (Arial-metric) would be too narrow.
  Noto Emoji (Google, SIL OFL 1.1) - monochrome emoji font.
  AmiSSL by Oliver Roberts - TLS for HTTPS.
  stb_image (public domain) - PNG/GIF decoding.
  TJpgDec by ChaN (BSD-style, 2021) - tiny JPEG decoder with
    scale-on-decode (1/2, 1/4, 1/8). http://elm-chan.org/fsw/tjpgd/
    Replaces stb_image for JPEG - same input, half the RAM and
    much faster on oversized photo thumbnails.
  Amiga Core Fonts for the Web (Amiga Information Center, 2000) -
    bitmap fallback when TT is unavailable.
  Helix AAC decoder (RealNetworks, RPSL 1.0) - decodes the AAC
    soundtrack of an MP4 movie. Present only in the 040 and 060
    executables and on AROS / PPC / OS4; the 68000 and 020 ones do
    not carry it. Sources: github.com/pschatzmann/arduino-libhelix
  libavc H.264 decoder (The Android Open Source Project, originally by
    Ittiam Systems; Apache-2.0) - decodes the picture of an MP4 movie.
    Present in the same executables as the Helix decoder. License text:
    libavc-LICENSE.txt next to this readme.
    Sources: github.com/ittiam-systems/libavc
  minimp3 by lieff (public domain, CC0) - plays MP3 internet radio;
    same executables as the Helix decoder. github.com/lieff/minimp3
  pdf.js 3.11.174 by Mozilla (Apache 2.0) - the PDF viewer of the
    JavaScript builds, in the pdfjs drawer with its LICENSE file.
    github.com/mozilla/pdf.js

History:

  1.4.0
  - Pages built with Gravity Forms show their forms laid out as intended:
    style rules of the form "not inside this element" are now understood
  - Pages built with the Spectra (UAGB) WordPress blocks show their
    sections at full width instead of squeezed to their content
  - Carousels and sliders shown before their script starts (slick and
    others) lay their slides out in a row instead of squeezing them
  - Pictures inside page headers and overlays positioned with
    position:absolute or position:fixed (often the site logo) are now
    downloaded and shown
  - Invisible tracking frames (width="0" height="0", e.g. Google Tag
    Manager) no longer push the whole page down
  - Grid layouts: columns written as minmax(0, 1fr) share the width
    equally, and side columns with a minimum width no longer make the
    grid wider than the page
  - Flexible boxes: a later rule that only sets flex-grow no longer
    cancels an earlier flex-basis, so rows of columns stay side by side
  - Columns holding a box with overflow:hidden are no longer laid out
    too narrow (its content now counts when column widths are worked out)
  - Style rules written as "A > B C" no longer apply to elements nested
    deeper than the rule says (text on some sites came out too large)
  - Pictures given a width in percent together with a maximum height (rows
    of client logos and similar) keep their width instead of shrinking
  - "inherit" now works for order, flex and the position offsets (top, left,
    right, bottom, inset), so a desktop rule that undoes a phone layout (the
    search box in shop headers) is no longer ignored
  - Grid layouts inside flexible boxes (drop-down menus and similar) no
    longer come out with rows far taller than their content
  - Pictures inside links styled "display:block; text-decoration:none" (a
    very common way to write a banner link) are downloaded and shown
    instead of staying as small placeholders
  - Product carousels shown before their script starts no longer spill the
    hidden slides into the page below them
  - Responsive pictures whose small placeholder is embedded in the page
    (Laravel/Spatie sites) keep their real shape instead of turning into a
    huge square
  - Grid items aligned to the start of their cell no longer wrap their text
    when they have padding (comparison tables and feature lists)
  - The tiny transparent placeholder picture used by lazy-loading scripts on
    many sites is shown as transparent instead of as a broken picture with
    its description text spread across the page
  - Style rules that exclude several kinds of parent element ("article but
    not main, not single") are now applied instead of ignored
  - Search boxes built as Bootstrap "input groups" inside drop-downs and
    side panels are as wide as intended instead of squeezed
  - Roundcube webmail: clicking a message shows it in the preview pane
    instead of an "403 Forbidden" error page, and the browser no longer
    crashes right after logging in
  - Element searches that many jQuery-based sites run inside one part of
    the page now find their elements, so toolbars and menus built that way
    (Roundcube and others) are put together as intended
  - Icons drawn with style rules marked !important (toolbar buttons) appear
    above their labels as intended instead of beside them
  - Pictures inside frames report a failed download to the page, so a
    replacement picture (such as a contact placeholder) is shown
  - A picture whose replacement also fails to load no longer freezes the
    browser
  - SVG pictures requested by page scripts load instead of failing
  - SVG diagrams styled with an embedded <style> sheet show their borders,
    rounded corners, centred and bold labels, and are no longer cut off
    halfway or blurred when larger than 512 pixels
  - Pages that load many documents into a frame one after another (e.g. a
    webmail preview pane) keep working: a frame's old document now gives
    its slot and its memory back, so the preview no longer stops loading
    after about thirty messages
  - Web pages see your real time zone (e.g. Europe/Warsaw), worked out from
    the country and GMT offset in your Locale settings, so webmail and other
    sites show message times correctly
  - Emalinium: the mouse wheel scrolls on AmigaOS 4 too
  - Secure page requests now carry the Fetch Metadata headers every modern
    browser sends, so sites such as Facebook no longer answer with an error
    page right away
  - JavaScript generators have the standard prototype chain, so scripts that
    extend iterators (Facebook's, among others) no longer stop at start-up
  - Scripts that wait for a page's own script files to finish loading now
    hear about it, and style elements report their style sheet to scripts -
    the Facebook mobile sign-in page shows its content instead of a blank page
  - Pages that encrypt the password in the browser before sending it (such as
    the Facebook sign-in) can do so now (Web Crypto AES-GCM), so the login is
    actually sent instead of failing with "the request couldn't be processed"
  - Tab moves to the next form field also on pages whose scripts react to every
    key press (it used to stay in the same field)
  - Amelinium_low fits on a single OFS floppy again (unused code and a
    second copy of the HTML entity tables are left out)
  - Opening a collapsible section (such as the file list on a GitHub release
    page) re-checks only that section instead of the styles of the whole page
  - Forums built with nested tables (e.g. safir.amigaos.se) show the
    poster's name and avatar column at its proper width instead of
    squeezing it so the name runs over the post
  - Boxes moved with position:relative and a top or bottom given in percent
    no longer jump far down the page when their parent's height comes from
    its content (they stay in place, as in other browsers)
  - Square and fixed-ratio buttons (aspect-ratio with a minimum height) are
    as wide as they are tall instead of as narrow as their icon
  - Style rules that pick elements by the position of the one before them
    ("everything after the third banner") are applied instead of ignored,
    so grids that show only their first few items no longer show all of them
  - Padding written as calc() with both a percentage and pixels (such as
    calc(50% - 5px)) is applied instead of dropped to zero, so picture tiles
    sized this way are no longer flat
  - Boxes with overflow:hidden placed after a full-width floating header
    move below it instead of being drawn over it, and their width in percent
    is taken from the whole column rather than from the space beside a float
  - Empty tables respect min-width and max-width (drop-down menus built as
    tables, such as an empty cart menu), and max-width no longer squeezes a
    table narrower than its longest word
  - Submit buttons placed with position:absolute (the search button of many
    WordPress sites) are as wide as their label instead of collapsing to a
    sliver
  - word-break and overflow-wrap set in the same rule no longer cancel each
    other, so long words can break where the page allows it and tables in
    narrow side columns fit again
  - File uploads tell the server what kind of file is being sent (image/png,
    image/jpeg and so on), so sites that name the stored file after it no
    longer save pictures that cannot be opened
  - File fields look like they do in other browsers: a "Choose File" button
    with "No file chosen" or the chosen file's name beside it, instead of a
    text box with a cut-off hint
  - Style rules whose parent condition is an attribute value containing a
    dot (for example data-name="website.components.image") are applied, so
    pictures on Squarespace sites are no longer missing
  - Elements with more than 24 attributes keep all of them: style rules and
    scripts asking about a later one (often a data-... attribute) now see
    it, so slideshow arrows and similar controls are no longer hidden
  - Grid rows given a minimum height (minmax(24px, auto) and similar) are at
    least that tall even when their content is smaller or missing, so
    Squarespace page sections are no longer squashed
  - @supports (--name: value) is true, as in other browsers, so style blocks
    that check for custom property support are applied
  - Style rules with :first-child (or similar) on two parent elements are
    applied, so the first section of Squarespace pages starts below the
    header instead of underneath it
  - Page titles and tab labels show an unknown entity such as &foo; as
    written, like the page text does, instead of a question mark
  - Old pages without a doctype lay out like in other browsers: the default
    gap above and below a paragraph or heading that starts or ends a table
    cell or the page is left out, while gaps set by the page stay
  - A broken end tag such as </> is no longer shown as text on the page
  - max-height and min-height with calc(100% - 54px) and similar mixed
    values limit the height as they should, so scrolling side panels no
    longer grow to their full content
  - Pictures limited with max-height: 100% shrink to fit their box (keeping
    their shape) in all layouts, so product thumbnails in shop carousels are
    no longer cut off or stretched
  - Style rules naming attributes with an escaped dot (Livewire's
    [wire\:loading\.delay] and similar) apply, so loading spinners on such
    sites stay hidden
  - Spacing utilities with a dot in the class name (Tailwind's space-y-1.5
    and similar) apply, so list items no longer run into each other
  - A declaration marked !important wins over a later ordinary one in the
    same rule, as it should
  - content: none in a later rule removes a ::before or ::after added by an
    earlier one, so dropdown buttons no longer show a stray arrow, and
    :before/:after written with one colon weigh as pseudo-elements
  - Grid items aligned to the end or centre of their cell (justify-self)
    account for their padding, border and margins, so buttons in such
    grids no longer stick out to the right
  - A size written wrongly (a number without a unit, an unknown word) is
    ignored instead of cancelling a correct size given just before it
  - text-indent on the first line next to a float is kept, so hidden site
    descriptions beside a logo no longer push the header down
  - Boxes stretched across a vertical flex layout keep their side margins,
    so page-builder sections (Beaver Builder and similar) no longer stick out
    past their column
  - An empty table (including the common clearfix ::after) keeps the margin
    of the block before it inside the parent, as in other browsers
  - Grid columns written as minmax(auto, 448px) share the free space with
    their neighbours instead of always taking the full 448px, so product
    pages with a picture beside the details get the right proportions
  - Addresses with a user name and password (a URL containing login credentials) log in
    to password-protected sites, and the password is not shown in the
    address bar
  - Requests to a server on a non-standard port name the port in the Host
    header, as other browsers do
  - JavaScript modules may export async functions, and Uint8Array.from()
    and friends accept strings and other iterables
  - Pictures drawn by scripts on a <canvas> are shown on the page (until now
    they were computed but never displayed), so canvas games and charts
    appear
  - Typed arrays store their numbers in little-endian order like every other
    browser, so pictures that scripts draw pixel by pixel have the right
    colours
  - The site icon is fetched from the same port as the page
  - JavaScript generators resume correctly inside nested loops, if/else,
    switch and try/catch/finally: values are no longer skipped, a finally
    block runs once instead of at every yield, and return() runs it
  - Regular expressions in scripts understand Unicode property classes
    such as \p{L} and \p{Script=Cyrillic}, named back-references and
    new RegExp(re, "g"), and string.normalize() really converts text, so
    searching with accents and Polish letters stripped works
  - Numbers formatted by scripts (prices, percentages, "1.2K" counters)
    follow the language rules of real browsers, e.g. Polish "1234,50 zl"
    instead of "zl1 234,50", and round the way they do
  - Very large numbers convert to BigInt exactly, and text trimming and
    number parsing treat non-breaking and other Unicode spaces as spaces
  - WebP pictures that a server labels as JPEG are recognised by their
    content and shown, instead of the alternative text
  - JavaScript: JSON.parse rejects malformed strings, JSON.stringify reports
    circular structures and skips symbols, and Map.groupBy and the new Set
    methods (union, intersection, difference, isSubsetOf, ...) are available
  - CSS: min(), max() and clamp() with percentages work in padding (picture
    cards that collapsed to a thin line keep their proportions)
  - CSS: break-before and break-after: column start a new column in
    multi-column layouts
  - CSS: sibling selectors with a negated class (.a:not(.b) + .c) or two
    classes (.a.b + .c) match; collapsed dropdown menus stay closed
  - Pages that redirect or reload themselves after a delay (<meta refresh>
    with a time) go to their target when the time is up instead of
    staying where they are

  1.3.9
  - New Page -> Forget JavaScript sites: turns JavaScript off again on every
    site where it was switched on (Clear cache keeps that list on purpose)
  - Video on 68040 and 68060 decodes almost twice as fast: the H.264
    decoder's motion compensation, inverse transform and colour
    interpolation are now written for these processors (68k assembly), and
    the 68060 build gets the faster-compiled decoder - the picture is
    exactly the same as before
  - WordPress sites (elektrowoz.pl and countless others) no longer keep the
    browser busy for many minutes while loading: the emoji check every
    WordPress page runs, and scripts that change classes on the page, are
    now many times faster; working out page styles on such sites (many
    classes on every element) takes about half the time on 68k
  - Photo galleries no longer make the browser decode full-size pictures
    nobody is looking at: backgrounds of hidden elements are not downloaded
    (as in every browser), and pictures loaded by page scripts are decoded
    only when they appear on screen
  - Fixed: an element could keep its old look when a page script changed
    its class and added something inside it in the same step
  - Fixed: style rules for elements inside an element whose class name
    contains an escaped dot (as utility CSS frameworks write them) now apply
  - AmigaOS 4: video sound now uses AHI by default, and the browser no
    longer hangs when it closes after playing a video; if audio.device
    does not respond, playback switches to AHI instead of staying silent
  - Images in sliders and carousels that load on demand (Flickity and
    others - e.g. the header photo of elektrowoz.pl articles) now appear;
    page scripts can listen to events with an object, as in every browser
  - Search fields driven by page scripts (e.g. file search on
    morphos-storage.net) react to Enter: key handlers set as a
    property or an HTML attribute now receive key presses
  - YouTube: fixed a crash (or an endless "Running page scripts...") when
    opening videos - the current YouTube player made the browser loop
    forever while preparing the stream
  - YouTube sound keeps playing when the browser window is not active (for
    example while you read in another window) - before, it stopped once the
    buffered part ran out and started again only after a click on the window
  - Downloading a file from a page without JavaScript now asks where to
    save it first and writes the file straight there, with no temporary
    copy (pages with JavaScript still start at once, because their
    download links can expire within seconds)
  - Pages whose scripts keep restyling the page (React shops and listings
    such as olx.pl) no longer run out of memory for page elements and end
    up blank; script-built style sheets also use far less memory
  - JavaScript: the contents of <template> elements are kept when a page
    fills, copies or reads them (olx.pl search results)
  - JavaScript: lists formatted in parts (Intl.ListFormat formatToParts) -
    the olx.pl search results page no longer ends in an error page
  - Drop-down menus that open on mouse-over (WordPress themes such as
    Hueman - the FORUM menu on elektrowoz.pl) now open: both the
    stylesheet rule that shows them and the theme script that animates
    them were not working
  - JavaScript: support for new.target - scripts using it (for example many
    error classes in modern sites) no longer fail to load as a whole
  - Pages that load many scripts at once (large shop and classified sites)
    no longer lose the scripts beyond the first sixteen
  - Typing into a form field now tells the page's scripts about it, so
    search boxes and forms built with React and similar frameworks see
    what you typed (the olx.pl search box, for one)
  - Fixed form fields that a page stretches to a taller box (Roundcube
    webmail login and many Bootstrap forms): clicking in the middle of
    the field did not put the cursor there, and the grey hint text
    vanished as soon as the page moved the cursor into a field
  - Shading laid over pictures (the dark fade behind headlines on car and
    news sites such as bmw.pl and interia.pl) is now see-through: on
    RTG it blends with the picture, on chipset screens it is drawn as a
    checker pattern - before it covered the picture with a solid band
  - Pages whose scripts build a very large document (volkswagen.pl) no
    longer end up empty - the browser ran out of room for page elements
  - Pages styled by scripts (styled-components and similar - volkswagen.pl)
    keep all their styles: large script-built style sheets were cut off,
    and style sheets a script removed or replaced kept applying
  - JavaScript: fixed generator functions with several yield expressions
    in one statement, plural rules with decimal digits, and the lastIndex
    of a regular expression after replace and match - together they kept
    modern sites such as olx.pl from starting their scripts at all
  - Fixed a crash when going on to another page after visiting a site
    whose scripts replace built-in JavaScript functions (olx.pl and many
    sites with analytics agents)
  - Fixed carousels and tile rows built on a CSS grid (many Shopify shops)
    collapsing into a single full-width column
  - Fixed product pages and other layouts that name their grid areas in the
    CSS grid shorthand stacking every part in one column
  - Fixed text laid over a picture (banners, slideshows, newsletter boxes in
    many shop themes) appearing below the picture instead of on it
  - Long CSS declarations that use variables are no longer dropped - they
    broke the layout of many modern sites, and pages now also use less memory
  - Grid rows now grow correctly for items spanning several rows and for
    grids with a minimum height
  - Pages that load their stylesheets in the background (WordPress themes
    such as Divi, and speed-up plugins) now get those stylesheets
  - Fixed inline handlers such as onclick and onerror not knowing which
    element they belong to
  - Fixed rows of columns built by Wix and similar site builders coming out
    equally wide, and items with a fractional size share (flex: 0.5) not
    growing at all
  - Fixed links whose whole tile is made clickable by the stylesheet turning
    into big blocks that covered the page
  - Fixed pages built with a modern utility stylesheet (Tailwind and the
    like) giving every element the same stray gap - whole pages came out
    far too tall
  - A new tab now opens an empty page instead of the start page, so the
    plus button reacts at once
  - The start page got a narrow right-hand column with the author's other
    Amiga software and hardware, and a short note on where the browser
    stands - still no images, so it loads as fast as before
  - Fixed a crash on pages whose scripts build long text while the machine
    is running out of memory - the browser now stops the page scripts and
    says so, instead of failing
  - Pages whose stylesheet starts with a framework directive (Tailwind and
    the like) now get the rest of that stylesheet instead of losing its
    first rule
  - WebP, SVG and AVIF images a site serves from its own server now load
    - the image converter was refusing them
  - Shopify shops and other sites that scale their whole layout from one
    setting are no longer rendered about one and a half times too large
  - Icons and labels inside small buttons are sized as in other browsers
    instead of spilling out of the button
  - Fixed pages that show one language per address (a German page with English
    text in the same file, and the other way round) showing both at once
  - Fixed style rules aimed at the first or last child of an element not
    working when that element also had a decoration added by the stylesheet
    (stray menu arrows, wrong spacing between rows on many themes)
  - A single stray quote in a page's stylesheet no longer swallows the rules
    that follow it - pages with such a typo now get their whole layout
  - Fixed hidden overlays (cookie banners, dialogs waiting for a click) being
    drawn full-size and covering the page
  - Fixed panels in a page grid whose text was squeezed into the top few
    lines, with the button right under the heading instead of at the
    bottom of the panel
  - Words holding a slash, an underscore or a dot (file names, addresses,
    names like Man/Woman/Chainsaw) are no longer broken across lines, which
    is what other browsers do - headlines and grid columns come out right
  - A commented-out line inside a modern nested stylesheet no longer
    swallows everything after it - pages whose footer or cookie panel
    came out unstyled now get their whole theme

  1.3.8
  - JavaScript: fixed calculations with fractions in the 020 builds on
    Amigas without a maths coprocessor: results such as 0.1 + 0.2 were off
    in the last digit
  - JavaScript: Math.ceil and Math.trunc of small negative numbers now give
    -0, as in other browsers
  - Fixed pages that give their background image through a style variable
    (e.g. Nextcloud) showing no background and no logo
  - Fixed the background colour being dropped when the background shorthand
    names it after the image, and backgrounds marked fixed are honoured now
  - The page background is taken from the root element when it has one of its
    own, as in other browsers, and a full-window background set to cover is
    scaled to the window instead of being tiled at its own size
  - Video quality: 480p and 720p added to the menu next to 144p, 240p and 360p
  - Video: when a film does not have the quality you picked, the next lower one
    is used instead of dropping straight to 144p
  - Pages that send binary data from JavaScript (file uploads, compressed
    data) now send the real bytes - some sites answered with an error before
  - Scripts that use deeply nested expressions no longer fail to load - the
    nesting the parser accepts now matches other browsers
  - Pages that keep settings or state in the browser's local storage now read
    them back correctly instead of starting over on every visit
  - Text set in a web font is spaced the way other browsers space it: the
    letter pairing is now read from the font's modern table, so headings and
    menu items no longer break one line too early
  - Pages that use several weights of one web font (light, regular, bold)
    now pick the file that matches the text instead of the first one listed
  - Pages declaring more than four web font families keep their main font
    instead of falling back to a wider substitute
  - Text fields sized with the size attribute are now as wide as in other
    browsers (they used to be a few pixels too wide on every page)
  - Fixed style rules that exclude the last (or only) element of a kind
    being dropped, which left some elements looking unstyled
  - A paragraph holding nothing but a line break keeps its spacing instead
    of pushing it outside the box it sits in
  - Video at 480p and 720p now plays the picture instead of showing noise
  - When the chosen video quality cannot be started, the film page says so
    in every build, instead of quietly playing 360p
  - On builds without the video decoder (68000, 020, OS 1.3) the two video
    menus are greyed out instead of taking a choice nothing can honour, and
    the film page names the build to run to watch it
  - Text fields keep their stated width when a minimum height is set as well
    (some search boxes came out a third of their width)
  - Code blocks that a page sets to wrap now wrap instead of running off the
    right edge, and the same setting written in a style attribute works too
  - Pages that fetch data embedded in the page address (data: links) now get
    it instead of a request going out to the server

  1.3.7
  - Google search with JavaScript no longer ends on the "unusual traffic"
    page - results load (frames now get their own JavaScript built-ins)
  - Fixed tweakers.net (and other pages with a cookie-consent overlay) drawing
    news items and the footer on top of each other
  - Cookie-consent windows built in a shadow tree are now styled and shown
    over the page instead of unstyled at the bottom
  - Fixed overlays now cover the window even when "Respect position:fixed" is
    off
  - Fixed centered rows of padded boxes (tiles, tab buttons) where the first
    box was pushed right and overlapped the next one
  - Fixed icons and overlays placed inside boxes that use filter, will-change
    or contain landing in the wrong place
  - Fixed elements hidden by mistake when a style rule combined several
    classes with an attribute condition (e.g. review stars in Shopify shops)
  - Buttons that only work with JavaScript (e.g. itch.io "Download") now say
    so in the status bar when JavaScript is off for the site
  - Fixed GitHub repository pages on 68k with JavaScript: the Releases,
    Sponsor and Contributors column and the commit messages now load
  - Fixed three-column layouts where the last column dropped below the others
    (sizes written with calc() and fractional pixels)
  - Fixed tables with an HTML comment at the start of a row getting an extra
    empty column that shifted the whole layout (e.g. compuextreme.de)
  - Fixed table columns that were too narrow for a menu whose list clips its
    overflow, and list bullets showing outside such a list
  - Fixed pages with a second <body> or <title> pasted inside them (e.g.
    tramp-bbs.de) losing their background colour and page title
  - Fixed style rules inside @supports checks for display values or
    -webkit-line-clamp being skipped, so text meant to be cut to a few lines
    (e.g. product names in OpenCart shops) was shown in full
  - Fixed pages with fluid text sizes (root font size set with calc() of rem
    and vw, e.g. Webflow sites) being laid out too small
  - JavaScript: fixed scripts using a destructuring pattern as a rest
    parameter (e.g. Nextcloud) failing to load
  - JavaScript: fixed Array.filter returning nothing on pages that load the
    core-js polyfills, which left the Nextcloud login form empty
  - JavaScript: Object.entries, Object.values, Object.assign and object
    spread now read getter properties (Nextcloud login fields got their
    labels back)
  - JavaScript: NaN, Infinity, undefined and the Math and Number constants
    can no longer be overwritten or deleted, as in other browsers
  - JavaScript: added the new Set methods (union, intersection, difference
    and others) and Map.groupBy
  - JavaScript: typed arrays got the newer methods (at, findLast, toSorted,
    with and others) and Uint8Array base64/hex conversion
  - JavaScript: fixed very large numbers formatted with toLocaleString
  - JavaScript: document.readyState now goes through loading, interactive and
    complete at the same moments as in other browsers
  - JavaScript: fixed compound assignments (x += y, a[i] -= f(), o.p ||= v)
    evaluating their parts in the wrong order, which gave wrong results when
    the right-hand side changed the variable or the key
  - Cookies marked HttpOnly are no longer visible to or changeable by page
    scripts, as in other browsers
  - Icon fonts and web fonts given only as WOFF are now loaded, so menu and
    button icons show up (e.g. Roundcube webmail)
  - JavaScript: built-in page objects behave more like Chrome's (window event
    handlers, attribute checks, events, dates, error messages, setting
    document.title and the body colours from scripts)
  - JavaScript: fixed a variable used as a property name getting corrupted
    after a failed write to a property of an undefined value
  - JavaScript: drop-down lists can be filled and cleared by scripts again
    (select.options.add, remove, length = 0, options[n] = new Option)
  - JavaScript: forms and fields can be reached by name, as in
    document.forms.search or form.elements.q
  - JavaScript: classList.add and remove now apply every class name given,
    not only the first; relList and htmlFor can be changed by scripts
  - Links and underlined text are underlined again with TrueType fonts
  - JavaScript builds: web addresses longer than 1024 characters are no
    longer cut off
  - JavaScript: setInterval with a zero delay now keeps repeating instead of
    running only once
  - JavaScript: Math.random gives the full range of values and never returns
    exactly 1
  - Fixed Tailwind sites losing every style rule that came after a class name
    with quotes in it (e.g. font-['Inter'])
  - Fixed carousel images (Owl Carousel) laid out wrongly before the
    carousel script starts
  - JavaScript: CSS rule selectors read by scripts (selectorText) no longer
    lose the letter "s"

  1.3.6
  - Fixed Google search jumping to the "enable JavaScript" page although
    JavaScript was on
  - reCAPTCHA boxes ("I'm not a robot") are now displayed, e.g. on Google's
    "unusual traffic" page
  - Fixed GitHub with JavaScript on: the front page shows its content and
    Releases pages list their files (import maps, style sheets added by
    scripts, several JavaScript engine fixes)
  - Fixed downloads from itch.io (e.g. BoingTube) failing because the
    download link expired before the file transfer started
  - Faster HTTPS on 68k: secure connections are resumed instead of
    renegotiated, and the handshake no longer computes a second, unused key
  - Fixed AROS on machines with a lot of memory (e.g. Raspberry Pi 500+)
    failing to connect to any site
  - Pages with long-running scripts (e.g. npr.org) are now shown while the
    scripts are still working instead of staying blank
  - When there is not enough free memory to start a page's scripts, the page
    is now shown as without JavaScript instead of staying blank
  - Fixed closing the browser (and leaving heavy script pages such as PDFs)
    taking minutes
  - Fixed a crash on pages using Knockout (many Magento shops)
  - Faster pages whose scripts measure elements while changing their classes
    (e.g. lazy-loading images)
  - Fixed pages losing their styles and fonts after resizing the window when
    a script had added a style sheet
  - Fixed page scripts receiving empty redirect responses instead of
    following them (XMLHttpRequest and fetch)
  - Fixed checkboxes and radio buttons without a value attribute sending an
    empty value instead of "on"
  - Fixed a new tab showing the previous page's site icon
  - Fixed navigation menus pushed off to the side on some Bootstrap sites
  - Fixed Bootstrap grid columns coming out 1 pixel narrower than in other
    browsers
  - Fixed links and buttons with a percentage max-width wrapping after every
    word
  - Fixed boxes growing too wide when an inline element inside them (an
    icon, a span) sets min-width
  - Improved CSS: attribute conditions on intermediate elements of a
    selector (e.g. hiding an empty shopping cart counter), container queries
    written as (max-width: N), container queries in script-added styles
    and :not() on outer and middle ancestors of a selector, including
    lists such as :not(.a, .b) (e.g. collapsed accordion panels)

  1.3.5
  - Fixed endless page reloading with JavaScript on at ppa.pl (forum threads
    with embedded videos, editing and replying to posts)
  - Fixed a crash and wrong styling on pages with very large style sheets
  - Fixed "Upload too big" when replying on forums from 64-bit AROS
    (x86_64, aarch64) machines with a lot of memory (e.g. Raspberry Pi 500+)
  - Fixed long grid lists (news, shops) losing every item after the 32nd row
  - Fixed pages spilling out of their layout after a stray </body> or a link
    nested inside another link (common in site logos)
  - Fixed text after a floating box starting a new line instead of continuing
  - Fixed pictures sticking out of their column (overflow:hidden, frames with
    padding and border, max-width:100%)
  - Fixed boxes with a minimum width sticking out beside a floating picture
    instead of moving below it (event lists, news teasers)
  - Fixed grids with a wide first column pushing the others out of the page
  - Fixed square and fixed-ratio tiles (aspect-ratio, Tailwind aspect-*)
    collapsing, and Tailwind grids getting an invisible extra first item
  - Fixed absolutely positioned buttons and icons inside a line (search
    buttons) dropping below it
  - Fixed Bootstrap drawers and search panels covering the whole window, and
    navigation bars dropping below the logo on wide windows
  - Fixed headers and menus of popular themes (Elementor, Salient, Porto,
    Bricks, Shopify, Magento): extra buttons, hidden logos, menus in two rows,
    submenu styles leaking into the top row, items vanishing
  - Fixed centred text in card rows and shop footers collapsing to zero width
  - Fixed lists flowed into columns splitting unevenly
  - Fixed menu items squeezed into a narrow column by a width set on a link
  - Fixed words glued to a link or a decoration ("[results]", "+150") breaking
    apart at the end of a line
  - Fixed flex items stretched past their max-height (oversized buttons)
  - Fixed boxes sized with calc() percentages (sliders, video frames)
    collapsing to nothing
  - Fixed lazy-loaded pictures shrinking to a small square before the image
    arrives, and pictures filled in later by a script collapsing
  - Fixed large inline vector maps and illustrations collapsing to nothing
  - Fixed hairline (0.5px) borders and rules disappearing
  - Fixed text columns sized in "ch" being about a tenth too narrow
  - Fixed rows of round social-media icons stacking one per line
  - Improved CSS: :not() with combinators and several classes,
    :not(:nth-child()), :nth-child() on outer elements, body:not(...), two
    attribute conditions on outer elements, display: initial/unset/revert,
    animations inside cascade layers

  1.3.4
  - Space and Backspace scroll by the visible area like Page Down/Up, so
    fewer redraws are needed on slow machines; Ctrl+Up/Down jump to the top
    and bottom of the page (for keyboards without Home/End, such as the A600).
  - Right-click menu on an image: "Open image in new tab".
  - Find Text, the homepage setting and page prompts work without
    reqtools.library and on AmigaOS 4 (a small built-in requester opens
    instead) - before, nothing happened.
  - Scripts marked "defer" and module scripts run after the page is
    parsed, as in other browsers (XenForo forums such as a1k.org).
  - Layout: flex items shrink like in other browsers, percentage heights
    in flex and grid items, SVG and image sizes, min-content with margins.
  - Headings take their size from the surrounding text and their spacing
    from their final size, as in other browsers.
  - Web fonts that come only in regular weight are used for bold and
    italic text too (large bold headings were drawn too small).
  - A page that took minutes to lay out (an empty item in a selector list
    styled every element) now loads in a second; more selector forms work
    (:has() on an ancestor, :not() before a class, long :where() lists).
  - Boxes, pictures and frames too wide to fit beside floated content move
    below it; footers pinned to the bottom of the page, scale(75%),
    min-width:max-content, height:0% and auto-fit grids now lay out
    correctly.
  - HTTPS on AROS, MorphOS and PowerPC cards: connects to servers that
    offer only older (CBC) cipher suites or ask for a handshake retry.
  - SVG icons sized in percent no longer vanish inside boxes that shrink to
    their content.
  - "!important" works on flex and alignment properties (Bootstrap utility
    classes such as justify-content-between).
  - Pages with more than 48 style sheets (large WordPress themes) are
    styled completely.
  - Text sized in "rem" keeps its fractional size, so line heights match
    other browsers (lists and menus were a pixel taller per line).
  - Pages that set a tiny root font size and size everything in "rem"
    ("1rem = 1px" designs) are no longer drawn many times too large.
  - Absolutely positioned flex and grid boxes holding only text (labels,
    badges on pictures) are no longer squeezed to an empty box.
  - Form fieldsets contain their floated fields (forms no longer overlap).
  - Selectors such as [data-x=y] ~ main (data- and aria- attributes on a
    preceding sibling) work; pages no longer start under their fixed header.
  - Invalid "flex" values (three numbers) are ignored like in other
    browsers instead of collapsing the box to nothing.
  - Pages saved with a byte order mark (many Shopify shops) keep their head:
    styles and scripts load as intended.
  - Banners and boxes whose height comes from an empty ::before/::after in a
    flex or grid container (aspect-ratio padding trick) are no longer flat.
  - Images sized width:100% in flex boxes keep their proportions (logos were
    drawn several times too tall).
  - More selectors with attributes on outer ancestors match (Shopify
    sliders now lay out as rows).
  - transform: scale(calc(...)) is computed (cards no longer shrink to a
    tiny thumbnail).
  - vBulletin 5 forums such as amigaportal.cz: the side column sits next to
    the content instead of below it, and avatars no longer cover the text.
  - Tables with table-layout:fixed keep their stated width instead of growing
    with their content (side columns no longer pushed off narrow screens).
  - The "font" shorthand accepts weights like 850 and sizes written with
    clamp(), calc(), min() or max(), and resets the weight, style and line
    height it leaves out (huge headlines on modern sites).
  - Grid columns sized in rem, em or vw get their real width (they were
    treated as a few pixels).
  - Badly nested links around blocks (<a><div>...</a></div>, common in page
    builders) no longer shift the rest of the page.
  - Very long pages (over 32767 pixels) built with flexbox no longer collapse
    and draw their footer over the content.
  - text-wrap: nowrap is supported (menus no longer break into several lines).
  - Form fields in grids no longer grow by their margins, and fields with
    box-sizing:border-box respect min-height.
  - Gaps between grid and flex columns given in percent (gap: 0 2%) are
    applied (columns were too wide and the gaps were missing).
  - A box with height:100% inside a parent of height 0 is 0 tall, as in
    other browsers (closed slide-out menus no longer cover the page).
  - Inline-block boxes with margin:auto are placed by text-align, as in other
    browsers (centred cards no longer jump to the right edge).
  - Frames with align="left"/"right" float beside the text, and frames have
    their default border.

  1.3.3
  - Much faster on 68k with JavaScript: memory handling no longer slows down
    as pages use more RAM. itch.io downloads work again (the purchase page
    stopped responding to clicks), and pages with many scripts no longer
    freeze for minutes.
  - PDF: a small PDF no longer eats all the memory and shows a blank page -
    memory is now reclaimed while the PDF renders. The PDF toolbar stays at
    the top while you page through the document.
  - Opening a PDF asks whether to open it in Amelinium or save it to disk;
    Save uses the already downloaded file.
  - Closing the browser after viewing a PDF (or another heavy page) no
    longer freezes or crashes it (seen on AROS).
  - AROS x86_64/aarch64: more stack for deep pages.
  - CSS: @layer cascade layers, :where() with zero weight, several :not()
    on one element, gap: inherit, clamp()/min()/max() with expressions,
    rem sizes based on the window width, more than 32 floats on a page.
  - Layout: flex columns, grid items with percentage heights, images in
    <picture> take their size from the chosen <source>, absolutely
    positioned images keep their size, <hr> and empty boxes no longer
    merge margins wrongly, file and range inputs drawn without a text frame.
  - Pages sent in chunks (chunked transfer) no longer lose their style
    sheets when the data contains an empty line.

  1.3.2
  - WarpOS: JavaScript works again - since 1.3.0 any script crashed the
    PowerPC build with an exception.
  - AROS x86_64 and aarch64: pages whose scripts wait on many things at once
    (YouTube) no longer crash with "Stack extends out of range".
  - A page whose scripts use up the memory (a large scanned PDF on a 256 MB
    machine) is stopped before the computer runs out of RAM; a PDF shows
    "Not enough memory" instead. Memory a page used is given back when you
    leave it.
  - Search results sent by a form (DuckDuckGo) are shown again when you
    return to their tab or press Back, instead of an empty search page.
  - YouTube videos embedded in other pages show their picture with a play
    button; clicking it plays the video in Amelinium's own player.
  - CSS: a floating box written after a line of text goes below that text
    instead of over it (forum list on amigans.net).
  - HTML: a heading inside a <div> inside another heading no longer closes
    the outer one (some site menus fell apart).
  - SVG: icons sized like width="1em" keep their proportions instead of
    becoming 150 pixels tall.

  1.3.1
  - The PDF viewer (pdfjs drawer) downloads itself the first time a PDF is
    opened, when it is missing - after "Install now" only the program was
    updated, so every PDF was saved to disk instead of shown.
  - CSS: rules like .menu>li>div>.button (a chain of '>' with two or more
    steps, common in Bootstrap menus) now apply.
  - CSS: ::before/::after icons whose content and size come from different
    rules (Font Awesome 6 and similar icon sets) are shown.
  - PDF: pictures inside a PDF (photos, diagrams) were drawn as black boxes
    on the Amiga. They are shown now.
  - JavaScript: getBoundingClientRect() of an inline element with a margin
    reports the element itself, not its margin.
  - CSS: a box stretched with left/right and box-sizing:border-box has the
    height the page asks for (menus and overlays were taller).
  - CSS: transform: translate3d() moves the box, and a mistyped prefixed
    copy no longer cancels a correct transform (hidden side menus showed).
  - CSS: the font shorthand understands size words (font: x-small Arial).
  - CSS: grid columns sized "auto" stay at their content width when the
    grid is centred (justify-content), and <br> inside a flex or grid row
    takes its place like in other browsers.

  1.3.0
  The biggest changes first:
  - PDF files open in a built-in viewer (pdf.js) in the JavaScript builds;
    WWW -> PDF lists Amiga user guides from Aminet.
  - Frames (<iframe>) run their own scripts, are drawn from what those
    scripts build, and talk to the page with postMessage.
  - <canvas> has a working 2D drawing context (shapes, text, gradients,
    shadows, reading pixels back); the canvas itself is not shown yet.
  - Emoji have their own font (Noto Emoji) instead of empty boxes.
  - Sound can go through AHI as well as Paula (Settings -> Sound output).
  - JavaScript is faster (function calls and arithmetic 10-30% on a 68040,
    timers no longer wait for the screen tick) and far closer to Chrome:
    fetch(), XMLHttpRequest, async generators, Trusted Types, many Web APIs.
  - CSS: :has(), colours in oklch()/lab()/color() (Tailwind 4), <picture>,
    srcset sizes, min()/max()/clamp() with percentages, and many layout
    fixes found by comparing random sites with Chrome.
  All changes:
  - JavaScript: pages sent with Cross-Origin-Opener-Policy and
    Cross-Origin-Embedder-Policy are cross-origin isolated like in other
    browsers (crossOriginIsolated, SharedArrayBuffer, performance.now()
    with 5 microsecond steps, 100 elsewhere); Atomics is available;
    ArrayBuffer gained byteLength, resize, transfer and detached.
  - JavaScript: navigator.storage.getDirectory() gives a working private
    file system (files and folders kept in memory for the session,
    writable streams, sync access handles in workers).
  - JavaScript: toString() of object and class methods, getters, setters
    and async functions returns their source text like other browsers.
  - JavaScript: Error.stack of a script written inside the page counts lines
    and columns from the start of the page (not of the script), columns past
    65535 no longer wrap, and calls through o[key]() point where Chrome does.
  - JavaScript: canvas measureText() returns a TextMetrics object whose fields
    are prototype getters, like in other browsers.
  - JavaScript: DOM interfaces inherit from their parent interfaces as in the
    standard (MouseEvent from UIEvent, Comment from CharacterData, FileReader
    from EventTarget and so on), and every interface prototype has its own
    constructor property.
  - Emoji are drawn and measured with their own font (Noto Emoji, fetched
    with the other TrueType fonts) instead of an empty box, also in canvas
    measureText() and fillText(); emoji sequences joined with ZWJ (families,
    couples) are one picture, and characters beyond U+FFFF are no longer
    replaced by "?".
  - JavaScript: style.setProperty() ignores a priority other than "important"
    and a value carrying "!important", like other browsers;
    getPropertyPriority() exists, and the style attribute changed from a
    script reads back as "name: value;" pairs.
  - JavaScript: performance entries carry the Server-Timing metrics the server
    sent (serverTiming with PerformanceServerTiming objects), for the page,
    frames and fetched resources.
  - HTML comments are now part of the page for scripts (comment nodes, as in
    other browsers), and a short comment such as "<!-->" no longer hides the
    text that follows it.
  - JavaScript: constructors such as URL, FormData, Headers and DOMException
    report their real names.
  - JavaScript: TextEncoder and TextDecoder work like in other browsers:
    encodeInto(), the encoding names (latin1, utf-16 and the others), the
    fatal and ignoreBOM options, decoding a stream in pieces, and the
    TextEncoderStream and TextDecoderStream classes.
  - JavaScript: <link> elements created by scripts are proper
    HTMLLinkElement objects, and getComputedStyle() of an element that is
    not in the page answers with empty values, as in other browsers.
  - JavaScript: writing to a WritableStream or TransformStream is queued
    like in other browsers, so the stream code runs in the right order
    instead of inside write().
  - JavaScript: element properties have the right types and defaults
    (draggable, spellcheck and translate are true/false, <meter> and
    <progress> report numbers, scripts created by a script are async), and
    getComputedStyle() reflects styles a script just added, also inside
    frames. Setting innerText turns line breaks into <br>.
  - JavaScript: text drawn on a <canvas> keeps its true edge smoothing, so
    pixels read back with getImageData() match other browsers more closely.
  - JavaScript: Object.getOwnPropertyNames() of a Proxy around a function
    lists the function's own properties, and performance.memory reports
    exact numbers on web pages, as in other browsers.
  - JavaScript: matchMedia() returns a proper MediaQueryList, the browser's
    own bookkeeping attributes are no longer visible to page scripts, and
    nonce attributes are hidden as in other browsers when the page sends a
    Content-Security-Policy header.
  - JavaScript: each frame numbers its setTimeout()/setInterval() timers
    on its own, and clearTimeout() in a frame no longer cancels the page's
    timers.
  - JavaScript: navigator.plugins and navigator.mimeTypes are proper
    PluginArray and MimeTypeArray objects.
  - JavaScript: requestAnimationFrame() and requestIdleCallback() number
    their callbacks on their own and animation frames get a high-resolution
    timestamp, as in other browsers.
  - JavaScript: Date.parse() and new Date("...") accept the same date
    formats as other browsers (for example "2020-12-1", "Dec 1 999" or
    "12/1/2020 10:00 PM").
  - JavaScript: structuredClone() copies dates, regular expressions, maps,
    sets, typed arrays, errors and cyclic objects like other browsers and
    reports DataCloneError for things that cannot be copied; Object(5n),
    BigInt.prototype methods and JSON.stringify() with BigInt behave as
    specified.
  - JavaScript: crypto.getRandomValues() and crypto.randomUUID() no longer
    use up the numbers a page gets from Math.random().
  - JavaScript: canvas drawing casts shadows (shadowBlur, shadowColor,
    shadowOffsetX/Y).
  - JavaScript: adding a frame from a script no longer runs pending promise
    callbacks in the middle of that script.
  - JavaScript: each frame has its own eval(), so code evaluated through a
    frame's eval() runs in that frame (needed by Cloudflare checks).
  - JavaScript: frames with a srcdoc attribute load that content (they
    used to stay empty).
  - JavaScript: Array methods called on a string, such as
    Array.prototype.map.call("abc", f), work as in other browsers.
  - JavaScript: TextEncoder.encode() returns a Uint8Array and a Blob made
    of binary data keeps the bytes instead of the text "1,2,3".
  - Downloads from itch.io work again: the purchase page no longer runs the
    browser out of memory (a large canvas used to cost hundreds of
    megabytes), so the download page loads with its styles and the Download
    buttons start the file as before.
  - JavaScript: typed arrays over a million elements are created (an
    invalid length now throws RangeError), canvas.toDataURL() produces a
    compressed PNG quickly, and JSON.stringify of a typed array gives an
    object like other browsers.
  - JavaScript: getBoundingClientRect() of an inline element includes an
    empty inline-block or ::after{content:""} inside it, and its height is
    the height of its text, not of an image or box placed in it.
  - JavaScript: performance.timing and the navigation entry report the real
    phases of loading a page (DNS, connection, request, response,
    DOMContentLoaded, load), performance.now() counts from the start of the
    navigation, and DOMContentLoaded handlers run before load handlers;
    " ".repeat() no longer gives an empty string for long results.
  - JavaScript: Function.prototype.bind can be taken and called as a value
    (Function.prototype.bind.call(f, ...)), Object.getPrototypeOf works on
    numbers and strings, RegExp flags/source/compile, the regexp symbol
    methods, Symbol.description, the remaining well-known symbols,
    isWellFormed/toWellFormed and getYear/setYear exist, and built-in
    objects list their own properties in the same order as other browsers.
  - JavaScript: timers and inter-frame messages no longer wait for the
    1/10 second screen tick, so scripts that chain zero-delay timeouts or
    talk between frames run far faster; nested timers keep the standard
    4 ms minimum.
  - Internet radio: Radio Kiss Morava added to WWW menu -> Radio.
  - JavaScript: strict mode, class static members and private fields, super,
    destructuring from strings, Sets and generators and into object
    properties, and several smaller fixes to objects, Map and JSON.parse.
  - JavaScript: promises accept "thenable" objects such as the ones jQuery
    and many libraries return (the result used to arrive as the object
    itself), and error types (TypeError, RangeError...) are told apart
    correctly; AggregateError added.
  - JavaScript: dates - years beyond 9999, month overflow in setMonth, Date()
    called as a function and invalid dates in JSON follow the standard.
  - Layout: nested rows on Bootstrap pages (.row inside .row) get their full
    width and spacing, and getComputedStyle() reports real widths and
    heights in pixels.
  - Layout: a box beside a float may let its margin overlap the float, as in
    other browsers (code blocks on Bootstrap pages were too narrow).
  - Stylesheets whose media list spans several lines are loaded (w3.org lost
    its layout), and matchMedia() answers like the stylesheet does.
  - Old Internet Explorer style hacks (`* html ...`) are ignored as in other
    browsers (they broke layouts such as eff.org).
  - CSS rules such as `.row:nth-child(2) .item` or `li:first-child span`
    (a structural condition on an ancestor) are applied instead of skipped.
  - JavaScript: spreading sets, strings and generators into function calls,
    Map and Set built from any iterable, and matchAll() results work.
  - JavaScript: SVG elements written in the page have their proper types
    (SVGRectElement, SVGPathElement...), so getBBox() works on them, including
    exact bounds of paths, curves and arcs; getElementsByTagName() with the
    name of a custom or SVG element no longer returns every element.
  - Layout: form fields and buttons that a stylesheet turns into table cells
    (Bootstrap 3 search boxes) stay ordinary inline fields, as in other
    browsers.
  - Layout: a fieldset's legend sits on its top border with a gap in the
    frame, as in other browsers (it used to sit inside the box), and
    fieldsets get the standard default frame and spacing.
  - Stylesheets: class names, ids and attribute values are case-sensitive
    on modern pages, as in other browsers (a rule for .myRow no longer
    styles class="myrow"); old pages without a doctype keep the lenient
    matching, now also in querySelector() and getElementsByClassName().
  - Forms: the label of an input button stays on one line and a width given
    to the button is kept; an input of type button without a value is
    empty, not "Button". A <title> written inside the page body no longer
    moves into the head.
  - Layout: the grid shorthand with auto-flow (grid: auto / auto-flow 200px)
    works, so product carousels and tile rows on shop themes are laid out
    side by side instead of in one long column.
  - Layout: images sized in percent (width: 100%) no longer force their
    column or box to the picture's full size; two equal columns stay equal
    and boxes around such images shrink to the space available.
  - Layout: a <canvas> (charts, games, drawings) takes up its space on the
    page as in other browsers (300x150 by default, or the size it states)
    instead of collapsing to nothing; its content is not drawn yet.
  - Style: rules using :popover-open, and negated states such as
    :not(:disabled), :not(:checked) or :not(:popover-open), now apply; menus
    that are hidden until opened no longer show up on the page, and a rule
    for an open popover no longer hits closed ones.
  - Layout: a height written as calc() with a percentage in an element's
    own style attribute (height: calc(100% - 20px)) now resolves against its
    container instead of turning into a fixed 100 pixel minimum, and
    margin: calc(...) 0 there no longer puts the same margin on all sides.
  - Layout: an image that has not loaded yet (or uses a placeholder) keeps
    the proportions its width and height attributes give it, so pictures
    scaled down with max-width no longer collapse or stretch before they
    arrive; aspect-ratio also survives a max-width limit, and a box with a
    set height and aspect-ratio takes its width from the ratio.
  - Pages opened from disk: a picture whose file is missing now shows its
    alternative text, as it does for a missing picture on the web, instead
    of an empty box of the picture's size.
  - Style: a rule for menu items three levels deep (for example
    "nav ul ul li a") no longer also hits the top-level items, which made
    every entry of such a menu as wide as its drop-down.
  - JavaScript: background page requests (XMLHttpRequest) now finish after
    the script that sent them has continued, as in other browsers, and a
    request that cannot reach its server reports an error instead of an
    empty success - pages that retry or fall back on failure now do so.
  - JavaScript: page requests with very long addresses (over 1024
    characters) are no longer cut short.
  - JavaScript: scripts can read every response header of their page
    requests (getResponseHeader), with the same cross-site limits as other
    browsers, and pictures created by scripts inside a frame now load.
  - JavaScript: scripts inside a frame see the Crypto and SubtleCrypto
    interfaces, like scripts on the page.
  - JavaScript: error messages read like in other browsers, and several
    mistakes now raise an error as they should (setting a property on null,
    'in' or 'instanceof' on a non-object, spreading a number, destructuring
    null, calling a string method on null).
  - JavaScript: XMLHttpRequest offers the full standard set of properties
    and constants, including responseType "json" and "arraybuffer".
  - JavaScript: XMLHttpRequest reports its progress step by step and passes
    a proper event object to its handlers, and buffers made by the engine
    are real ArrayBuffers.
  - JavaScript: <canvas> has a 2D drawing context. Scripts can draw
    rectangles, lines, curves, circles, gradients and text, clip and blend,
    copy pictures and other canvases onto it, and read the pixels back; a
    canvas is still not shown on screen.
  - A PNG picture whose data is damaged but whose header is fine now counts
    as loaded, with its size and transparent pixels, as in other browsers.
  - JavaScript: fetch() works properly. Every answer used to arrive with
    status 0 and an empty body, and a failed connection was reported as an
    answer instead of an error; responses now carry their real status,
    status text, headers and body, a body can be read once, and a network
    failure rejects with "Failed to fetch", as in other browsers.
  - JavaScript: code run through eval() no longer reads its own names from
    memory that was already released - this caused random wrong names,
    "is not a constructor" errors and crashes on heavy pages.
  - JavaScript: reading a variable that was never declared now throws
    ReferenceError ("x is not defined") instead of quietly giving
    undefined, and several other errors are now thrown where every browser
    throws them (String.fromCodePoint with an invalid value, a prototype
    chain that would loop, "caller" and "callee" in strict code).
  - JavaScript: XMLHttpRequest statusText is the server's own phrase
    ("Unauthorized"), not always "OK".
  - JavaScript: FontFace and document.fonts follow the CSS Font Loading
    rules: asking for a local font that is not installed now fails the way
    it does in other browsers, instead of claiming every font exists.
  - JavaScript: navigator.storage, navigator.permissions, getGamepads,
    getBattery, speechSynthesis, Notification, BroadcastChannel,
    screen.orientation and navigator.gpu now exist, answering honestly for
    this machine (no gamepads, no voices, no GPU, mains power).
  - JavaScript: Trusted Types (trustedTypes, policies, TrustedHTML and
    TrustedScript). A frame whose Content-Security-Policy requires them now
    refuses eval() and new Function() on plain strings, as other browsers
    do; innerHTML accepts a TrustedHTML value.
  - Layout: stretched flex items take the height of their row even when
    their content is taller, and overflow: clip no longer lets a flex item
    shrink below its content.
  - Layout: absolutely positioned boxes with top, bottom and auto margins are
    centred vertically; grid columns no longer grow to fit an item that has
    min-width: 0; :not() with several structural conditions works;
    CSS rules that combine an attribute test with :not(#id), or an
    ancestor written as #id.class, apply exactly where they should.
  - Movies: picture and sound stay in step - the picture ran about a tenth
    of a second ahead of the sound, more on AmigaOS 4.
  - Fixed: a very long text page (one text block over 64 KB, such as a
    whole manual in one <pre>) was cut short, and its later lines were
    drawn over the top of the page.
  - Frames (<iframe>) run their own scripts and talk to the page with
    postMessage, as security checks and embedded widgets need.
  - YouTube: the cookie consent window fits the screen, its text scrolls
    to the end and its buttons show their labels.
  - YouTube: the cookie consent choice is saved, search results appear,
    and the YouTube logo and channel pictures show.
  - Pictures that a page's own scripts add or change are loaded now, with
    the load events pages wait for (thumbnails on YouTube and on many
    modern sites stayed empty before).
  - Fixed: a symbol such as a bullet could turn into odd characters where
    a page lets long words break anywhere.
  - JavaScript: text built piece by piece in a loop (s += x) is much
    faster, and very long results no longer come out cut short.
  - JavaScript: regular expressions match repeats longer than 511
    characters (long addresses and texts failed to match before).
  - JavaScript: new Image() and new Audio() create real elements; images
    that scripts create report complete only once loaded.
  - Fixed: a script copying a promise, Map or similar built-in object (as
    YouTube does) could crash the browser a while later.
  - JavaScript: IntersectionObserver behaves as in other browsers, so pages
    no longer load their own slower replacement for it.
  - YouTube: the cookie consent window has its white background (its text
    was drawn straight over the page).
  - Fixed: a style sheet that a script adds to a page with no style sheet of
    its own had no effect.
  - YouTube: icons show (logo, menu, buttons, list markers) - scripts now
    see the contents of SVG pictures, and arcs in SVG paths are drawn as
    real curves.
  - Fixed: an element hidden with an invalid opacity value (as YouTube sets
    it) stays visible, as in other browsers.
  - A scrolling box inside a window that stays in place (position: fixed,
    as in most dialogs) now scrolls its content, not just its scrollbar.
  - Clicks reach boxes that a page positions freely (absolute, fixed) also
    right after the page has changed them.
  - Layout: percentage heights inside CSS grids, icons mirrored with
    scale, var()var() written without a space.
  - JavaScript: many fixes to text with non-English letters, number
    formatting, Intl, element scroll
    positions, getBoundingClientRect inside scrolled boxes, and custom
    elements (the building blocks of YouTube and similar sites).
  - JavaScript: localStorage and sessionStorage accept the short form
    (localStorage.key = value, localStorage.key) and list stored keys;
    MessageChannel messages arrive without timer delay, so pages built with
    React respond faster; constants really are constant; Proxy objects work
    with for-in, JSON and property descriptors; Object.keys() of built-in
    objects and of the window lists the same as in other browsers; SVG text
    elements report character positions.
  - Layout: text set in fractional font sizes (16.5px) gets its proper
    line height; percentage table columns are measured from the table
    width; flex carousels wider than 32767 pixels are laid out correctly;
    a closed <details> stays closed even when a style sheet sets display
    on its content; <marquee> text is laid out like in other browsers (on
    one line, not scrolling).
  - Style: flex-basis with calc(), grid rows in fr units inside a grid of
    automatic height (including collapsed 0fr accordions), and width or
    max-width written with min(), max() or clamp() and one or more
    percentages (Elementor background videos no longer shrink to nothing).
  - Style: !important now also wins for widths and heights in percent,
    calc() or auto, and for percentage padding and max-width; several
    selector forms (".item:last-child:after", a class written after :not(),
    long sibling names, "!important" rules with two ancestors) apply exactly
    where they should; getComputedStyle() answers for every property.
  - Style: rules meant for forced colors, high contrast, inverted colors or
    HDR screens no longer apply on an ordinary screen (GitHub links were
    drawn in the wrong colour).
  - Scrolling: pages whose content scrolls inside the body while the page
    itself does not (Google News) can be scrolled with the main scrollbar,
    wheel and keys.
  - Frames show the content their own scripts build; frames created inside
    other frames and frames loaded from blob: addresses work.
  - JavaScript: lists such as querySelectorAll(), children, childNodes,
    form.elements and attributes are proper NodeList, HTMLCollection and
    NamedNodeMap objects with item(), namedItem() and forEach(); classList,
    URLSearchParams, FormData and Headers can be looped over (YouTube).
  - JavaScript: Math.sin, cos, tan, atan2, cbrt, log2 and their relatives
    give exactly the results other browsers give (sin of very large numbers
    and even of Math.PI came out different before).
  - JavaScript: Date.now() and performance.now() tick in fractions of a
    millisecond and agree with each other.
  - JavaScript: many smaller additions so pages see a standard browser:
    CSS.supports(), screen and window sizes from the real screen,
    performance.memory, location and history as proper objects, element
    types reported correctly, and requests to other sites send only the
    site name as referrer, as other browsers do.
  - A page that builds an empty frame (about:blank) and puts pictures or
    links into it no longer stops the whole browser with an "insert volume
    about" requester; such addresses are resolved against the page, as in
    other browsers.
  - JavaScript: array methods (push, map, filter, join...) work on reactive
    arrays such as those of Vue 3 applications; they used to return empty
    or wrong results.
  - JavaScript: Promise.withResolvers() and Promise.try(), URL.canParse()
    and URL.parse(); new URL() rejects an address that is not a URL, and
    event.eventPhase reports the real phase of an event.
  - itch.io downloads now start in time on a 68020 with JIT as well: the
    page no longer fetches its background picture again at every layout
    check, and JavaScript timers keep running while the window is inactive.
  - JavaScript runs faster: function calls, variable access and simple
    arithmetic are roughly 10-30% quicker on a 68040, and canvas drawing
    (charts, games) is several times faster.
  - Layout closer to other browsers: !important inside style="", <picture>
    takes its image from the matching <source>, width/height attributes
    only on elements that allow them, <hr size>, <svg width="1em">, chained
    child selectors (.a>.b>.c) and tag-qualified ancestors (header.x .y),
    auto margins of grid and flex items, wrapping flex rows (Bootstrap
    columns), fixed elements inside transformed ones, rem sizes set by a
    later stylesheet, container units (cqw) and percentages inside calc().
  - SVG text: a font-size attribute is honoured, and text lengths measured
    by scripts match other browsers.
  - JavaScript: mouse events carry the same fields as in other browsers
    (pointer events, coordinates), and mouse movement over a frame reaches
    the scripts of that frame.
  - JavaScript: a form submitted by a script uses its own method (POST),
    history.replaceState() changes the page address, canvas measureText()
    gives fractional widths, and objects used as property keys, permission
    queries and many smaller details behave as in other browsers.
  - JavaScript: error objects, built-in constructors (Map, Promise, typed
    arrays need "new"), Element/HTMLElement/HTMLDocument/CSSStyleDeclaration
    prototypes and the order of onclick-style handlers versus
    addEventListener now match other browsers; Uint8Array() called without
    "new" no longer crashes the engine.
  - JavaScript: every frame has its own DOM prototypes and constructors;
    event, screen and element properties live on their interface
    prototypes as in other browsers; a frame's window size follows its
    <iframe> (width/height and style); document.styleSheets lists the
    rules of <style> elements; getBoundingClientRect() returns a DOMRect.
  - JavaScript: an emoji built from two halves ("\uD83D" + "\uDE00") is
    now the same string as the emoji itself; documents made with
    DOMParser or createHTMLDocument search their own tree; Float16Array,
    ImageData colour settings, CSSRuleList and performance.mark/measure
    entries work as in other browsers.
  - Fixed: a table cell right after a <caption> no longer ends up inside
    the caption; absolutely positioned boxes keep their left margin;
    <progress> and <meter> have their standard size.
  - CSS: colours written with color(), lab(), lch(), oklab() and oklch()
    (used by Tailwind 4 for its whole palette) are understood; a canvas
    created with colorSpace "display-p3" keeps its pixels in that space.
  - JavaScript: innerHTML and outerHTML are no longer cut off after about
    8 KB, and the text of <script> and <style> comes back without
    entities; a Proxy can be used as a getter or setter; a frame reports
    its own navigation timing instead of the page's.
  - JavaScript: error stack traces look like Chrome's (script address,
    the right line and column in every frame, "Object.render", "new F");
    scripts added by a page fire "load" or "error" when they finish;
    performance.getEntriesByType("resource") lists the page's scripts,
    frames and requests; Math functions and isNaN call an object's
    valueOf; array callbacks get the right "this"; event listeners
    registered for the capture phase run before the target, as in other
    browsers.
  - CSS: a negated element name (:not(html), :not(p)) is honoured in
    !important rules and on ancestors (Shopify shops built on the Dawn
    theme), and so are :last-child and similar conditions on ancestors in
    !important rules.
  - CSS: the rem unit follows html{font-size: calc(var(--x) * 62.5%)} (the
    Shopify Dawn theme), so sizes given in rem on those shops are no
    longer 60% too large.
  - CSS: line-height: calc(1 + 0.8 / var(--x)) and other calc() giving a
    plain number are understood - such text no longer collapses into lines
    two pixels high.
  - CSS: @supports (inset: ...) and the related properties now answer
    yes, so fallback blocks written for browsers without inset (Shopify
    Dawn footers) are no longer applied.
  - CSS: ::before and ::after rules check all of their ancestor conditions
    (an outer class, :not(), a tag name, :nth-child() on an element in
    between), so they no longer appear where the page did not ask for them.
  - CSS: column-count now also splits inline content (inline-block cards,
    plain text) into columns line by line, balanced like other browsers;
    a multi-column box no longer lets its first child's top margin leak
    out.
  - CSS: a flex item stretched across a column flex container keeps its
    max-width.
  - CSS: heights in percent above 100% (height: 200%) work.
  - CSS: absolutely or fixed positioned boxes stretched between left and
    right with a max-width and auto margins are centred (Bootstrap toasts).
  - CSS: a selector starting with an id and followed by an attribute
    condition (#loader[data-v-1a2b], as written by Vue scoped styles)
    matches again.
  - CSS: an image with an empty src (<img src="">) is laid out like in other
    browsers - an empty inline element in standards mode (no longer a
    box of its CSS width), square with one given dimension in quirks mode;
    an <img> with neither src nor alt no longer gets a 16 pixel stand-in
    for the dimension the page did not give.
  - CSS: rules whose last class name is longer than 63 characters (Shopify
    section classes) apply again in descendant selectors, ::before/::after
    and !important.
  - CSS: grid-template-columns: repeat(auto-fill, 25%) and other auto-fill
    repeats with percentage or calc() tracks produce the right number of
    columns (they collapsed to one); percentage tracks, also inside calc(),
    keep their fractional part (16.6667% is six columns, not five).
  - CSS: a class or id written after an attribute condition (#menu[open].on,
    div[data-v].active, .a[x].b.c) no longer makes the whole rule ignored.
  - CSS: min(), max() and clamp() nested inside calc() are understood
    (calc(100% - 2 * clamp(20px, 4vw, 64px))) - such page containers no
    longer collapse to zero width.
  - Images served with a Content-Encoding no browser knows (aws-chunked from
    S3-style storage) are shown instead of being dropped; only real
    compression we cannot unpack (br, zstd, deflate) is refused.
  - CSS: an image or SVG whose given width works out to zero (width: 100%
    inside a zero-wide box, or a calc() that comes out negative) is zero
    wide instead of taking its natural size.
  - Fixed: parsing a style sheet that outgrew its first rule table read
    memory that had just been freed.
  - CSS: an ancestor written with an attribute between two classes
    (.a[data-x].b .c, .a[data-x].b span) is matched instead of the whole
    rule being dropped.
  - Images: a picture chosen from srcset takes its natural size from the
    srcset width and the sizes attribute (or the 2x/1.5x density), so a
    1600w photo shown with sizes="400px" is 400 pixels wide, not 1600;
    sizes also picks a smaller file when the picture is shown small.
  - Layout: a menu item ending in an empty inline-block (a:after with
    content:"") no longer makes the whole menu bar taller.
  - CSS: a ::before/::after made absolute or a block by a rule that does
    not set content now takes effect (grids no longer get an extra cell).
  - Layout: a box with aspect-ratio grows to fit taller content, as in
    other browsers (unless it scrolls or sets a min-height).
  - Layout: grid items honour the order property.
  - Images: an inline SVG with only a viewBox (no width or height) fills
    the width of its container and adds nothing to the width of a
    shrinking box, as in other browsers; a picture with a percentage width
    wider than 100% is no
    longer squeezed into its container.
  - Layout: a grid item larger than its cell is centred (or end-aligned)
    past the cell edges, as in other browsers.
  - JavaScript: RegExp.$1 to $9, RegExp.input, lastMatch, lastParen,
    leftContext and rightContext hold the result of the last match, like in
    other browsers.
  - JavaScript: Error.stack names the receiver of a method called on an
    object made with Object.create() or on a Proxy like Chrome does, and
    assigning to a static property of a function defined with a setter
    calls that setter.
  - JavaScript: delete works on functions (static properties, name and
    length); a bound function takes "bound " when the target has no string
    name; unknown tags such as <blah> or <applet> are HTMLUnknownElement.
  - JavaScript: bind() on a function wrapped in a Proxy keeps its name and
    length ("bound querySelectorAll" instead of an empty name).
  - Sound: Settings -> Sound output chooses between Paula (audio.device,
    the default) and AHI (ahi.device, 16 bits, through whatever AHI is set
    up to use - a sound card, 14-bit Paula or the system mixer). Movies and
    radio stations started afterwards use it; if AHI cannot play, the
    player falls back to Paula.
  - JavaScript: async generators (async function*) and for await loops
    work as in other browsers; "for await" used to run like a plain loop
    without waiting.
  - JavaScript: naturalWidth and naturalHeight of an image chosen from
    srcset take the candidate's density into account, like the layout does.
  - CSS: rules with a structural condition on an ancestor such as
    li:not(:first-child), or on an ancestor further up the selector
    (.list li:not(:first-child) .title a), now apply.
  - JavaScript: document.querySelector() with an id followed by more of the
    selector ("#menu a", "#box > p") found nothing; it does now.
  - JavaScript: content generated by CSS ::before and ::after no longer
    shows up in children, childNodes, textContent or innerHTML.
  - CSS: the :has() selector works in its common forms (.card:has(img),
    li:has(> ul), .menu:not(:has(.active))).
  - Images: a block-level picture with a percentage width is rounded to the
    nearest pixel like other blocks, not truncated.
  - CSS: max-width, min-width, max-height and min-height set to initial,
    unset or revert (and max-width: none in a style attribute) cancel an
    earlier limit.
  - JavaScript: destructuring (const {x} = obj, function({x}) {...}) reads
    getters defined in classes and prototypes, and works on strings and
    functions; it used to give undefined.
  - Fixed: calling a method directly on a value read from a Map or WeakMap
    (map.get(key).method()) could destroy that value inside the map, causing
    random errors in scripts that keep objects in maps.
  - PDF files open in a built-in viewer, like in Firefox: a grey toolbar
    that stays at the top with Previous / Next, page number, zoom and
    Download, and pages drawn as you scroll to them. It is pdf.js by Mozilla
    (Apache 2.0) in the new pdfjs drawer; JavaScript builds only. Without
    that drawer, or in a build without JavaScript, a PDF is downloaded as
    before and the status bar says why. The WWW menu has a new PDF submenu
    with Amiga user guides (A500 to A4000, CD32) from Aminet.
  - JavaScript: DOMMatrix and DOMMatrixReadOnly exist, and a canvas
    getTransform() returns one.
  - CSS: style sheets that start with a byte order mark, @charset or a
    @layer statement load their @import files again (whole frameworks such
    as Bootstrap were missing), and @import with layer() or supports() works.
  - Check boxes and radio buttons keep their 13x13 size when a page gives
    form fields padding or a border, and offsetWidth/clientWidth ignore
    transforms (scale) as in other browsers.
  - Fixed: JavaScript returning a let/const variable from inside a block,
    loop or switch ({ const x = ...; return x; }) gave undefined or another
    value, and a const declared in one switch case hid a variable of the
    same name after the switch (PDF tables were lost because of it).

  1.2.9
  - Fixed: pages whose body is as tall as the window (html, body
    { height: 100% }, e.g. demozoo.org) could not be scrolled - the
    scrollbar knob filled the whole bar.
  - Fixed: a row of links kept together with white-space: nowrap (the
    demozoo.org footer) did not wrap between the links and made the page
    wider than the window.
  - JavaScript: Proxy.
  - JavaScript: regular expressions with an optional or repeated group
    followed by more pattern, e.g. /v0(.*)?\/api/, could fail to match.
  - JavaScript: a function that replaces itself on its first call (common
    in compiled code) returned a wrong result on that call.
  - JavaScript: document.currentScript in scripts a page adds itself,
    iframe.contentWindow, built-in functions print as native code, and
    Error() works without new.

  1.2.8
  - Internet radio: WWW menu -> Radio PL (TOK FM, Radio ZET, Antyradio,
    Chillizet, Radio 357, Radio Nowy Swiat, RMF and more) and Radio DE
    (Deutschlandfunk, SWR3, 1LIVE, NDR 2, Bayern 3, Antenne Bayern and
    more); FIP and KEXP added to Radio.
  - MP3 sound needs about a quarter less CPU, and AAC sound (radio and the
    soundtrack of movies) a little less again - with exactly the same
    sound as before.
  - Fixed: movies (YouTube too) skipped frames while the stream was still
    loading and played in bursts with a short stop every second - they now
    play smoothly.
  - A short link (tinyurl, bit.ly...) that leads to a YouTube movie now
    opens it in the built-in player.
  - JavaScript: string length, indexes and regular expressions count
    characters (as other browsers do), not bytes - Polish and other
    accented letters no longer break text handling and form checks.
  - JavaScript: element.attributes, document as a Node, and error
    messages (toString) behave as in other browsers.
  - JavaScript: Shadow DOM (attachShadow, slots) and element.style.cssText.
  - JavaScript: numbers are printed and read exactly as in other browsers
    (0.1+0.2 gave "0.3", very large and very small numbers lost digits).
  - JavaScript: typed arrays and DataView share their buffer correctly
    between views, and values out of range wrap around as they should.
  - JavaScript: building long texts piece by piece is much faster.
  - JavaScript: DOM methods report errors as other browsers do (a node
    inserted into itself, a method called on something that is not a
    node) instead of silently doing nothing.
  - Movies: the full-screen button is now only on the player bar (it was
    also on the main toolbar).
  - JavaScript: custom elements created through innerHTML or importNode
    work at once; the arguments object behaves as in other browsers.
  - Fixed: styles did not follow a class that a page script added to an
    element already on screen, and a rule like #id.class > .x could hit
    elements it should not.
  - CSS: the scale property.
  - Fixed: Settings -> Screen Mode crashed on 64-bit AROS (hosted) when the
    browser ran on Workbench; it now uses the same requester as at startup
    and lists 24-bit modes.
  - New: MorphOS versions of the browser and mail client (first release).

  1.2.7
  - Fixed: a long movie (hours, hundreds of thousands of frames) stayed on
    "Fetching the movie... 1%" forever; the sample table is now read in one
    pass, so such a file starts playing within seconds.
  - JavaScript: pages keep far less memory - scripts that run for a long
    time (web applications) no longer run out of memory, because unused
    objects are now collected while the page is open, not only when leaving.
  - JavaScript: large scripts load faster and use much less memory (function
    bodies are compiled when first called).
  - JavaScript: custom elements (customElements.define), MutationObserver,
    WeakRef, FinalizationRegistry; top-level variables are now properties of
    window, as in other browsers.
  - Movies: full screen. A button at the right end of the player bar asks
    for a screen mode, with the best mode for the movie already selected.
    Esc or the right mouse button leaves, the left button or Space
    pauses, a click on the bar seeks, cursor keys skip 10 s and change
    the volume.
  - Movies: volume slider with a mute button on the player bar; the setting
    is remembered.
  - Movies play faster: the picture is converted and scaled several times
    faster (most on 8-bit and AGA screens), frames are handed over without
    waiting for the next tick, and AAC sound needs about a third less CPU.
  - Internet radio: the <audio> element, AAC and MP3 streams and .pls /
    .m3u playlists play in the browser; WWW menu -> Radio lists stations
    with format and bitrate. A 68040/25 keeps up with AAC and 22 kHz MP3;
    44.1 kHz MP3 needs a faster CPU. HE-AAC streams play at reduced quality
    (mono). Same executables as the movie player.
  - Fixed: search and other forms handled by page scripts (olx.pl) did
    nothing - the submit event is now sent to scripts.
  - Fixed: pages that scroll their body instead of the whole document
    (news.google.com) could not be scrolled past the first screen.
  - JavaScript: await no longer freezes the page while it waits; __proto__
    works as in other browsers.
  - JavaScript: spreading or looping over a text (for-of, [...s], Array.from)
    gives whole characters - Polish and other accented letters were split
    into two broken halves.
  - Fixed (AGA/OCS/ECS screens, since 1.2.5): some icons drawn at their own
    size (for example "Premium" on wp.pl) were scrambled.

  1.2.6
  - Fixed (AGA/OCS/ECS own screens): pictures kept in the disk cache by an
    earlier version came back as coloured garbage in 1.2.5, whose chipset
    screen stores bitplanes interleaved. The cache now records the layout and
    decodes such a picture again instead of showing it scrambled. The first
    visit to a page after upgrading fetches its pictures once more.
  - Fixed (AROS): the Home button's house icon was drawn scrambled.
  - Tabs and panels built from radio buttons and CSS alone (`:checked + label
    + .tab`) now open and switch when clicked.
  - youtube.com's front page: the top bar with its menu icon now appears.
  - Many layout fixes found by comparing pages with a modern browser:
    letter spacing in em and fractional pixels, spaces at the start and end
    of a line no longer widen buttons and menus, flex columns shrink items
    with a stated height, justify-content after an item stops growing,
    selectors with escaped characters (Tailwind's gap-0.5, md:gap-5), media
    queries with a percentage now never match, calc() in gap, padding,
    margin, top/left and grid lines, min-width on images, absolutely
    positioned boxes with min-height in percent, and more.

  1.2.5
  - IMPORTANT when upgrading: Amelinium_040, Amelinium_060 and their _JS
    versions now need a real maths coprocessor. A 68EC040, 68LC040, 68EC060 or
    68LC060 has none and will refuse to start, saying so. Use Amelinium_020 or
    Amelinium_020_JS on those machines - that is what they were getting
    anyway, because until now the accelerated builds linked 68000 libraries.
    In exchange the 040 and 060 builds now really use the processor they are
    named after: JavaScript arithmetic runs on the coprocessor instead of in
    software, and pictures decode faster.
  - New: video playback. A <video> with an MP4 file (H.264 picture, AAC
    sound) shows its poster and a player bar with play/pause and a seek
    groove, and starts playing while the file is still arriving. Clicking
    anywhere on the groove jumps there, even far past what has arrived - the
    download simply restarts from that point. Sound goes through Paula in
    stereo, the picture through a built-in H.264 decoder, each in its own
    process so the browser stays usable. The download is held in a fixed
    16 MB ring on disk, so a long film does not need its full size in free
    space. Available in the 040 and 060 builds and in the AROS, AmigaOS 4 and
    PPC-card builds; the 68000 and 020 builds do not carry the decoders.
  - New: a YouTube watch address opens in Amelinium's own player page instead
    of youtube.com, which needs JavaScript and cannot load here. The page shows
    the title, channel and length. Settings -> Video quality picks 144p (the
    default), 240p, 360p or sound only; Settings -> Video playback picks how
    often a new picture is decoded - key frames only by default, which costs
    least. At 1, 6, 12 or 24 frames per second the frames that are not going
    to be shown and that no other frame depends on (more than half of a
    YouTube film) are skipped without decoding. Decoding a picture is heavy
    work: a 640x360 frame can take seconds on a plain 040, so 144p is the
    setting for a classic machine.
    In the builds with JavaScript, 144p and 240p play for the whole length of
    the film, fetched the way YouTube's own embedded player fetches them
    (YouTube's player code is downloaded once and kept in the cache), and
    the seek groove jumps anywhere in them, backwards too. The
    builds without JavaScript get 144p and 240p only up to about a minute of
    film; anything longer comes as 360p there, and the player page says so.
  - New: WWW -> Video -> "YouTube search (Invidious)" - a YouTube search page
    light enough to render here. Opening one of its videos asks whether to
    play it in Amelinium's own player, with "Always" if you want it to stop
    asking.
  - New: Amelinium_WOS and Emalinium_WOS - a WarpOS build for a PPC card in a
    classic Amiga, with JavaScript, HTTPS and TrueType fonts. This is the
    FIRST version of this target and it may not be perfect - please report
    what you run into. One thing is known already: laying out a page takes
    considerably longer on it than on the PowerUP build of the same page, so
    a big site will feel slow.
  - Faster: JavaScript source is read a quarter to a third faster, so
    script-heavy pages get going sooner - YouTube's player code alone is
    ready about eight seconds earlier on a 68040. How scripts behave does not
    change.
  - Better picture on AGA/ECS: the browser's own screen is now opened
    interleaved, so a picture on its way to the screen no longer flashes in
    wrong colours while it is drawn plane by plane - most visibly with every
    new frame of a video. RTG screens are not affected.
  - Fixed: a download that the server cut short was reported as finished,
    leaving a half file that looked whole. It is now shown as interrupted,
    and Resume continues it from where it stopped.
  - Fixed: JavaScript: dates written with a time zone or in e-mail form
    (new Date("2026-09-24T10:00:00+02:00"), Date.parse) were read wrong or
    not at all; obj[key]() evaluated obj twice; slice, splice and friends
    misbehaved when given Infinity; a typed array's .buffer was a method
    instead of a property; eval() inside a function could not see the
    function's own variables; btoa and atob mishandled characters above 127;
    a regular expression right after if (...), for (...) or while (...) made
    the whole script fail to load (Babel, among others). And from the second
    page of a session on, some built-in functions - Number.isInteger,
    String.fromCharCode, Boolean's methods, DataView and typed array methods
    among them - could silently turn into unrelated functions, so scripts
    that worked on the first page failed on the next one.
  - Fixed: HTML entities written without a semicolon - &lt &gt &amp and the
    rest of the legacy list - now decode, as they do in every other browser.
    They appear in plenty of old pages.
  - Fixed: with many bookmarks the menu silently stopped at the fortieth one.
    It now fits as many as the screen can show and splits into B1, B2, ... when
    it needs to.
  - Fixed: Page -> View Source ignored the scrollbar arrows, did not follow the
    knob while dragging, and drew with the page font instead of the screen font.
  - Fixed: clicking a #name anchor, or opening an address that carries one, now
    jumps to it.
  - Fixed: images embedded in the page itself (data: URLs) longer than about a
    kilobyte were not loaded at all.
  - Fixed: text-align set on a table did not reach its cells.
  - New: PageUp and PageDown scroll a page, on keyboards that have them
    (a PC-style keyboard on AmigaOS 4 or AROS).
  - Fixed: selecting text and copying it could pick up a second copy of part of
    the selection, and a selection finished outside the window was not copied
    at all.
  - Fixed: a plain .txt file was rendered far too large and did not wrap.
  - Fixed: SVG pictures written directly into a page now draw their outlines,
    lines and text - until now only the filled shapes appeared, so logos and
    icons made of strokes were blank and labels were missing.
  - Fixed: an <a name="..."> anchor with no href was drawn as a blue underlined
    link.
  - Fixed: a crash on AROS on pages that use :hover on an element with no
    parent.
  - Fixed: many page layouts now match other browsers more closely, found by
    comparing sites element by element. Among them: menus built from floating
    list items with height:100% links no longer collapse to nothing; a
    "sticky footer" page (html, body { height: 100% }) is as tall as the
    window; table rows ignore min-height and max-height as other browsers do;
    percentage margins inside flex rows (Bootstrap column offsets) land in the
    right place; hidden SVG icon sheets take no space; a floating box with a
    horizontal rule inside is no longer twice as wide; the gap above a heading
    after an invisible "skip to content" link is correct; flex items align,
    wrap and line up on text like elsewhere; line-height written as calc()
    works; rem sizes follow a root font size set through a variable; a text
    field with a percentage width no longer pushes a table wider than the
    page; and <input type="hidden"> never takes space, whatever the page's
    stylesheet says. Also: max-height: none now lifts an earlier limit, so
    sections that open without JavaScript are no longer empty; Tailwind class
    names with escaped characters (such as [&>svg]:h-full) match; an SVG with
    only a height keeps its proportions; </br> breaks the line as in every
    browser; custom element names longer than eleven letters match in
    selectors; the -webkit- spellings of flexbox work; media queries for
    features Amelinium does not know no longer apply by accident;
    :first-child and similar conditions on a parent in a selector are
    checked; :any-link and :not() on a parent element work; Tailwind's
    space-y-* spacing and its @property variables apply; ::before and
    ::after built from several rules or inside @layer get all of them;
    children of a display: contents box inside a flex or grid container
    become blocks; calc() widths of flex items keep their pixel part;
    left: auto (and the other sides) cancels an earlier value; a very wide
    logo keeps its proportions under max-width; and a page opened from disk
    finds its stylesheets and pictures when they are addressed as ./ or ../.
    Further: rules that start with an attribute, such as
    [role=complementary] h3 or [x] .a+.b, apply; percentage padding on flex
    items, and padding or margin written with calc() in the shorthand
    (Tailwind), come out right; text placed straight into a flex container no
    longer takes the container's own width; an SVG icon given only a width
    keeps its proportions; a selector like .menu > a i no longer reaches icons
    nested deeper; and alternate style sheets (rel="alternate stylesheet")
    are no longer applied on top of the main one.
  - Emalinium: the message list now really sorts by date, newest first, and
    stays sorted after deleting a message. The Compose window opens far larger,
    can be resized, and keeps what you have typed while you resize it. Its
    scrollbar arrows work too.

  1.2.4
  - New: Settings -> "Polish letters with Alt". With it on, Alt plus
    a c e l n o s x z types the Polish letters directly, whatever keymap the
    system has loaded - Shift gives the capitals. It is off by default and
    changes nothing when off, so Alt+A still gives the letter your keymap
    says. Added because on a machine with no Polish keymap the keyboard never
    produces a Polish byte at all, so no choice of encoding could help.
    If the letters look wrong on screen but arrive correctly in the page, your
    screen font simply has no Polish glyphs - pick the encoding your font uses
    from the same list, or turn TrueType on.
  - Fixed: on the Workbench screen the browser overwrote the shared palette, so
    the colours of everything else on Workbench went wrong until those programs
    were restarted. Own screens were never affected. This was new in 1.2.3.
  - The right-click context menu is drawn in the screen font now - the same one
    the window title uses. It used to take the System Default Text font, which
    is a different preference, so on a Workbench where the two differ the menu
    looked out of place.
  - Settings -> Keyboard/font is now a submenu offering twelve encodings
    instead of three. Amiga has its own ones: AmigaPL for Polish and
    Amiga-1251 for Russian put the national letters at byte positions no PC
    encoding uses, so a keymap that speaks them looked like garbage before.
    The list also has Latin-2/3/4/5/9/10, ISO-8859-5, KOI8-R and CP1250.
    Pick the one your keymap and your screen font use; the setting is
    remembered, and -charset NAME does the same from the Shell.
  - Latin-9 (ISO-8859-15) could be read but not written: a euro sign typed
    into a form was dropped, and a currency sign was sent as a euro.

  1.2.3
  - New: PowerUP builds for a PPC card in a classic Amiga (Blizzard PPC or
    CyberStorm PPC under OS 3.x) - Amelinium_PUP and Emalinium_PUP. The
    browser has JavaScript and HTTPS; TLS is compiled in, so AmiSSL is not
    needed and not used on this target.
  - New: JavaScript in the AmigaOS 4 build. Amelinium_OS4 never had it before,
    which was not obvious - the binary looked and started the same, and the
    difference showed only on a page that needs scripts.
  - PowerUP: Date.now() returned the same instant forever, any number above
    2147483647 printed wrong, and x|0 gave the wrong answer for such numbers.
    One cause: floor, ceil and modf in the target's C library round through a
    32-bit integer, which the PowerPC saturates. This target now brings its
    own three, so clocks, Math and number printing behave like everywhere else.
  - PowerUP: a hexadecimal number written as 0xNN was read as zero, so, for
    example, String.fromCharCode(0xFB01) produced a NUL byte.
  - PowerUP: the thousands separator for Polish, Czech, Russian and the other
    languages that use a space came out as the text "u00a0" in
    Intl.NumberFormat.
  - Tables: a cell whose rowspan reaches past the end of the table no longer
    leaves its row short, so the cell stopped sticking out of the row.
  - min-width: auto was ignored. A page that removes its desktop minimum this
    way - which is how responsive sites do it - came out wider than the
    window, so every percentage and every centred block was measured against
    the wrong width.
  - Grid: a column sized auto next to 1fr came out zero-width. That is the
    ordinary "logo on the left, content on the right" header.
  - flex-wrap did not break a line when an item's own minimum already filled
    it, so the items after it were laid out past the right edge of the
    container.
  - Content written inside a table but outside a cell now moves in front of
    the table, the way every browser does it. Old hand-written pages rely on
    this, and without it everything below such a table was misplaced.
  - A page sent with a compression we cannot decode (Brotli, for example) now
    says so on an error page that names the encoding, instead of drawing the
    compressed bytes as text.
  - Text areas: the scrollbar can be grabbed (its clickable area used to sit
    beside the field, over the page), and lines no longer spill above and
    below the box.
  - Keyboard and screen font now speak the system's character set. Settings ->
    Keyboard/font offers Latin-1, Latin-2 and CP1250. Before this, national
    characters looked right on screen and arrived at the server as garbage -
    the two errors cancelled out locally, which is why it went unnoticed.
  - The title bar no longer keeps "- Loading..." after the page has finished.
  - version <file> from the Shell now answers on the 64-bit ARM builds; the
    $VER: string was missing there.

  1.2.2
  - New: AmigaOS 4 (PowerPC) builds - Amelinium_OS4 and Emalinium_OS4
  - HTTPS through a proxy now works. The browser opens a tunnel, the way
    other browsers do; before this some HTTPS sites loaded and others did
    not, with no pattern the user could see
  - Saving a page now uses the page's own file name instead of always
    calling it page.html
  - The ttf button on the toolbar now downloads the TrueType fonts when
    they are missing, exactly like the menu entry does. Turning fonts on
    from the toolbar used to do nothing on a fresh install
  - Pictures written with a line break or a tab around the = in the tag
    are now loaded. Such pages were missing images, and the space they
    should have taken collapsed
  - <br clear=left|right|all> now moves the content after it below the
    floating element, as it did in the browsers these pages were written for
  - Widths above 200% are honoured. A block asking for 600% came out three
    times too narrow, which broke wide sliders and carousels
  - align on an image submit button now floats it, like every other browser
  - vertical-align written in a stylesheet now works for super, sub,
    text-top and text-bottom; table cells set to baseline line their text
    up on one baseline instead of sitting at the top
  - Percentage widths now get their exact share of the container instead of
    always rounding down. Three columns at 33.333% fill a 999px container
    exactly, where before they lost three pixels - for blocks, floats and
    inline-blocks alike, and for columns sized with box-sizing: border-box.
    Two 50% columns in an odd-width container still sit side by side, and a
    min-width or max-width on such a column is no longer overridden
  - Cookies a site marks SameSite=Strict or SameSite=Lax are no longer sent
    when another site's page pulls that site's images or stylesheets. They
    still go out normally when you open the site yourself, and when the site
    loads its own files
  - A page's images, stylesheets and scripts now name that page as the
    referrer. They used to name the page you were on before it
  - Search menu: lite.duckduckgo.com added
  - A failed connection now says WHAT went wrong - the reply timed out, the
    connection was reset, the server closed without answering, the request
    could not be sent - instead of a single "Connection Failed" for every
    case. Going Back or switching tabs also names the HTTP status, and says
    so plainly when the browser itself refused (a redirect to https on a
    build without AmiSSL)
  - Start page redesigned

  1.2.1
  - Fixed pages laid out with frames that set both rows and columns: they
    came up as a blank page, because only one of the two was read
  - A page that asks to reload itself after a number of seconds now waits
    that long. Weather, webcam and departure boards reloaded at once, over
    and over, and were unusable
  - Dropping a file icon from Workbench onto the browser window opens it.
    Works when the browser runs on the Workbench screen
  - Emalinium shows the body of messages that used to read "(No viewable
    content)": those whose text sits behind more than 32 attachments, and
    those with an unusually long MIME boundary
  - Emalinium: a long subject no longer runs under the message list scroll bar
  - Fixed sites that stopped loading with "cannot connect" and no error code
    once enough cookies had piled up - Google News and Pouet were reported.
    The request grew past its buffer and never finished; deleting the cookies
    drawer used to be the only cure
  - Fixed opening files on a volume whose name contains a space, such as the
    standard "Ram Disk:". They were taken for web addresses

  1.2.0
  - Added Emalinium, the mail client, for all four AROS targets
  - Fixed addresses containing a space: they went to the server unencoded, so a
    server answered 400 where every other browser gets 200. It affects every
    request the browser makes - pages, images, style sheets and downloads
  - Fixed typing national characters into form fields. Letters such as a, o and
    a with diacritics did nothing at all, and pasting them did nothing either,
    so a password with one in it could not be entered
  - Fixed pages that hide or show their own parts with a style sheet built by a
    script
  - Fixed the message list in Emalinium: it has its own scroll bar and grows
    with the window, instead of showing a handful of messages. Its arrows are
    no longer painted over by the list itself, and the counter in the header
    stays empty until a mailbox is open
  - Dragging a selection across a page no longer repaints the whole page, so it
    flickers far less on a long one
  - Improved layout in several places, so pages come out closer to what other
    browsers show: lengths in em now follow the element's own font size,
    fixed-width text keeps its smaller default size, flexible boxes shrink by
    the rule, and old pages get the font size a browser gives them in tables
  - Added demozoo.org to the WWW menu and removed thedaemons.space, which no
    longer answers
  - Fixed the text size on pages that set it on the root element twice, once
    through :root and once through html. The whole page was drawn a couple of
    points too small
  - Fixed grids whose column widths are written with calc() or left to the
    browser: their contents were laid out one under another, each across the
    full width, instead of side by side
  - Fixed line spacing where a page asks for the font's own spacing, and made
    !important work for that property
  - Fixed rules with several parts, such as ".header nav li a", applying to
    links that had nothing to do with that header - they were styled as if they
    belonged to the menu
  - Fixed pages built with Tailwind: one escaped character in a class name made
    every nested rule in that style sheet dead
  - Fixed background images given directly on an element (style="background-
    image:url(...)"). They were never loaded, so a banner showed as empty space
  - Fixed <hgroup>, <search>, <dir>, <xmp>, <listing> and <optgroup>, which were
    unknown to the layout and ran into the surrounding text
  - Fixed hidden form fields taking up room in flexible boxes

  1.1.9
  - Text on a page can be selected by dragging the mouse over it, and the
    copy shortcut puts it on the clipboard. A site that forbids selection in
    its style sheet is obeyed, exactly as in any other browser
  - Text in Greek, Cyrillic or Polish no longer disappears on pages that use
    a downloaded font. Such fonts are usually cut down to the Latin letters,
    and the characters they lack were being drawn as nothing, leaving what
    looked like huge gaps between words. A missing character now comes from a
    built-in face, and only that character changes - the rest of the word
    keeps the page's own font
  - View Source no longer redraws the whole text every time the mouse moves
    over its window, and dragging the scroll bar's knob no longer fights with
    the pointer

  1.1.8
  - Web fonts are used when a site offers them as TrueType. Icon fonts -
    Font Awesome, Bootstrap Icons, Material Icons - draw real symbols now
    instead of empty boxes, because they place their glyphs at private code
    points that only the site's own font carries. Each font is fetched once
    into the ttfonts drawer and reused on later visits
  - Fixed downloads coming out corrupt from servers that send a file in
    chunks. The chunk headers were being written into the file, so it was a
    few dozen bytes too long and would not open. Affects every download, not
    just fonts
  - Shopping baskets and other content hidden behind <noscript> no longer
    disappear when scripts are on. A shop that hides its cart for
    script-less visitors was hiding it from us as well
  - Accepting a cookie notice is remembered between sessions. The date the
    page hands us was written in a format we misread as the year 12, so
    every such cookie expired the moment the browser closed
  - View Source shows the whole document: it has a scroll bar now, and long
    lines wrap instead of being cut at the window edge. A minified page is
    one very long line, so previously only its first screenful was reachable
  - The document's default font is now serif, as in every desktop browser.
    Pages that name no font of their own - most of the older web - were
    being laid out too wide
  - A byte order mark at the start of a style sheet no longer swallows the
    sheet's first rule. Today that rule is usually the one carrying a
    theme's colours, sizes and spacing, so the whole page was affected
  - Tags written inside an HTML comment are no longer obeyed. A commented-out
    style block was still being applied and a commented-out style sheet still
    fetched
  - Text no longer breaks after a single character on pages that size a
    column in "ch" units, which we were reading as plain pixels
  - align="justify" works on paragraphs, and a space at the end of a line no
    longer takes up room - which also nudged centred and right-aligned lines
    into place
  - Margins and padding on the <html> element now inset the page, and
    <hr align=...> is placed where it belongs
  - A list inside a list no longer leaves a gap under it, and line heights
    match the browser on serif faces
  - Old markup of the form <p>...<b><h3>...</h3></b> keeps the bold inside
    the heading, the way every browser reconstructs it
  - A rule written for a part of a widget we do not draw (::file-selector-
    button, ::placeholder and the like) is dropped instead of being applied
    to the element itself
  - A horizontal margin on a link or span no longer pushes what follows onto
    the next line, which was making rows twice as tall
  - Boxes positioned with left+right or top+bottom take their margins into
    account, and a box sized by top+bottom now has that height before its
    content is laid out - so icons centred inside it land in the middle
  - A flex item keeps its contents' margins to itself, so a column no longer
    comes out short by the margin of whatever is inside it
  - Characters whose UTF-8 form ends in the byte A0 - the dagger, several
    currency signs, and some icon-font symbols - are drawn as one character
    again instead of three
  - system-ui is recognised as a font family, so sheets that ask for the
    system face get a sans-serif one
  - Emalinium saves every attachment of a message, one after another, and
    works on a machine that has only reqtools.library - both saving an
    attachment and adding one to a message you are writing
  - A file requester opened with no remembered drawer starts in PROGDIR:
    instead of nowhere in particular, which was misbehaving on AROS
  - Guarded against a crash on AROS aarch64 when picking a screen mode: the
    number of colours is now read from the screen instead of assumed

  1.1.7
  - Uploading a picture to a site that does it with its own scripts now works
    end to end - postimages.org was refusing every attempt with "Automated
    uploads are not allowed via the website" because we left out headers that
    every browser sends (Origin, Referer and the three Sec-Fetch-* ones), and
    a file picker opened from a script now opens the requester as it should
  - Fixed downloading release files from GitHub. The file list inside "Assets"
    is fetched only when you expand it, which we did not do at all, and the
    signed download address that follows was being cut short, so the download
    came back as an error
  - Fixed buttons on sites built with Bootstrap being greyed out and refusing
    clicks everywhere, and text fields inside a button-and-field group being
    one character wide
  - Fixed a crash on AROS 64-bit, reported when opening github.com. AROS
    builds also get a much bigger stack, which they never did before
  - A <textarea> that is too small for its text now scrolls and shows a
    scrollbar instead of locking up
  - Pages now receive every kind of event they listen for - mouse movement,
    key presses, the wheel, pointer events - where before only a click and a
    mousedown ever reached them. Scripts waiting on the rest no longer hang
  - The busy pointer no longer stays up after a click that did nothing
  - Fixed Date.now() and new Date().getTime() disagreeing by the whole
    timezone offset - two hours here
  - The start page is now short and links to this readme, locally and online
  - Added postimages.org to the WWW menu

  1.1.6
  - Text in a form field can now be SELECTED - with the mouse (click puts the
    cursor where you clicked, drag selects), with Shift+arrows, and the
    selection is what Cut and Copy take. Editor toolbars on forums finally do
    what they say: the bold/italic buttons wrap what you highlighted
  - Fixed the text in a field jumping a few pixels, and sometimes reflowing,
    the moment you clicked into it. A field is now drawn the same way whether
    it has the cursor or not
  - Fixed uploading a file from a form without JavaScript. <input type=file>
    used to be an ordinary text field: you could type in it, and what you
    typed was sent instead of the file
  - Uploads that go through a page's own scripts work too (FileReader,
    FormData, XMLHttpRequest). A file's contents never pass through the
    script engine - they go from disk straight into the request - so a photo
    does not have to fit in memory twice
  - A download can now be RESUMED. An interrupted transfer keeps what it
    already has, the download window gains a Resume button, and the unfinished
    entry stays on the downloads list with its own Resume link
  - Fixed the download list and the about page losing their scroll position
    when switching tabs, going Back or pressing F5
  - Fixed one failed page load making every later page load without images or
    stylesheets until the browser was restarted
  - Fixed prefs.txt written by a Windows text editor losing its first setting -
    Notepad adds a marker at the start of the file, and that marker was read as
    part of the setting's name
  - Font size keywords (small, large, x-large and the rest) came out one step
    too small, and did not follow the font family. Dates, bylines and captions
    on news sites were a size too small and wrapped where they should not
  - Font sizes given in viewport units (1.4vw and the like) meant one pixel -
    the text was there but invisible
  - Fixed percentage sizes on a box positioned outside the flow measuring
    against the box itself instead of against what contains it
  - ::before / ::after with no content no longer leave an empty box behind,
    which used to push list text onto the next line
  - Fixed rules of the "> * + *" shape - the usual way to space sections and
    lists today - applying everywhere on the page instead of to one level
  - Fixed a rule naming three or more parents (".a .b .c .d") losing the middle
    one, so it applied far more widely than written - on wikipedia every table
    of contents entry was affected
  - Fixed a parent named by tag ("header .thing") being dropped when the
    element itself had a class, so the rule applied to every ".thing" on the
    page
  - Stylesheets are now merged in document order when a <style> block sits
    between two <link>s, which is how a page decides which of two equal rules
    wins
  - A stylesheet linked for a narrow screen (media="(max-width:699px)")
    is no longer applied on a wide one - pages that ship a separate mobile
    sheet were getting both
  - Fixed a rule that names a parent further up ("#main ul > li > a") not
    applying when anything sat between that parent and the rest of the
    chain
  - Fixed columns coming out too wide, and a picture with a percentage size
    limit freezing its column at full width
  - Fixed a box laid out as a table (display:table) with padding of its own
    coming out wider than the room it had - the padding was added outside the
    box, so everything under it was too wide as well
  - box-sizing:border-box is now honoured on a stated table width, which is
    what the reset nearly every modern page uses asks for
  - :open is understood, so a closed <dialog> or <details> stays closed
  - calc(), min(), max() and clamp() work as a grid track size, and var() in
    grid-template-columns now reaches the layout - such grids used to collapse
    to a single column
  - Grid tracks written as minmax() are bounded by the space actually free
  - Fixed line-height smaller than the font being raised to the font's height -
    the standard way of collapsing a row you are not meant to see
  - flex-grow inside a column now works; before, items with "flex: 1" in a
    column came out with no height at all
  - Fixed max-height and min-height on an image in a block, and a percentage
    max-width letting an image shrink - the ordinary "img { max-width: 100% }"
    of every modern page
  - Several sizing fixes for boxes measured inside flex and grid: a box's own
    min-width/max-width now bounds what it asks its parent for
  - Fixed element.title reading back empty on every element of every page
  - option.text can be assigned, which is how scripts fill drop-down lists
  - Text in a <textarea> no longer shows a stray glyph at the end of each line
    on servers that send CRLF - most forums do
  - new String("x") and new Number(7) now carry their value, so scripts that
    wrap text before working on it no longer insert "[object Object]"
  - Functions have a prototype chain of their own, so classes written with
    "extends" and compiled down to older JavaScript work
  - Blob, File, FileReader and URL.createObjectURL exist, and a Worker can be
    started from a Blob - today's usual way of running one without a
    separate .js file
  - The whole stream family (ReadableStream, WritableStream, TransformStream)
    and Reflect are implemented
  - Object.prototype.toString.call(null) says [object Null]
  - New WWW menu section Amiga GR (amiga.gr), and theoasisbbs.com under Sites 2
  - New -fixed option: honour position:fixed from the command line, the same
    setting as Settings -> Respect position:fixed

  1.1.5
  - New target Amelinium_AROS_i386_v0 - AROS ABI v0, the classic 32-bit line
    from axrt.org. ABI v0 and ABI v1 are different systems, so take the file
    that matches the AROS you installed
  - Fixed changing the screen mode running a string of menu entries nobody
    picked - it would end up loading the downloads page over and over and
    the browser had to be restarted
  - New -zoom N option, so a zoom level can be set from the command line as
    well as from the Page menu
  - Fixed a zoomed page shrinking further every time one of its scripts
    changed anything, until the text was unreadable
  - Fixed the two buttons of the download window coming out blank. Their
    labels are now coloured against what is really drawn under them, so
    they stay readable whatever the screen palette is and whatever draws
    the buttons - including systems that give them their own look
  - Fixed new Function("...") returning nothing, which killed anti-bot and
    packed scripts on their first line, and added globalThis
  - Fixed x["length"], x["charAt"](1) and every other bracket form doing
    nothing on text, numbers, true/false, functions and symbols - obfuscated
    and minified scripts write nearly every call that way
  - Fixed two classes extending different parents in one file: the second one
    took the first one's parent
  - Fixed any empty function in a file that also uses "class X extends Y"
    hanging the browser
  - Fixed a class member whose name is computed (class X { [name]() {} }) or
    written as text being stored under the wrong name - among other things
    this is how a class is made iterable, and such a class was simply not
    iterable here
  - Fixed { get [name]() {} } in an object being a syntax error, which threw
    away the whole script file it appeared in
  - Very large whole numbers (BigInt) now hold five times as many digits, so
    the arithmetic behind today's anti-bot checks no longer refuses to start.
    Only a page that actually uses such numbers pays for the extra memory
  - Pages using a rule that asks about an attribute on a parent as well as
    on the element itself are no longer skipped - on github this is what
    hides the navigation icons on a narrow window, as it does in Chrome
  - Container queries (@container) are now understood. A page can size a part
    of itself against the box it sits in rather than against the window, and
    until now every such rule was skipped. A page that does not use them is
    unaffected
  - Pages that build part of themselves with document.write now show it. Five
    of the sites we test against use it, and on one of them it is the search
    box, which simply was not there before

  1.1.4
  - Two more sites in the WWW menu: whdownload.com and amigaworld.net
  - A page can now be scrolled while its pictures are still loading - the
    mouse wheel, the cursor keys and the scrollbars all work from the moment
    the text is on screen
  - The address bar now uses the largest font that fits the toolbar row
    instead of the smallest one
  - Fixed styling being dropped on pages that use very long class names, as
    CSS modules generate them - github lost part of its layout that way
  - Fixed icons drawn as SVG inside the page not appearing at all on pages
    that use many of them - github lost its logo and its menu button
  - Fixed background-color: currentColor doing nothing on an element (it
    worked on ::before / ::after), which is how github draws its menu button
  - Fixed colours and spacing on pages whose stylesheet writes custom
    property names with capital letters (github, a1k)
  - Fixed rules with more than one :where() being thrown away
  - Fixed long declarations using var() being cut in half and dropped
  - Fixed font: 1.4rem/1.5 ... being read as 1 pixel, which shrank whole
    menus on pages that size text in rem
  - Fixed selectors written as .a > * > .b matching nothing
  - Fixed an <svg> icon being placed BEFORE the text it belongs to, so it
    appeared on the wrong side of a button
  - Fixed line-height: 0 having no effect, and rows staying too tall
  - Fixed grid columns written as minmax(0, auto) coming out zero wide, which
    made button labels disappear
  - Fixed flex: 100% being read as three separate values, so flex rows that
    should wrap stayed on one line and ran off screen
  - Fixed the first line of an inline-flex or inline-grid box sitting too
    high, which made whole rows of links too tall
  - Fixed style="width:0%" and style="width:150%" being ignored - this is how
    progress bars and sliders are written
  - Fixed attribute selectors: only 17 of about 60 attribute names were
    known, so [hidden] and most others matched nothing
  - Fixed a :not() naming a class longer than 15 characters excluding
    nothing while still winning over the rule it was written to refine
  - Fixed an inline-flex or inline-grid box coming out too narrow, so an
    icon next to a label stuck out of its own link
  - Fixed an empty flex item taking one pixel of the row instead of none
  - Fixed grid columns written as min-content or max-content being widened
    to fill the container, which pushed button labels out of place and broke
    short words across two lines
  - Fixed an icon inside a grid button overflowing its own slot, which
    shifted the label left by the icon margin
  - Fixed a grid column of zero width still taking one pixel
  - Fixed a box positioned inside a flex container ignoring the container's
    alignment unless that container was itself positioned - github placed
    the buttons above its file list 40 pixels too low
  - Fixed the Search button and Enter doing nothing on a form written between
    <table> and <tr> (whdownload.com)
  - Fixed a frame staying blank when its address is relative - the other
    frames of the same page hid the problem (triumph.no)
  - Fixed pictures inside a frame losing their transparency, so GIFs with a
    transparent background came out on a solid block
  - Fixed a frame ignoring its own character set, so accented letters were
    drawn wrong even though the frame declared the encoding
  - Fixed pictures being lost for good when a server asks the browser to slow
    down (HTTP 429) - it now waits as long as the server asks and tries again
  - Fixed aminet.net stalling on Kickstart 1.3 and on any machine short of
    memory: every stylesheet reserved almost 2 MB whatever its size, and now
    takes only what its text needs
  - Fixed Amiga-V typing a letter into a form field instead of pasting, and
    doing nothing at all in the address bar
  - Fixed pressing Amiga-V in the address bar loading the downloads page over
    and over and locking the browser up - a menu item nobody picked
  - Fixed the status bar staying on "Converting image" for good after the page
    had finished, once scrolling brought a new icon into view

  1.1.3
  - New target Amelinium_AROS_aarch64 - AROS on 64-bit ARM (Raspberry Pi 3/4/5).
    Same engine as every other target.
  - Settings: the WEBP/SVG image proxy can now be switched off
  - Fixed a page getting a horizontal scrollbar because a line refused to break
    before a nowrap element
  - Fixed the page background jumping when only part of the page was redrawn,
    e.g. under the mouse pointer
  - Fixed tables built with a <form> between <table> and <tr> - rows are no
    longer pulled out of the table
  - Fixed a crash on start on machines with no TCP/IP stack

  1.1.2
  - New target Amelinium_AROS_x86_64 - AROS on 64-bit PCs. Same browser as
    everywhere else: https, pictures, TrueType fonts and JavaScript all work
  - Fixed the AROS x86_64 build crashing on the first picture of any page
  - The user agent now says which build is running (AROS i386 or AROS
    x86_64), instead of just "AROS"
  - Fixed 1.1.1 hanging with corrupted graphics on every page - a rewrite of
    the tag scanner had dropped the line that sets where a tag's attributes
    begin, so every tag of every page was parsed from a stray address
  - Fixed pages showing raw markup as text when an attribute value contains a
    literal > - the tag now ends at the quote that closes the value, in both
    parsers (this is the EAB "The Zone" report)
  - Fixed text meant only for screen readers being painted over the page:
    clip: rect() now really clips
  - Fixed elements hidden with large negative offsets (left:-9999px) coming
    back on screen - the value was being read as a percentage
  - Fixed table columns growing instead of shrinking when a cell states a
    width: the stated width is now a hint for the column, not its minimum
  - Fixed a form field set to width:100% stretching its table and squeezing
    the button beside it narrower than its own label
  - Fixed pictures and form controls coming out too wide on pages that use
    box-sizing: border-box
  - Fixed a table cell that is floated or absolutely positioned losing its
    layout and rendering nothing
  - Fixed grid columns written as 1.45fr being laid out as 1.4fr
  - Old table layouts without a DOCTYPE: a collapsible space no longer makes
    a row taller, and a cell no longer takes on its children's margins
  - Fixed flex rows overflowing when one item could not shrink
  - Fixed the last word of a broken-up long word being measured too narrow
  - Back, Forward and switching tabs now follow server redirects
  - Addresses typed with a capitalised scheme are shown lower-case, and a site
    is recognised whatever the case of its host name
  - Fixed connections to older (HTTP/1.0) servers being kept after the server
    had closed them
  - Two more phone user agents in the Agent menu
  - An interrupted update download is no longer installed over the browser: a
    transfer that stalls is reported as a failure, and the downloaded file is
    checked for completeness before it replaces the program

  1.1.1
  - JavaScript now works in the AROS i386 build - the JS button is no longer
    greyed out there
  - Added the Popover API: an element with the popover attribute stays hidden
    until it is shown, and popovertarget buttons open it without JavaScript
  - Fixed images going missing on pages that load many at once - our own
    decoding time was being charged against the other downloads
  - Fixed one failed connection writing off a whole host, so the rest of a
    gallery was skipped
  - Fixed frameset images: they now reuse connections, retry once, and can go
    through the SVG/WebP rasteriser like every other picture
  - Fixed addresses typed HTTP:// or HttpS:// being treated as unknown - the
    scheme is case-insensitive (RFC 3986)
  - Fixed the URL field text sitting one pixel too high and too far left

  1.1.0
  - New target Amelinium_AROS_i386, with TLS 1.2 and 1.3 BUILT IN - no AmiSSL
    and no extra library to install; AmiSSL has no AROS release at all
  - Images now load six at a time instead of two, and the browser backs off by
    itself when a server refuses that many
  - Fixed three separate ways pictures could silently go missing
  - Faster layout and text measurement on heavy pages
  - Fixed "no AmiSSL for https" on AROS sending the user after a library that
    does not exist for that machine
