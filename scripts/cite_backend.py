#!/usr/bin/env python3
"""Fetch all Zotero library items and export BibTeX entries."""

from __future__ import annotations

import os
import re
import sys
from typing import Any, Optional

from pyzotero import zotero


def get_zotero():
    required = ("ZOTERO_API_KEY", "ZOTERO_LIBRARY_ID", "ZOTERO_LIBRARY_TYPE")
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(f"Missing environment variables: {', '.join(missing)}")
    return zotero.Zotero(
        os.environ["ZOTERO_LIBRARY_ID"],
        os.environ["ZOTERO_LIBRARY_TYPE"],
        os.environ["ZOTERO_API_KEY"],
    )


def display_item(item: dict[str, Any]) -> Optional[str]:
    data = item.get("data", {})
    if data.get("itemType") in {"attachment", "note", "annotation"}:
        return None

    title = data.get("title") or "Untitled"
    creators = data.get("creators", [])
    if creators:
        first = creators[0]
        author = first.get("lastName") or first.get("name") or "Unknown"
        if len(creators) > 1:
            author += " et al."
    else:
        author = "Unknown"

    match = re.search(r"(\d{4})", data.get("date", ""))
    year = match.group(1) if match else "n.d."
    return f"{title[:90]} | {author} ({year}) [{item.get('key', '')}]"


def list_items() -> int:
    client = get_zotero()
    items = list(
        client.everything(client.top(limit=100, sort="dateModified", direction="desc"))
    )
    displayed = [line for item in items if (line := display_item(item))]
    if not displayed:
        print("The Zotero library contains no citable items.", file=sys.stderr)
        return 1
    print("\n".join(displayed))
    return 0


def export_bibtex(zotero_key: str) -> int:
    entries = get_zotero().items(itemKey=zotero_key, content="bibtex", limit=1)
    if not entries:
        print(
            f"No BibTeX entry returned for Zotero item {zotero_key}.", file=sys.stderr
        )
        return 1
    print(entries[0].strip())
    return 0


def main() -> int:
    try:
        if len(sys.argv) == 3 and sys.argv[1] == "--bibtex":
            return export_bibtex(sys.argv[2])
        if len(sys.argv) == 1:
            return list_items()
        print("Usage: cite_backend.py [--bibtex ITEM_KEY]", file=sys.stderr)
        return 2
    except Exception as exc:
        print(f"Zotero citation lookup failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
