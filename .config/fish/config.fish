if status is-interactive
    # Commands to run in interactive sessions can go here
end

tmux
cd ~

alias vim='nvim'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/reza/miniconda3/bin/conda
    eval /home/reza/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

set -x LD_LIBRARY_PATH /usr/lib/cuda/lib64 $LD_LIBRARY_PATH
set PATH $PATH ~/bin
