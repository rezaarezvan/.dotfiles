#!/usr/bin/env fish

# Quick citation lookup from Zotero library
# Returns citation key

set -l script_dir (dirname (status filename))

# Source environment
if test -f ~/.env_arxiv_zotero
    source ~/.env_arxiv_zotero
else
    echo "Missing ~/.env_arxiv_zotero"
    exit 1
end

# Fetch and select citation
set -l result (python3 $script_dir/cite_backend.py | \
    fzf --prompt="Cite > " --height=80% --border \
        --preview='echo {}' --preview-window=down:3:wrap)

test -z "$result" && exit 0

# Extract citation key and output
set -l key (echo $result | sed 's/.*\[\([^]]*\)\].*/\1/')
echo -n $key
