#!/usr/bin/env fish
set dir (fdfind --type d --hidden --exclude .git . ~ | fzf --prompt="Cd to: " --height 40% --border)
if test -n "$dir"
    cd $dir
end
