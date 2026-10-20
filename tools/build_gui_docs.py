"""Render the GUI manual offline using only the Python standard library.

This deliberately supports the small Markdown subset used by this manual:
headings, paragraphs, flat lists, tables, links, bold, and inline code.
"""
import argparse
import html
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "docs/gui/README.md"
OUTPUT = ROOT / "docs/gui/user-guide.html"


def inline(text):
    pieces, offset = [], 0
    for match in re.finditer(r"`([^`]+)`|\[([^\]]+)\]\(([^)]+)\)|\*\*([^*]+)\*\*", text):
        pieces.append(html.escape(text[offset:match.start()]))
        code, label, target, bold = match.groups()
        if code is not None:
            pieces.append("<code>" + html.escape(code) + "</code>")
        elif label is not None:
            if re.match(r"^(?:javascript|data):", target, re.I):
                raise ValueError("Unsupported documentation link")
            pieces.append('<a href="' + html.escape(target, quote=True) + '">' + html.escape(label) + "</a>")
        else:
            pieces.append("<strong>" + html.escape(bold) + "</strong>")
        offset = match.end()
    pieces.append(html.escape(text[offset:]))
    return "".join(pieces)


def render(markdown):
    lines = markdown.splitlines()
    body, contents, seen = [], [], set()
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        heading = re.match(r"^(#{1,3}) (.+)$", line)
        if heading:
            level, title = len(heading[1]), heading[2]
            anchor = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
            if anchor in seen:
                raise ValueError("Duplicate manual heading: " + title)
            seen.add(anchor)
            body.append(f'<h{level} id="{anchor}">{inline(title)}</h{level}>')
            if level == 2:
                contents.append(f'<li><a href="#{anchor}">{inline(title)}</a></li>')
            i += 1
        elif line.startswith("|"):
            rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                cells = [cell.strip() for cell in lines[i].strip().strip("|").split("|")]
                if not all(re.fullmatch(r":?-+:?", cell) for cell in cells):
                    rows.append(cells)
                i += 1
            body.append('<div class="table-wrap"><table><thead><tr>' + "".join("<th scope=\"col\">" + inline(cell) + "</th>" for cell in rows[0]) + "</tr></thead><tbody>")
            body.extend("<tr>" + "".join("<td>" + inline(cell) + "</td>" for cell in row) + "</tr>" for row in rows[1:])
            body.append("</tbody></table></div>")
        elif re.match(r"^(?:- |\d+\. )", line):
            ordered = bool(re.match(r"\d+\. ", line))
            tag = "ol" if ordered else "ul"
            body.append("<" + tag + ">")
            while i < len(lines) and re.match(r"^\s*(?:\d+\. |\- )", lines[i]):
                text = re.sub(r"^\s*(?:\d+\. |\- )", "", lines[i])
                body.append("<li>" + inline(text) + "</li>")
                i += 1
            body.append("</" + tag + ">")
        else:
            paragraph = [line]
            i += 1
            while i < len(lines) and lines[i].strip() and not re.match(r"^\s*(?:#|\||- |\d+\. )", lines[i]):
                paragraph.append(lines[i].strip())
                i += 1
            body.append("<p>" + inline(" ".join(paragraph)) + "</p>")
    return """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>HstWB Windows GUI user guide</title><style>
:root{color-scheme:light dark;--paper:#fff;--ink:#18202b;--edge:#bcc8d6;--link:#0058ad;--soft:#eef3f8}
*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:17px/1.65 system-ui,Segoe UI,sans-serif}
header{background:#0058ad;color:white;padding:1.2rem max(1rem,calc((100% - 1050px)/2))}header p{margin:0}
main{max-width:1050px;margin:auto;padding:1.2rem 1.4rem 4rem}a{color:var(--link);text-underline-offset:.18em}a:focus{outline:3px solid #e5a100;outline-offset:3px}
nav{border:1px solid var(--edge);background:var(--soft);padding:1rem 1.4rem;border-radius:6px}nav ul{columns:2;column-gap:2rem}
h1,h2,h3{line-height:1.25}h1{font-size:2.2rem}h2{margin-top:2.6rem;border-bottom:2px solid var(--edge);padding-bottom:.4rem}h3{margin-top:1.8rem}
li{margin:.4rem 0}code{font-size:.94em;background:var(--soft);padding:.1em .3em}.table-wrap{overflow-x:auto;margin:1.2rem 0}table{border-collapse:collapse;width:100%}th,td{border:1px solid var(--edge);padding:.65rem .8rem;text-align:left;vertical-align:top}th{background:var(--soft)}
@media(max-width:650px){nav ul{columns:1}body{font-size:16px}main{padding:1rem}}
@media(prefers-color-scheme:dark){:root{--paper:#15202c;--ink:#edf2f8;--edge:#526579;--link:#8cc5ff;--soft:#223346}}
@media print{:root{--paper:white;--ink:black;--edge:#aaa;--soft:#eee;--link:#164c80}header{background:white;color:black;padding:0}nav{display:none}main{max-width:none;padding:0}h2,h3{break-after:avoid}tr{break-inside:avoid}a{color:inherit}}
</style></head><body><header><p><strong>HstWB / Amiga Installer</strong> · Windows GUI documentation · Offline edition</p></header><main>
<nav aria-label="Guide contents"><strong>Contents</strong><ul>""" + "\n".join(contents) + "</ul></nav>\n" + "\n".join(body) + "\n</main></body></html>\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if the checked-in HTML is stale")
    args = parser.parse_args()
    text = SOURCE.read_text(encoding="utf-8")
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text):
        if not re.match(r"\w+://|#", target) and not (SOURCE.parent / target.split("#")[0]).exists():
            raise SystemExit("Broken GUI documentation link: " + target)
    result = render(text)
    if args.check:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != result:
            raise SystemExit("GUI HTML is stale; run tools/build_gui_docs.py")
    else:
        OUTPUT.write_text(result, encoding="utf-8")
    print("GUI guide HTML and local links verified.")


if __name__ == "__main__":
    main()
