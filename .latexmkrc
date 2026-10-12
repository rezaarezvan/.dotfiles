$pdf_mode = 1;                 # pdflatex
set_tex_cmds('-interaction=nonstopmode -file-line-error %O %S');
$aux_dir = 'build';            # aux clutter hidden, pdf next to .tex (like typst)
$bibtex_use = 2;
$pdf_previewer = 'true';       # sioyek lives in its own pane
$sleep_time = 0.25;             # poll for changes every 250ms (default 2s)
