#!/usr/bin/env fish
# Browse arXiv and save picks into the Zotero collection currently selected (tmux prefix+a)

set -l backend (dirname (status filename))/arxiv_backend.py

function fail
    echo $argv
    read -P "Press enter to exit..."
    exit 1
end

set -l categories \
    "cs.LG   Machine Learning" \
    "cs.AI   Artificial Intelligence" \
    "cs.MA   Multiagent Systems" \
    "cs.CL   Computation and Language" \
    "cs.CV   Computer Vision" \
    "cs.RO   Robotics" \
    "cs.NE   Neural and Evolutionary Computing" \
    "stat.ML Statistics: Machine Learning" \
    "math.OC Optimization and Control"

set -l papers
set -l mode (printf '%s\n' "Browse category" "Search" | fzf --prompt="arXiv > " --height=40% --border --no-info)
switch "$mode"
    case "Browse category"
        set -l cat (printf '%s\n' $categories | fzf --prompt="Category > " --height=50% --border --no-info --print-query | tail -1)
        test -z "$cat"; and exit 0
        set papers (python3 $backend list (string split -f1 ' ' -- $cat) 50); or fail "arXiv request failed"
    case Search
        read -P "Search: " query
        test -z "$query"; and exit 0
        set papers (python3 $backend search "$query" 50); or fail "arXiv request failed"
    case '*'
        exit 0
end

test (count $papers) -eq 0; and fail "No papers found."

set -l picks (printf '%s\n' $papers | fzf --multi --delimiter \t --with-nth 2.. --height=80% --border \
    --prompt="Papers > " --header="Tab: select | Enter: save to Zotero and open")
test -z "$picks"; and exit 0

for pick in $picks
    set -l id (string split -f1 \t -- $pick)
    echo "Saving $id..."
    set -l pdf (python3 $backend add $id); or fail "Could not fetch $id"
    if command -q sioyek
        sioyek "$pdf" >/dev/null 2>&1 &
    else if command -q open
        open "$pdf"
    else
        xdg-open "$pdf" >/dev/null 2>&1 &
    end
    disown 2>/dev/null
end
