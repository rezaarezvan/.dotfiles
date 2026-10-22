function fish_prompt --description 'Write out the prompt'
    set -l last_ret $status

    # Biscuit Mar Dark
    set -l base01 ffe9c7
    set -l base02 9c8181
    set -l base03 967a7a
    set -l c_error e3556f
    set -l c_success 949f6b
    set -l c_orange e39c45
    set -l c_magenta ca6bac

    set -l ret_color $c_success
    test $last_ret -gt 0; and set ret_color $c_error

    set -l venv
    set -q VIRTUAL_ENV; and set venv ' '(set_color $c_magenta)'('(path basename $VIRTUAL_ENV)')'

    printf %s \
        (set_color $base03) '[' (set_color $ret_color) $last_ret (set_color $base03) '] ' \
        (set_color $base01) $USER (set_color $base02) @ (set_color $base01) (prompt_hostname) ' ' \
        (set_color $fish_color_cwd) (prompt_pwd) $venv (set_color -o $c_orange) (fish_git_prompt) ' ' \
        (set_color $c_error) 'ζ' (set_color normal) (set_color $base01) '➞' (set_color normal) ' '
end
