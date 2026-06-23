#!/usr/bin/env fish
# Unified arXiv paper browser and downloader
# Keybind: prefix + a (in tmux)

set -l script_dir (dirname (status filename))

if test -f ~/.env_arxiv_zotero
    source ~/.env_arxiv_zotero
else
    echo "Missing ~/.env_arxiv_zotero"
    echo "Required: ZOTERO_API_KEY, ZOTERO_LIBRARY_ID, ZOTERO_LIBRARY_TYPE, PHD_RESEARCH_DIR"
    read -P "Press enter to exit..."
    exit 1
end

set -l missing_env
for var in ZOTERO_API_KEY ZOTERO_LIBRARY_ID ZOTERO_LIBRARY_TYPE PHD_RESEARCH_DIR
    if not set -q $var
        set -a missing_env $var
    end
end
if test (count $missing_env) -gt 0
    echo "Missing environment variables: "(string join ", " $missing_env)
    read -P "Press enter to exit..."
    exit 1
end

if not python3 -c "import arxiv, pyzotero" 2>/dev/null
    echo "Missing Python packages."
    echo "Run: python3 -m pip install --user 'arxiv<3' 'pyzotero<1.10' 'urllib3<2'"
    exit 1
end

function open_pdf --argument-names pdf_path
    set -l cleanup_dir (dirname "$pdf_path")

    if command -q sioyek
        nohup fish -c 'sioyek "$argv[1]" >/tmp/arxiv-sioyek.log 2>&1; rm -rf "$argv[2]"' -- "$pdf_path" "$cleanup_dir" >/dev/null 2>&1 &
        return 0
    end

    switch (uname -s)
        case Darwin
            if command -q open
                nohup fish -c 'open -W "$argv[1]" >/tmp/arxiv-open.log 2>&1; rm -rf "$argv[2]"' -- "$pdf_path" "$cleanup_dir" >/dev/null 2>&1 &
                return 0
            end
        case '*'
            if command -q xdg-open
                nohup fish -c 'xdg-open "$argv[1]" >/tmp/arxiv-xdg-open.log 2>&1; sleep 3600; rm -rf "$argv[2]"' -- "$pdf_path" "$cleanup_dir" >/dev/null 2>&1 &
                return 0
            end
    end

    echo "No PDF viewer found. Install sioyek or configure the OS default opener."
    return 1
end

function open_note --argument-names notes_path arxiv_id
    if set -q TMUX
        if not command -q tmux
            echo "Inside tmux, but tmux is not on PATH."
            return 1
        end

        set -l note_dir (dirname "$notes_path")
        set -l escaped_note (string escape -- "$notes_path")
        tmux new-window -c "$note_dir" -n "arxiv:$arxiv_id" "nvim $escaped_note"
        return $status
    end

    nvim "$notes_path"
end

# Predefined categories
set -l categories \
    "CS.MA   - Multiagent Systems" \
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
        or begin
            read -P "Press enter to exit..."
            exit 1
        end

    case "Search by Query"
        read -P "Search query: " query
        test -z "$query" && exit 0

        read -P "Number of results [25]: " count
        test -z "$count" && set count 25

        echo "Searching arXiv..."
        set papers_json (python3 $script_dir/arxiv_backend.py search "$query" $count)
        or begin
            read -P "Press enter to exit..."
            exit 1
        end
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
set -l keep_open 0
for paper in $selected
    # Extract arXiv ID from selection
    set -l arxiv_id (string replace -r '^\[([^\]]+)\].*$' '$1' -- $paper)

    echo ""
    echo "Processing: $paper"
    echo "Downloading and adding to Zotero..."

    # Download paper and get paths
    set -l result (python3 $script_dir/arxiv_backend.py download $arxiv_id $category)
    or begin
        echo "Could not process $arxiv_id"
        continue
    end
    set -l pdf_path (echo $result | python3 -c "import json,sys; print(json.load(sys.stdin)['pdf'])")
    set -l notes_path (echo $result | python3 -c "import json,sys; print(json.load(sys.stdin)['notes'])")
    set -l duplicate (echo $result | python3 -c "import json,sys; print(str(json.load(sys.stdin)['duplicate']).lower())")

    set downloaded_count (math $downloaded_count + 1)
    if test "$duplicate" = true
        echo "Already present in Zotero; reusing the existing item."
    end

    echo "Opening notes..."
    if not open_note "$notes_path" "$arxiv_id"
        echo "Could not open notes in a new tmux window: $notes_path"
        set keep_open 1
    end

    echo "Opening PDF..."
    open_pdf "$pdf_path"
end

if test $downloaded_count -gt 0
    echo ""
    echo "Processed $downloaded_count paper(s)."
    echo "Review and commit Markdown notes from $PHD_RESEARCH_DIR yourself."
end

if test $keep_open -eq 1
    read -P "Press enter to exit..."
end
