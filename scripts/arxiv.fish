#!/usr/bin/env fish

# Unified arXiv paper browser and downloader
# Keybind: prefix + a (in tmux)

set -l script_dir (dirname (status filename))

# Source environment
if test -f ~/.env_arxiv_zotero
    source ~/.env_arxiv_zotero
else
    echo "Missing ~/.env_arxiv_zotero"
    echo "Required: ZOTERO_API_KEY, ZOTERO_LIBRARY_ID, ZOTERO_LIBRARY_TYPE, PAPERS_DIR"
    read -P "Press enter to exit..."
    exit 1
end

# Predefined categories
set -l categories \
    "cs.LG   - Machine Learning" \
    "cs.AI   - Artificial Intelligence" \
    "cs.CL   - Computation and Language" \
    "cs.CV   - Computer Vision" \
    "cs.RO   - Robotics" \
    "cs.NE   - Neural and Evolutionary Computing" \
    "stat.ML - Statistics: Machine Learning" \
    "math.OC - Optimization and Control" \
    "Custom..."

# Count options
set -l count_options \
    "10  - Quick browse" \
    "25  - Standard" \
    "50  - Deep dive"

# Mode selection
set -l mode (printf "%s\n" "Browse by Category" "Search by Query" | \
    fzf --prompt="arXiv > " --height=40% --border --no-info)

test -z "$mode" && exit 0

set -l papers_json ""
set -l category "query"

switch $mode
    case "Browse by Category"
        # Category selection
        set -l cat_choice (printf "%s\n" $categories | \
            fzf --prompt="Category > " --height=50% --border --no-info)
        test -z "$cat_choice" && exit 0

        if test "$cat_choice" = "Custom..."
            read -P "Enter category (e.g., cs.LG): " category
            test -z "$category" && exit 0
        else
            set category (echo $cat_choice | awk '{print $1}')
        end

        # Count selection
        set -l count_choice (printf "%s\n" $count_options | \
            fzf --prompt="How many? > " --height=40% --border --no-info)
        test -z "$count_choice" && exit 0

        set -l count_val (echo $count_choice | awk '{print $1}')

        echo "Fetching $count_val papers from $category..."
        set papers_json (python3 $script_dir/arxiv_backend.py list $category $count_val)

    case "Search by Query"
        read -P "Search query: " query
        test -z "$query" && exit 0

        read -P "Number of results [25]: " count
        test -z "$count" && set count 25

        echo "Searching arXiv..."
        set papers_json (python3 $script_dir/arxiv_backend.py search "$query" $count)
end

# Parse JSON and format for fzf
set -l papers (echo $papers_json | python3 -c "
import json, sys
papers = json.load(sys.stdin)
for p in papers:
    print(f\"[{p['id']}] {p['title'][:80]} | {p['authors']} | {p['date']}\")
")

if test (count $papers) -eq 0
    echo "No papers found."
    read -P "Press enter to exit..."
    exit 0
end

# Multi-select papers with fzf
set -l selected (printf "%s\n" $papers | \
    fzf --prompt="Select papers (Tab to multi-select) > " \
        --height=80% --border \
        --multi \
        --bind="tab:toggle+down" \
        --header="Tab: select | Enter: confirm | Esc: cancel")

test -z "$selected" && exit 0

# Process each selected paper
set -l downloaded_count 0
for paper in $selected
    # Extract arXiv ID from selection
    set -l arxiv_id (echo $paper | grep -oP '^\[\K[^\]]+')

    echo ""
    echo "Processing: $paper"
    echo "Downloading and adding to Zotero..."

    # Download paper and get paths
    set -l result (python3 $script_dir/arxiv_backend.py download $arxiv_id $category)
    set -l pdf_path (echo $result | python3 -c "import json,sys; print(json.load(sys.stdin)['pdf'])")
    set -l notes_path (echo $result | python3 -c "import json,sys; print(json.load(sys.stdin)['notes'])")

    set downloaded_count (math $downloaded_count + 1)

    # Open PDF (blocking)
    echo "Opening PDF... (close to continue)"
    sioyek "$pdf_path"

    # Open notes (blocking)
    echo "Opening notes..."
    nvim "$notes_path"
end

# Git commit if papers were downloaded
if test $downloaded_count -gt 0
    echo ""
    echo "Committing $downloaded_count paper(s) to git..."
    cd $PAPERS_DIR
    git add -A
    git commit -m "Added $downloaded_count paper(s) from $category" 2>/dev/null
    echo "Done!"
end

read -P "Press enter to exit..."
