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
#
set -x CUDA_HOME /usr/local/cuda-12.2
set -x PATH $CUDA_HOME/bin $PATH
set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
set PATH $PATH ~/bin

# Zig
set -x PATH /usr/local/zig-0.14.0 $PATH
