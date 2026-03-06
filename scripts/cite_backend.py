#!/usr/bin/env python3
"""Fetch Zotero library items and export BibTeX entries."""

import os
import re
import sys
from pyzotero import zotero


def get_zotero():
    api_key = os.getenv("ZOTERO_API_KEY")
    lib_id = os.getenv("ZOTERO_LIBRARY_ID")
    lib_type = os.getenv("ZOTERO_LIBRARY_TYPE")
    return zotero.Zotero(lib_id, lib_type, api_key)


def list_items():
    zot = get_zotero()
    for item in zot.top(limit=100, sort="dateModified", direction="desc"):
        data = item.get("data", {})
        if data.get("itemType") in ("attachment", "note"):
            continue

        title = data.get("title", "Untitled")
        creators = data.get("creators", [])

        if creators:
            first = creators[0]
            author = first.get("lastName", first.get("name", "Unknown"))
            if len(creators) > 1:
                author += " et al."
        else:
            author = "Unknown"

        year = ""
        date = data.get("date", "")
        if date:
            match = re.search(r"(\d{4})", date)
            if match:
                year = match.group(1)

        print(f"{title[:70]} | {author} ({year}) [{item.get('key', '')}]")


def export_bibtex(zotero_key):
    zot = get_zotero()
    entries = zot.items(itemKey=zotero_key, content="bibtex", limit=1)
    if entries:
        print(entries[0].strip())


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--bibtex":
        export_bibtex(sys.argv[2])
    else:
        list_items()


if __name__ == "__main__":
    main()
