#!/usr/bin/env fish

# Parse arguments
test (count $argv) -lt 1; and echo "Usage: arxiv_zotero <query>" && exit 1

# Source environment variables
test -f ~/.env_arxiv_zotero && source ~/.env_arxiv_zotero || { echo "Missing ~/.env_arxiv_zotero with ZOTERO_API_KEY, ZOTERO_LIBRARY_ID, etc."; exit 1 }

# Setup directories
mkdir -p $PAPERS_DIR
cd $PAPERS_DIR

# Fetch papers
ZOTERO_API_KEY=$ZOTERO_API_KEY \
ZOTERO_LIBRARY_ID=$ZOTERO_LIBRARY_ID \
ZOTERO_LIBRARY_TYPE=$ZOTERO_LIBRARY_TYPE \
PAPERS_DIR=$PAPERS_DIR \
python3 ~/scripts/arxiv_zotero.py "$argv[1]"

# Add papers to git
git add .
git commit -m "Papers for: $argv[1]" 2>/dev/null; or true
