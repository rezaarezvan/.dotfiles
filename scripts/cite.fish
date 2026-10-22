#!/usr/bin/env fish
# Fuzzy-search the Zotero library and copy the BibTeX entry (tmux prefix+z)

set -l api http://127.0.0.1:23119/api/users/0

set -l items (curl -sf "$api/items/top?format=json&sort=dateModified&direction=desc" | jq -r '
    .[] | .data | select(.itemType != "note" and .itemType != "attachment")
    | [.key, (.citationKey // ""), ((.creators[0].lastName // .creators[0].name // "?") + ((.date // "") | (" " + capture("(?<y>[0-9]{4})").y)? // "")), .title]
    | @tsv')
if test $status -ne 0 -o (count $items) -eq 0
    echo "No answer from Zotero. Is it running with Settings > Advanced > \"Allow other applications\" on?"
    read -P "Press enter to exit..."
    exit 1
end

set -l pick (printf '%s\n' $items | fzf --delimiter \t --with-nth 2.. --prompt="Cite > " --height=80% --border)
test -z "$pick"; and exit 0

set -l bib (curl -sf "$api/items/"(string split -f1 \t -- $pick)"?format=bibtex")
string join \n -- $bib | fish_clipboard_copy
string join \n -- $bib
