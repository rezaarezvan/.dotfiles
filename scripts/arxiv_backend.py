#!/usr/bin/env python3
"""
Unified arXiv backend for paper discovery, download, and Zotero integration.

Usage:
    arxiv_backend.py list <category> <count>          - List recent papers
    arxiv_backend.py search <query> <count>           - Search papers by query
    arxiv_backend.py download <arxiv_id> <category>   - Download and add to Zotero
"""

import json
import os
import re
import sys

import arxiv
from pyzotero import zotero


def get_env():
    """Load environment variables."""
    return {
        "api_key": os.getenv("ZOTERO_API_KEY"),
        "lib_id": os.getenv("ZOTERO_LIBRARY_ID"),
        "lib_type": os.getenv("ZOTERO_LIBRARY_TYPE"),
        "papers_dir": os.getenv("PAPERS_DIR", os.path.expanduser("~/papers")),
    }


def sanitize_filename(title: str) -> str:
    """Convert title to filesystem-safe name."""
    clean = re.sub(r"[^\w\s-]", "", title.lower())
    clean = re.sub(r"[\s_]+", "_", clean)
    return clean[:80]


def format_authors(authors: list) -> str:
    """Format author list for display."""
    names = [str(a) for a in authors]
    if len(names) <= 3:
        return ", ".join(names)
    return f"{names[0]}, {names[1]}, ... ({len(names)} authors)"


def list_papers(category: str, count: int):
    """Fetch recent papers by category."""
    client = arxiv.Client()
    search = arxiv.Search(
        query=f"cat:{category}",
        max_results=count,
        sort_by=arxiv.SortCriterion.SubmittedDate,
        sort_order=arxiv.SortOrder.Descending,
    )

    papers = []
    for r in client.results(search):
        papers.append(
            {
                "id": r.get_short_id(),
                "title": r.title.replace("\n", " "),
                "authors": format_authors(r.authors),
                "date": r.published.strftime("%Y-%m-%d"),
            }
        )

    print(json.dumps(papers))


def search_papers(query: str, count: int):
    """Search papers by query string."""
    client = arxiv.Client()
    search = arxiv.Search(
        query=query,
        max_results=count,
        sort_by=arxiv.SortCriterion.Relevance,
    )

    papers = []
    for r in client.results(search):
        papers.append(
            {
                "id": r.get_short_id(),
                "title": r.title.replace("\n", " "),
                "authors": format_authors(r.authors),
                "date": r.published.strftime("%Y-%m-%d"),
            }
        )

    print(json.dumps(papers))


def download_paper(arxiv_id: str, category: str):
    """Download paper, add to Zotero, create notes template."""
    env = get_env()
    papers_dir = env["papers_dir"]

    # Create category directory
    cat_dir = os.path.join(papers_dir, category)
    os.makedirs(cat_dir, exist_ok=True)

    # Fetch paper metadata
    client = arxiv.Client()
    search = arxiv.Search(id_list=[arxiv_id])
    paper = next(client.results(search))

    # Generate filenames
    safe_title = sanitize_filename(paper.title)
    base_name = f"{arxiv_id}_{safe_title}"
    pdf_path = os.path.join(cat_dir, f"{base_name}.pdf")
    notes_path = os.path.join(cat_dir, f"{base_name}.md")

    # Download PDF
    paper.download_pdf(dirpath=cat_dir, filename=f"{base_name}.pdf")

    # Add to Zotero
    zot = zotero.Zotero(env["lib_id"], env["lib_type"], env["api_key"])
    item = zot.item_template("journalArticle")
    item["title"] = paper.title
    item["creators"] = [
        {"creatorType": "author", "name": str(a)} for a in paper.authors
    ]
    item["date"] = str(paper.published.date())
    item["abstractNote"] = paper.summary
    item["url"] = paper.entry_id
    item["extra"] = f"arXiv:{arxiv_id}"

    resp = zot.create_items([item])
    if resp["successful"]:
        zot.attachment_simple([pdf_path], resp["successful"]["0"]["key"])

    # Create notes template
    authors_full = ", ".join(str(a) for a in paper.authors)
    notes_content = f"""# {paper.title}

- **arXiv:** {arxiv_id}
- **Authors:** {authors_full}
- **Date:** {paper.published.strftime("%Y-%m-%d")}
- **URL:** {paper.entry_id}

## Abstract

{paper.summary}

## Notes

"""

    with open(notes_path, "w") as f:
        f.write(notes_content)

    # Output paths for fish script
    print(json.dumps({"pdf": pdf_path, "notes": notes_path}))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "list" and len(sys.argv) == 4:
        list_papers(sys.argv[2], int(sys.argv[3]))
    elif cmd == "search" and len(sys.argv) == 4:
        search_papers(sys.argv[2], int(sys.argv[3]))
    elif cmd == "download" and len(sys.argv) == 4:
        download_paper(sys.argv[2], sys.argv[3])
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
