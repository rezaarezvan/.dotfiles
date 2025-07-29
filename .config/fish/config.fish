set -x CUDA_HOME /usr/local/cuda-12.2
set -x PATH $CUDA_HOME/bin $PATH
set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
set -x PATH $PATH ~/bin

# Only for interactive sessions
if status is-interactive
    alias vim='nvim'
    set -x FZF_DEFAULT_COMMAND "fdfind --type d --hidden --exclude .git"
end

# Start tmux only if not already in a tmux session and in an interactive shell
if status is-interactive && not set -q TMUX
    tmux
    cd ~
end
