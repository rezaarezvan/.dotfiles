set -x CUDA_HOME /usr/local/cuda-12.2
set -x PATH $CUDA_HOME/bin $PATH
set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
set -x PATH $PATH ~/bin

# Zig
set -x PATH /usr/local/zig-0.14.0 $PATH

# Only for interactive sessions
if status is-interactive
    alias vim='nvim'
    # fzf: Use fdfind for dirs to match your script
    set -x FZF_DEFAULT_COMMAND "fdfind --type d --hidden --exclude .git"
end

# Start tmux only if not already in a tmux session and in an interactive shell
if status is-interactive && not set -q TMUX
    tmux
    cd ~
end
