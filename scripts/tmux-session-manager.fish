#!/usr/bin/env fish

# tmux session manager with fzf
# Keybinds: Enter=switch, Ctrl-E=create, Ctrl-X=kill, Ctrl-R=refresh

function _list_sessions
    echo "+ Create New Session..."
    tmux list-sessions -F "#{session_name}" 2>/dev/null
end

while true
    set -l raw_choice (_list_sessions | fzf \
        --prompt="sessions > " \
        --height=60% --border --exit-0 \
        --expect=enter,ctrl-x,ctrl-e,ctrl-r \
        --header="Enter:switch | Ctrl-E:new | Ctrl-X:kill | Ctrl-R:refresh" \
        --preview='test {} != "+ Create New Session..." && tmux list-windows -t {} 2>/dev/null || echo "Create a new tmux session"' \
        --preview-window=right:40%)

    test -z "$raw_choice" && exit 0

    set -l lines (string split -n '\n' -- $raw_choice)
    set -l key $lines[1]
    set -l sel $lines[2]

    switch $key
        case enter
            if test "$sel" = "+ Create New Session..."
                read -P "New session name: " newname
                test -n "$newname" && tmux new -d -s "$newname" -c (pwd)
            else if test -n "$sel"
                tmux switch-client -t $sel
                exit 0
            end
        case ctrl-e
            read -P "New session name: " newname
            test -n "$newname" && tmux new -d -s "$newname" -c (pwd)
        case ctrl-x
            if test -n "$sel" -a "$sel" != "+ Create New Session..."
                tmux kill-session -t $sel
            end
        case ctrl-r
            # Refresh: just loop
    end
end
