#!/usr/bin/env python3
"""Fetch Zotero library items for citation lookup."""

import os
import re
from pyzotero import zotero


def generate_cite_key(item: dict) -> str:
    """Generate a citation key from item metadata."""
    creators = item.get("creators", [])
    first_author = ""
    if creators:
        c = creators[0]
        first_author = c.get("lastName", c.get("name", "unknown"))
        first_author = re.sub(r"[^\w]", "", first_author).lower()

    year = ""
    date = item.get("date", "")
    if date:
        match = re.search(r"(\d{4})", date)
        if match:
            year = match.group(1)

    # First word of title
    title = item.get("title", "")
    title_word = ""
    if title:
        words = re.findall(r"\w+", title.lower())
        # Skip common words
        skip = {"the", "a", "an", "on", "in", "of", "for", "to", "and", "with"}
        for w in words:
            if w not in skip and len(w) > 2:
                title_word = w
                break

    return f"{first_author}{year}{title_word}"


def main():
    api_key = os.getenv("ZOTERO_API_KEY")
    lib_id = os.getenv("ZOTERO_LIBRARY_ID")
    lib_type = os.getenv("ZOTERO_LIBRARY_TYPE")

    zot = zotero.Zotero(lib_id, lib_type, api_key)

    # Fetch recent items (limit to 100 for speed)
    items = zot.top(limit=100, sort="dateModified", direction="desc")

    for item in items:
        data = item.get("data", {})
        if data.get("itemType") in ("attachment", "note"):
            continue

        title = data.get("title", "Untitled")
        creators = data.get("creators", [])

        # Format authors
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

        key = generate_cite_key(data)

        # Format: Title | Author (Year) [key]
        print(f"{title[:70]} | {author} ({year}) [{key}]")


if __name__ == "__main__":
    main()
