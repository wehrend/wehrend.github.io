#!/usr/bin/env python3
"""
Check which English content pages are not yet translated to German.

Erstellt separate Listen für Pages (alles außer posts/) und Posts (unter posts/).
"""

import argparse
from pathlib import Path
import sys

EXTENSIONS = {".md", ".markdown", ".adoc"}

def collect_pages(root: Path, lang: str):
    base = root / "content" / lang
    if not base.is_dir():
        print(f"ERROR: Missing directory: {base}", file=sys.stderr)
        return set(), set()

    pages, posts = set(), set()
    for p in base.rglob("*"):
        if p.is_file() and p.suffix.lower() in EXTENSIONS:
            rel = p.relative_to(base)
            # Trenne Posts und Pages
            if str(rel).startswith("posts/"):
                posts.add(rel)
            else:
                pages.add(rel)
    return pages, posts

def report_missing(name, en_set, de_set):
    missing = sorted([str(p) for p in en_set - de_set])
    if missing:
        print(f"\nMissing German translations for {name}:")
        for rel in missing:
            print(f"  - {rel}")
        print(f"Total missing {name}: {len(missing)}")
    else:
        print(f"\n✅ All English {name} have German versions.")
    return missing

def report_orphans(name, en_set, de_set):
    orphans = sorted([str(p) for p in de_set - en_set])
    if orphans:
        print(f"\nGerman {name} without English counterpart:")
        for rel in orphans:
            print(f"  - {rel}")
        print(f"Total orphan {name}: {len(orphans)}")
    else:
        print(f"\nNo orphan German {name}.")
    return orphans

def main():
    ap = argparse.ArgumentParser(description="Find English pages/posts missing German translations.")
    ap.add_argument("--root", default=".", help="Project root (default: current directory)")
    ap.add_argument("--fail-on-missing", action="store_true",
                    help="Exit with non-zero code if any are missing")
    ap.add_argument("--show-orphans", action="store_true",
                    help="Also list German-only files")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    en_pages, en_posts = collect_pages(root, "en")
    de_pages, de_posts = collect_pages(root, "de")

    if not en_pages and not en_posts:
        print("No English content found under content/en")
        sys.exit(1)

    missing_pages = report_missing("pages", en_pages, de_pages)
    missing_posts = report_missing("posts", en_posts, de_posts)

    if args.show_orphans:
        report_orphans("pages", en_pages, de_pages)
        report_orphans("posts", en_posts, de_posts)

    if (missing_pages or missing_posts) and args.fail_on_missing:
        sys.exit(2)

if __name__ == "__main__":
    main()
