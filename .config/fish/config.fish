# nvim nightly from bob (`bob update nightly`)
fish_add_path -gPm ~/.local/share/bob/nvim-bin ~/.local/bin /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path -gPa ~/bin

if test -d ~/.nvm/versions/node
    fish_add_path -gP (command ls -d ~/.nvm/versions/node/*/bin | sort -V | tail -1)
end

if test -d /usr/local/cuda
    set -gx CUDA_HOME /usr/local/cuda
    fish_add_path -gP $CUDA_HOME/bin
    contains -- $CUDA_HOME/lib64 $LD_LIBRARY_PATH
    or set -gx LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
end

if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings
    alias vim='nvim'
    command -q fd; and set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"

    if not set -q TMUX; and command -q tmux
        exec tmux new -A -s main
    end
end
