#!/usr/bin/env python3
"""Discover arXiv papers, attach PDFs to Zotero, and create Markdown notes."""

from __future__ import annotations

import json
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Any, Optional

import arxiv
from pyzotero import zotero


ARXIV_ID_RE = re.compile(r"(?<!\d)(\d{4}\.\d{4,5})(?:v\d+)?", re.IGNORECASE)


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


def all_results(client, first_page):
    return list(client.everything(first_page))


def research_dir() -> Path:
    configured = os.getenv("PHD_RESEARCH_DIR")
    if not configured:
        raise RuntimeError("Missing environment variable: PHD_RESEARCH_DIR")
    path = Path(os.path.expandvars(configured)).expanduser()
    if not path.is_dir():
        raise RuntimeError(f"PHD_RESEARCH_DIR is not a directory: {path}")
    return path


def sanitize_filename(title: str) -> str:
    clean = re.sub(r"[^\w\s-]", "", title.lower())
    clean = re.sub(r"[\s_]+", "_", clean)
    return clean[:80].strip("_") or "untitled"


def format_authors(authors: list[Any]) -> str:
    names = [str(author) for author in authors]
    if len(names) <= 3:
        return ", ".join(names)
    return f"{names[0]}, {names[1]}, ... ({len(names)} authors)"


def paper_record(result: Any) -> dict[str, str]:
    return {
        "id": result.get_short_id(),
        "title": result.title.replace("\n", " "),
        "authors": format_authors(result.authors),
        "date": result.published.strftime("%Y-%m-%d"),
    }


def list_papers(category: str, count: int) -> list[dict[str, str]]:
    search = arxiv.Search(
        query=f"cat:{category}",
        max_results=count,
        sort_by=arxiv.SortCriterion.SubmittedDate,
        sort_order=arxiv.SortOrder.Descending,
    )
    return [paper_record(result) for result in arxiv.Client().results(search)]


def search_papers(query: str, count: int) -> list[dict[str, str]]:
    search = arxiv.Search(
        query=query,
        max_results=count,
        sort_by=arxiv.SortCriterion.Relevance,
    )
    return [paper_record(result) for result in arxiv.Client().results(search)]


def get_inbox_key(client: Any) -> str:
    collections = all_results(client, client.collections(limit=100))
    for collection in collections:
        data = collection["data"]
        if data["name"] == "00 Inbox" and not data.get("parentCollection"):
            return collection["key"]
    raise RuntimeError("Zotero collection '00 Inbox' is missing")


def canonical_arxiv_id(arxiv_id: str) -> str:
    match = ARXIV_ID_RE.search(arxiv_id)
    if not match:
        return arxiv_id.split("v", 1)[0].lower()
    return match.group(1).lower()


def item_arxiv_id(item: dict[str, Any]) -> Optional[str]:
    data = item.get("data", {})
    haystack = "\n".join(
        str(data.get(field, "")) for field in ("extra", "url", "title")
    )
    match = ARXIV_ID_RE.search(haystack)
    return match.group(1).lower() if match else None


def find_arxiv_item(client: Any, arxiv_id: str) -> Optional[dict[str, Any]]:
    canonical_id = canonical_arxiv_id(arxiv_id)
    items = all_results(client, client.top(limit=100))
    matches = [
        item
        for item in items
        if item.get("data", {}).get("itemType")
        not in {"attachment", "note", "annotation"}
        and item_arxiv_id(item) == canonical_id
    ]
    if not matches:
        return None
    return min(matches, key=lambda item: item.get("data", {}).get("dateAdded", ""))


def has_pdf_attachment(client: Any, item_key: str) -> bool:
    children = all_results(client, client.children(item_key, limit=100))
    return any(
        child.get("data", {}).get("itemType") == "attachment"
        and child.get("data", {}).get("contentType") == "application/pdf"
        for child in children
    )


def create_zotero_item(client: Any, paper: Any, category: str, inbox_key: str) -> str:
    item = client.item_template("journalArticle")
    item["title"] = paper.title
    item["creators"] = [
        {"creatorType": "author", "name": str(author)} for author in paper.authors
    ]
    item["date"] = str(paper.published.date())
    item["abstractNote"] = paper.summary
    item["url"] = paper.entry_id
    item["extra"] = f"arXiv:{paper.get_short_id().split('v', 1)[0]}"
    item["collections"] = [inbox_key]
    item["tags"] = [
        {"tag": "source/arxiv"},
        {"tag": "status/to-read"},
        {"tag": f"arxiv/{category.lower()}"},
    ]

    response = client.create_items([item])
    successful = response.get("successful", {})
    if "0" not in successful:
        raise RuntimeError(f"Zotero rejected the new item: {response}")
    return successful["0"]["key"]


def write_note(paper: Any) -> Path:
    year = str(paper.published.year)
    notes_dir = research_dir() / "papers" / year
    notes_dir.mkdir(parents=True, exist_ok=True)
    base_name = f"{paper.get_short_id()}_{sanitize_filename(paper.title)}"
    notes_path = notes_dir / f"{base_name}.md"
    if notes_path.exists():
        return notes_path

    authors = ", ".join(str(author) for author in paper.authors)
    notes_path.write_text(
        f"""# {paper.title}

- **arXiv:** {paper.get_short_id()}
- **Authors:** {authors}
- **Published:** {paper.published:%Y-%m-%d}
- **URL:** {paper.entry_id}
- **Status:** to-read

## Abstract

{paper.summary}

## Notes

""",
        encoding="utf-8",
    )
    return notes_path


def download_paper(arxiv_id: str, category: str) -> dict[str, Any]:
    search = arxiv.Search(id_list=[arxiv_id])
    paper = next(arxiv.Client().results(search), None)
    if paper is None:
        raise RuntimeError(f"arXiv paper not found: {arxiv_id}")

    client = get_zotero()
    inbox_key = get_inbox_key(client)
    existing = find_arxiv_item(client, paper.get_short_id())

    temp_dir = Path(tempfile.mkdtemp(prefix="arxiv-"))
    pdf_name = f"{paper.get_short_id()}_{sanitize_filename(paper.title)}.pdf"
    pdf_path = Path(paper.download_pdf(dirpath=temp_dir, filename=pdf_name))

    duplicate = existing is not None
    item_key = (
        existing["key"]
        if existing
        else create_zotero_item(client, paper, category, inbox_key)
    )
    if not duplicate or not has_pdf_attachment(client, item_key):
        client.attachment_simple([str(pdf_path)], item_key)

    notes_path = write_note(paper)
    return {
        "pdf": str(pdf_path),
        "notes": str(notes_path),
        "zotero_key": item_key,
        "duplicate": duplicate,
    }


def parse_count(value: str) -> int:
    count = int(value)
    if not 1 <= count <= 100:
        raise ValueError("result count must be between 1 and 100")
    return count


def main() -> int:
    try:
        if len(sys.argv) == 4 and sys.argv[1] == "list":
            print(json.dumps(list_papers(sys.argv[2], parse_count(sys.argv[3]))))
        elif len(sys.argv) == 4 and sys.argv[1] == "search":
            print(json.dumps(search_papers(sys.argv[2], parse_count(sys.argv[3]))))
        elif len(sys.argv) == 4 and sys.argv[1] == "download":
            print(json.dumps(download_paper(sys.argv[2], sys.argv[3])))
        else:
            print(
                "Usage: arxiv_backend.py {list <category> <count>|"
                "search <query> <count>|download <arxiv-id> <category>}",
                file=sys.stderr,
            )
            return 2
    except Exception as exc:
        print(f"arXiv workflow failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
