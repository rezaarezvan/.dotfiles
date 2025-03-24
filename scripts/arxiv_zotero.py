import os
import sys
import arxiv

from pyzotero import zotero

key = os.getenv("ZOTERO_API_KEY")
lib_id = os.getenv("ZOTERO_LIBRARY_ID")
lib_type = os.getenv("ZOTERO_LIBRARY_TYPE")
papers_dir = os.getenv("PAPERS_DIR")

if len(sys.argv) < 2:
    print("Usage: arxiv_zotero.py <query>")
    sys.exit(1)
query = sys.argv[1]

search = arxiv.Search(query=query, max_results=1)

for r in search.results():
    pdf = r.download_pdf(dirpath=papers_dir)
    print(f"Got: {r.title} -> {pdf}")

    zot = zotero.Zotero(lib_id, lib_type, key)
    item = zot.item_template("journalArticle")

    item["title"] = r.title
    item["creators"] = [{"creatorType": "author", "name": str(a)} for a in r.authors]
    item["date"] = str(r.published)
    item["abstractNote"] = r.summary
    item["url"] = r.entry_id
    item["extra"] = f"arXiv:{r.get_short_id()}"

    resp = zot.create_items([item])
    if resp["successful"]:
        item_id = resp["successful"]["0"]["key"]
        zot.attachment_simple([pdf], item_id)
        print(f"Zotero: {r.title}")

    os.system(f"sioyek {pdf}")
