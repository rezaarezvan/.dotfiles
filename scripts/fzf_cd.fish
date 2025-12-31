#!/usr/bin/env fish

# Platform-agnostic fd detection (fd on macOS, fdfind on Ubuntu/Debian)
if command -q fd
    set finder fd
else if command -q fdfind
    set finder fdfind
else
    echo "Error: fd/fdfind not installed"
    echo "Install: brew install fd (macOS) or apt install fd-find (Ubuntu)"
    return 1
end

set dir ($finder --type d --hidden --exclude .git . $HOME | \
    fzf --prompt="cd: " --height=41% --border)

test -n "$dir" && cd "$dir"
