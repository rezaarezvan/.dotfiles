# Biscuit Mar Dark. Most Biscuit colors already clear 4.5:1 on #1a1515, so these
# are the stock values; only red/purple/cyan are lifted, using Biscuit's own
# bright variants rather than invented ones.
set -l foreground ffe9c7
set -l selection 453636
set -l comment 967a7a
set -l red e3556f
set -l orange e39c45
set -l yellow f07942
set -l green 949f6b
set -l purple 9894b3
set -l cyan ca6bac
set -l pink ae3f8a

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment
set -g fish_color_cancel $red --reverse
set -g fish_color_option $orange

# Default Prompt Colors
set -g fish_color_cwd $green
set -g fish_color_host $purple
set -g fish_color_host_remote $purple
set -g fish_color_user $cyan

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_background
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection
set -g fish_pager_color_selected_prefix $cyan
set -g fish_pager_color_selected_completion $foreground
set -g fish_pager_color_selected_description $comment
set -g fish_pager_color_secondary_background
set -g fish_pager_color_secondary_prefix $cyan
set -g fish_pager_color_secondary_completion $foreground
set -g fish_pager_color_secondary_description $comment
