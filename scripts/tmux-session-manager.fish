#!/usr/bin/env fish

function _list_sessions
    echo "+ Create New Session..."
    tmux list-sessions -F "#{session_name}" 2>/dev/null
end

while true
    set -l raw_choice (_list_sessions | fzf \
        --prompt="tmux sessions > " \
        --height=60% --border --exit-0 \
        --expect=enter,ctrl-x,ctrl-e,ctrl-r)

    if test -z "$raw_choice"
        exit 0
    end

    set -l lines (string split -n '\n' -- $raw_choice)
    set -l key $lines[1]
    set -l sel $lines[2]

    switch $key
        case enter
            if test "$sel" = "+ Create New Session..."
                set -l newname
                read --prompt-str "New session name: " newname
                if test -n "$newname"
                    tmux new -d -s "$newname" -c (pwd)
                end
            else if test -n "$sel"
                tmux switch-client -t $sel
                exit 0
            end
        case ctrl-e
            set -l newname
            read --prompt-str "New session name: " newname
            if test -n "$newname"
                tmux new -d -s "$newname" -c (pwd)
            end
        case ctrl-x
            if test -n "$sel" -a "$sel" != "+ Create New Session..."
                tmux kill-session -t $sel
            end
        case ctrl-r
            # just loop; will refresh
    end
end
