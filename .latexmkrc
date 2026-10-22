$pdf_mode = 1;                 # pdflatex
set_tex_cmds('-interaction=nonstopmode -file-line-error %O %S');
use Cwd;
($aux_dir = getcwd()) =~ s{/}{%}g;
$aux_dir = "$ENV{HOME}/.cache/latexmk/$aux_dir";  # pdf stays next to .tex
$bibtex_use = 2;
$pdf_previewer = 'true';       # sioyek lives in its own pane
$sleep_time = 0.25;             # poll for changes every 250ms (default 2s)
