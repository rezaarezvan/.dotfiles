#!/usr/bin/env python3

import re
import sys
import json
import secrets
import tempfile
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

API = "https://export.arxiv.org/api/query"
ZOTERO = "http://127.0.0.1:23119/connector"
LOCAL_API = "http://127.0.0.1:23119/api/users/0"
NS = {"a": "http://www.w3.org/2005/Atom", "arxiv": "http://arxiv.org/schemas/atom"}


def fetch(url, data=None, headers={}):
    with urllib.request.urlopen(
        urllib.request.Request(url, data=data, headers=headers), timeout=60
    ) as r:
        return r.read()


def query(**params):
    root = ET.fromstring(fetch(f"{API}?{urllib.parse.urlencode(params)}"))
    return [paper(e) for e in root.findall("a:entry", NS)]


def paper(e):
    text = lambda tag: " ".join((e.findtext(tag, "", NS) or "").split())
    return {
        "id": re.sub(r"v\d+$", "", text("a:id").rsplit("/abs/", 1)[-1]),
        "title": text("a:title"),
        "authors": [
            " ".join(a.findtext("a:name", "", NS).split())
            for a in e.findall("a:author", NS)
        ],
        "date": text("a:published")[:10],
        "abstract": text("a:summary"),
    }


def show(papers):
    for p in papers:
        authors = ", ".join(p["authors"][:2]) + (
            " et al." if len(p["authors"]) > 2 else ""
        )
        print(f"{p['id']}\t{p['title']}\t{authors}\t{p['date']}")


def creator(name):
    first, _, last = name.rpartition(" ")
    return {"firstName": first, "lastName": last, "creatorType": "author"}


def save_to_zotero(p, pdf):
    session, url = secrets.token_hex(8), f"https://arxiv.org/abs/{p['id']}"
    item = {
        "id": "1",
        "itemType": "preprint",
        "title": p["title"],
        "creators": [creator(a) for a in p["authors"]],
        "date": p["date"],
        "abstractNote": p["abstract"],
        "url": url,
        "repository": "arXiv",
        "archiveID": f"arXiv:{p['id']}",
        "DOI": f"10.48550/arXiv.{p['id']}",
    }
    body = {"sessionID": session, "uri": url, "items": [item]}
    fetch(
        f"{ZOTERO}/saveItems",
        json.dumps(body).encode(),
        {"Content-Type": "application/json"},
    )
    meta = {
        "sessionID": session,
        "parentItemID": "1",
        "title": "Full Text PDF",
        "url": f"https://arxiv.org/pdf/{p['id']}",
    }
    fetch(
        f"{ZOTERO}/saveAttachment",
        pdf.read_bytes(),
        {"Content-Type": "application/pdf", "X-Metadata": json.dumps(meta)},
    )


def zotero_pdf(arxiv_id):
    # Local path of the paper's PDF in Zotero, via the local API (Settings > Advanced)
    url = f"https://arxiv.org/abs/{arxiv_id}"
    params = urllib.parse.urlencode({"q": arxiv_id, "qmode": "everything"})
    for item in json.loads(fetch(f"{LOCAL_API}/items/top?{params}")):
        if item["data"].get("url") != url:
            continue
        for child in json.loads(fetch(f"{LOCAL_API}/items/{item['key']}/children")):
            href = child["links"].get("enclosure", {}).get("href", "")
            if href.startswith("file://") and href.endswith(".pdf"):
                return Path(urllib.request.url2pathname(urllib.parse.urlparse(href).path))


def target():
    # Where saveItems will put new items: the row selected in Zotero's left pane
    try:
        sel = json.loads(fetch(f"{ZOTERO}/getSelectedCollection", b"{}", {"Content-Type": "application/json"}))
    except OSError:
        return "Zotero is not running"
    return sel["name"] if sel.get("id") else f"{sel['name']} (no collection selected)"


def add(arxiv_id):
    if not (papers := query(id_list=arxiv_id, max_results=1)):
        sys.exit(f"arXiv paper not found: {arxiv_id}")
    p = papers[0]
    try:
        if stored := zotero_pdf(p["id"]):
            print(stored)
            return
        with tempfile.TemporaryDirectory() as tmp:
            pdf = Path(tmp) / f"{p['id'].replace('/', '_')}.pdf"
            pdf.write_bytes(fetch(f"https://arxiv.org/pdf/{p['id']}"))
            save_to_zotero(p, pdf)
        print(zotero_pdf(p["id"]) or sys.exit(f"saved {p['id']} but Zotero has no PDF for it"))
    except OSError as e:
        sys.exit(f"{e} (is Zotero running?)")


def main():
    cmd, args = (sys.argv[1], sys.argv[2:]) if len(sys.argv) > 1 else ("", [])
    if cmd == "list" and len(args) == 2:
        show(
            query(
                search_query=f"cat:{args[0]}",
                sortBy="submittedDate",
                sortOrder="descending",
                max_results=args[1],
            )
        )
    elif cmd == "search" and len(args) == 2:
        show(
            query(
                search_query=" AND ".join(f"all:{w}" for w in args[0].split()),
                sortBy="relevance",
                max_results=args[1],
            )
        )
    elif cmd == "target" and not args:
        print(target())
    elif cmd == "add" and len(args) == 1:
        add(args[0])
    else:
        sys.exit(
            "usage: arxiv_backend.py {list <category> <count> | search <query> <count> | target | add <id>}"
        )


if __name__ == "__main__":
    main()
