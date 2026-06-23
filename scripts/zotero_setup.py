#!/usr/bin/env python3
"""Create the PhD Zotero hierarchy and file unorganized items."""

import os
import sys

from pyzotero import zotero


TREE = {
    "00 Inbox": (),
    "10 Reading": ("Queue", "In Progress", "Read"),
    "20 Projects": ("Entropic Risk", "Puffer Planning", "Future Projects"),
    "30 Topics": (
        "Reinforcement Learning & Planning",
        "Risk-Sensitive Decision Making",
        "Multi-Agent Systems",
        "Machine Learning & Optimization",
    ),
    "40 Outputs": ("Papers", "Thesis", "Talks & Presentations"),
    "90 Archive": (),
}


def client():
    required = ("ZOTERO_API_KEY", "ZOTERO_LIBRARY_ID", "ZOTERO_LIBRARY_TYPE")
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError("Missing environment variables: " + ", ".join(missing))
    return zotero.Zotero(
        os.environ["ZOTERO_LIBRARY_ID"],
        os.environ["ZOTERO_LIBRARY_TYPE"],
        os.environ["ZOTERO_API_KEY"],
    )


def wanted_paths():
    for root, children in TREE.items():
        yield (root,)
        for child in children:
            yield (root, child)


def collection_paths(collections):
    by_key = {entry["key"]: entry for entry in collections}
    paths = {}
    for entry in collections:
        names = [entry["data"]["name"]]
        parent = entry["data"].get("parentCollection")
        while parent:
            parent_entry = by_key[parent]
            names.append(parent_entry["data"]["name"])
            parent = parent_entry["data"].get("parentCollection")
        paths[tuple(reversed(names))] = entry
    return paths


def state(zot):
    collections = list(zot.everything(zot.collections(limit=100)))
    items = list(zot.everything(zot.top(limit=100)))
    items = [
        item
        for item in items
        if item["data"].get("itemType") not in {"attachment", "note", "annotation"}
    ]
    return collections, items


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in {"plan", "apply"}:
        print("Usage: zotero_setup.py {plan|apply}", file=sys.stderr)
        return 2

    try:
        zot = client()
        collections, items = state(zot)
        paths = collection_paths(collections)
        missing = [path for path in wanted_paths() if path not in paths]
        unfiled = [item for item in items if not item["data"].get("collections")]

        print(f"Collections to create: {len(missing)}")
        print(f"Unfiled items to move to 00 Inbox: {len(unfiled)}")
        for path in missing:
            print("  " + " / ".join(path))

        if sys.argv[1] == "plan":
            return 0

        for path in missing:
            parent = paths[path[:-1]]["key"] if len(path) > 1 else False
            response = zot.create_collections(
                [{"name": path[-1], "parentCollection": parent}]
            )
            paths[path] = response["successful"]["0"]

        inbox = paths[("00 Inbox",)]["key"]
        for item in unfiled:
            item["data"]["collections"] = [inbox]
            zot.update_item(item)

        print(f"Created {len(missing)} collections; filed {len(unfiled)} items.")
        return 0
    except Exception as exc:
        print(f"Zotero setup failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
