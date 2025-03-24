#!/usr/bin/env fish

# Parse arguments
test (count $argv) -lt 3 && echo "Usage: arxiv_readlist <N> <24h|1w> <fields>" && exit 1
set n $argv[1]
set time $argv[2]
set fields $argv[3]

# Source environment variables
test -f ~/.env_arxiv_zotero && source ~/.env_arxiv_zotero || { echo "Missing ~/.env_arxiv_zotero with ZOTERO_API_KEY, ZOTERO_LIBRARY_ID, etc."; exit 1 }

# Setup dirs
mkdir -p "$PAPERS_DIR/notes"

# Fetch papers
ZOTERO_API_KEY=$ZOTERO_API_KEY \
ZOTERO_LIBRARY_ID=$ZOTERO_LIBRARY_ID \
ZOTERO_LIBRARY_TYPE=$ZOTERO_LIBRARY_TYPE \
PAPERS_DIR=$PAPERS_DIR \
python3 ~/scripts/arxiv_fetch.py $n $time $fields

# Read papers from readlist.md, splitting into array
set papers (cat $PAPERS_DIR/readlist.md | grep "^- " | sed 's/^- //')
test (count $papers) -eq 0 && echo "No papers found for $fields in the last $time" && exit 1

# Select with fzf
set selected (printf "%s\n" $papers | fzf --prompt="Pick a paper: ")
test -z "$selected" && exit 0

# Extract arXiv ID
set arxiv_id (echo $selected | grep -o 'arXiv:[0-9.]*v[0-9]' | cut -d':' -f2)

# Process paper
ZOTERO_API_KEY=$ZOTERO_API_KEY \
ZOTERO_LIBRARY_ID=$ZOTERO_LIBRARY_ID \
ZOTERO_LIBRARY_TYPE=$ZOTERO_LIBRARY_TYPE \
PAPERS_DIR=$PAPERS_DIR \
python3 ~/scripts/arxiv_fetch.py $arxiv_id

# Notes
set notes "$PAPERS_DIR/notes/$arxiv_id.md"
test -f $notes || echo "# Notes for $selected\n" > $notes
tmux new-window -n "notes" "nvim $notes"
