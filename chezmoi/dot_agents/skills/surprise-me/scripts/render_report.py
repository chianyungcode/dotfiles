#!/usr/bin/env python3
"""Render a Surprise Me recommendation spec as a self-contained HTML report.

Usage:
    python render_report.py spec.json [--repo-root PATH] [--output-dir PATH]

The spec is JSON with this shape:
{
  "title": "Feature ideas for Example",
  "date_created": "2026-07-17",
  "subtitle": "Repository and competitor research",
  "sections": [
    {"id": "context", "heading": "Context", "html": "<p>...</p>"}
  ]
}

Section HTML is intentionally raw so the agent can include tables, citations,
details blocks, and the winner's decision gate. The script owns the document
shell, styles, date validation, slugification, and output path.
"""

from __future__ import annotations

import argparse
import datetime as dt
import html
import json
import re
from pathlib import Path


CSS = """
:root {
  color-scheme: light dark;
  --bg: #f7f7f4;
  --surface: #ffffff;
  --surface-muted: #eeeee9;
  --text: #20221f;
  --muted: #666b63;
  --border: #d8dbd2;
  --accent: #236b51;
  --accent-soft: #e0f1e8;
  --code: #edf0eb;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #171a18;
    --surface: #202521;
    --surface-muted: #2a302b;
    --text: #edf2ed;
    --muted: #aeb8ae;
    --border: #3d463f;
    --accent: #78d7ad;
    --accent-soft: #1d3b2e;
    --code: #2b332d;
  }
}
* { box-sizing: border-box; }
body {
  background: var(--bg);
  color: var(--text);
  font: 16px/1.65 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  margin: 0 auto;
  max-width: 1060px;
  padding: 2rem 1.25rem 5rem;
}
h1, h2, h3 { line-height: 1.2; }
h1 { font-size: clamp(1.8rem, 4vw, 2.7rem); margin-bottom: .5rem; }
h2 { border-bottom: 1px solid var(--border); margin-top: 3rem; padding-bottom: .5rem; }
h3 { margin-top: 1.7rem; }
a { color: var(--accent); }
.meta, .muted { color: var(--muted); }
.meta { margin-top: 0; }
.toc, .callout, .card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; }
.toc { padding: 1rem 1.25rem; }
.toc ul { margin: .5rem 0 0; padding-left: 1.3rem; }
.callout { background: var(--accent-soft); border-left: 5px solid var(--accent); padding: 1rem 1.15rem; }
.card { margin: 1rem 0; padding: 1.1rem 1.25rem; }
.card > :first-child { margin-top: 0; }
table { border-collapse: collapse; display: block; overflow-x: auto; width: 100%; }
th, td { border: 1px solid var(--border); padding: .55rem .7rem; text-align: left; vertical-align: top; }
th { background: var(--surface-muted); }
code, pre { background: var(--code); border-radius: 5px; }
code { padding: .1rem .3rem; }
pre { overflow-x: auto; padding: 1rem; }
pre code { padding: 0; }
blockquote { border-left: 4px solid var(--border); margin-left: 0; padding-left: 1rem; }
details { background: var(--surface-muted); border-radius: 8px; margin: .75rem 0; padding: .7rem 1rem; }
summary { cursor: pointer; font-weight: 650; }
footer { border-top: 1px solid var(--border); color: var(--muted); margin-top: 3rem; padding-top: 1rem; }
"""


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "surprise-me"


def validate_spec(spec: object) -> dict:
    if not isinstance(spec, dict):
        raise ValueError("spec must be a JSON object")
    title = spec.get("title")
    sections = spec.get("sections")
    if not isinstance(title, str) or not title.strip():
        raise ValueError("spec.title must be a non-empty string")
    if not isinstance(sections, list) or not sections:
        raise ValueError("spec.sections must be a non-empty list")
    for section in sections:
        if not isinstance(section, dict) or not all(
            isinstance(section.get(key), str) and section[key].strip()
            for key in ("id", "heading", "html")
        ):
            raise ValueError("each section needs non-empty id, heading, and html strings")
    date_created = spec.get("date_created", dt.date.today().isoformat())
    if not isinstance(date_created, str) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", date_created):
        raise ValueError("date_created must use YYYY-MM-DD")
    try:
        dt.date.fromisoformat(date_created)
    except ValueError as exc:
        raise ValueError("date_created is not a valid calendar date") from exc
    spec["date_created"] = date_created
    return spec


def render(spec: dict) -> str:
    title = html.escape(spec["title"])
    subtitle = html.escape(spec.get("subtitle", ""))
    sections = spec["sections"]
    toc = "\n".join(
        f'<li><a href="#{html.escape(section["id"], quote=True)}">'
        f'{html.escape(section["heading"])}</a></li>'
        for section in sections
    )
    bodies = "\n\n".join(
        f'<section id="{html.escape(section["id"], quote=True)}">'
        f'<h2>{html.escape(section["heading"])}</h2>{section["html"]}</section>'
        for section in sections
    )
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="generated-date" content="{spec["date_created"]}">
  <title>{title}</title>
  <style>{CSS}</style>
</head>
<body>
  <header>
    <h1>{title}</h1>
    <p class="meta">{subtitle} · Generated {spec["date_created"]}</p>
  </header>
  <nav class="toc" aria-label="Table of contents">
    <strong>Contents</strong>
    <ul>{toc}</ul>
  </nav>
  <main>{bodies}</main>
  <footer>Generated by <code>$surprise-me</code>. Repository evidence and web citations are included in the report.</footer>
</body>
</html>
"""


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("spec", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--output-dir", type=Path, default=Path("docs/chianyung/surprise-me"))
    args = parser.parse_args()

    spec = validate_spec(json.loads(args.spec.read_text(encoding="utf-8")))
    output_dir = args.output_dir if args.output_dir.is_absolute() else args.repo_root / args.output_dir
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f'{spec["date_created"]}-{slugify(spec["title"])}.html'
    output_path.write_text(render(spec), encoding="utf-8")
    print(output_path)


if __name__ == "__main__":
    main()
