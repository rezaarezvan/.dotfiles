#!/usr/bin/env fish

# Quick citation lookup from Zotero library
# Copies BibTeX entry to clipboard

set -l script_dir (dirname (status filename))

if test -f ~/.env_arxiv_zotero
    source ~/.env_arxiv_zotero
else
    echo "Missing ~/.env_arxiv_zotero"
    echo "Required: ZOTERO_API_KEY, ZOTERO_LIBRARY_ID, ZOTERO_LIBRARY_TYPE"
    exit 1
end

if not python3 -c "import pyzotero" 2>/dev/null
    echo "Missing pyzotero. Run: python3 -m pip install --user 'pyzotero<1.10'"
    exit 1
end

set -l result (python3 $script_dir/cite_backend.py | \
    fzf --prompt="Cite > " --height=80% --border \
        --preview='echo {}' --preview-window=down:3:wrap)

test -z "$result" && exit 0

set -l zotero_key (echo $result | sed 's/.*\[\([^]]*\)\]$/\1/')

set -l bibtex (python3 $script_dir/cite_backend.py --bibtex $zotero_key)
or exit 1
string join \n $bibtex | fish_clipboard_copy
string join \n $bibtex
