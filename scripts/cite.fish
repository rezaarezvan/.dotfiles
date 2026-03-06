#!/usr/bin/env fish

# Quick citation lookup from Zotero library
# Copies BibTeX entry to clipboard

set -l script_dir (dirname (status filename))

if test -f ~/.env_arxiv_zotero
    source ~/.env_arxiv_zotero
else
    echo "Missing ~/.env_arxiv_zotero"
    exit 1
end

set -l result (python3 $script_dir/cite_backend.py | \
    fzf --prompt="Cite > " --height=80% --border \
        --preview='echo {}' --preview-window=down:3:wrap)

test -z "$result" && exit 0

set -l zotero_key (echo $result | sed 's/.*\[\([^]]*\)\]$/\1/')

set -l bibtex (python3 $script_dir/cite_backend.py --bibtex $zotero_key)
string join \n $bibtex | fish_clipboard_copy
string join \n $bibtex
