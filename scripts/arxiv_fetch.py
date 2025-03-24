import os
import sys
import arxiv

from pyzotero import zotero
from datetime import datetime, timedelta, timezone

papers_dir = os.getenv("PAPERS_DIR", os.path.expanduser("~/papers"))
os.makedirs(papers_dir, exist_ok=True)

if len(sys.argv) == 4:
    n, time, fields = int(sys.argv[1]), sys.argv[2], sys.argv[3]
    since = datetime.now(timezone.utc) - (
        timedelta(hours=24) if time == "24h" else timedelta(weeks=1)
    )
    client = arxiv.Client()
    search = arxiv.Search(
        query=f"cat:{fields}",
        max_results=n,
        sort_by=arxiv.SortCriterion.SubmittedDate,
        sort_order=arxiv.SortOrder.Descending,
    )

    with open(os.path.join(papers_dir, "readlist.md"), "w") as f:
        f.write("# Latest Papers\n\n")
        for r in client.results(search):
            if r.published > since:
                entry = f"- {r.title} (arXiv:{r.get_short_id()})\n"
                f.write(entry)
                print(entry, end="")

elif len(sys.argv) == 2:
    arxiv_id = sys.argv[1]
    client = arxiv.Client()
    search = arxiv.Search(id_list=[arxiv_id])
    r = next(client.results(search))
    pdf = r.download_pdf(dirpath=papers_dir)
    os.system(f"sioyek {pdf} &")
    zot = zotero.Zotero(
        os.getenv("ZOTERO_LIBRARY_ID"),
        os.getenv("ZOTERO_LIBRARY_TYPE"),
        os.getenv("ZOTERO_API_KEY"),
    )
    item = zot.item_template("journalArticle")
    item["title"] = r.title
    item["creators"] = [{"creatorType": "author", "name": str(a)} for a in r.authors]
    item["date"] = str(r.published)
    item["abstractNote"] = r.summary
    item["url"] = r.entry_id
    item["extra"] = f"arXiv:{arxiv_id}"
    resp = zot.create_items([item])

    if resp["successful"]:
        zot.attachment_simple([pdf], resp["successful"]["0"]["key"])
else:
    print("Usage: arxiv_fetch <N> <24h|1w> <fields> OR arxiv_fetch <arxiv_id>")
    sys.exit(1)
