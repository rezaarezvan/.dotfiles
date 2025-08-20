#!/usr/bin/env fish
set dir (fdfind --type d --exclude .git . $HOME | fzf --prompt="Cd to: " --height 41% --border)
if test -n "$dir"
    cd $dir
end
