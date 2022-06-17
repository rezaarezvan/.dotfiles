call plug#begin('~/.vim/plugged')
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'
	Plug 'sheerun/vim-polyglot'
	Plug 'Raimondi/delimitMate'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-syntastic/syntastic'
	Plug 'ryanoasis/vim-devicons'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'ervandew/supertab'
	Plug 'axvr/photon.vim'
	Plug 'cocopon/iceberg.vim'
call plug#end()

set path+=**

" Larger movements
noremap <C-r> b
noremap <C-l> w
noremap <C-k> 5k
noremap <C-j> 5j
noremap <C-s> :%s/
noremap <C-a> ggVG


" Copy, cut, paste for normal people
noremap <C-c> yy
noremap <C-x> d
noremap <C-v> p

" Indents
nnoremap <tab> >>
noremap <S-tab> <<
vmap <tab> >gv
vmap <S-tab> <gv

" Find
noremap <C-f> /

" Undo and redo
noremap <C-z> u

" Open file
noremap <C-o> :e 

filetype plugin on

set hlsearch
set splitbelow
set splitright

" Enable folding
set foldmethod=syntax
set foldlevel=99
"Enable folding with the spacebar
nnoremap <space> za

" open files with ctrl-p
nnoremap <c-p> :Files<cr>

au BufNewFile,BufRead *.py,*.java,*.cpp,*.c,*.cs,*.rkt,*.h,*.html
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=120 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |

set encoding=utf-8

syntax on

" air-line
let g:airline_powerline_fonts = 1
let g:airline_theme = 'iceberg'
let g:airline#extensions#tabline#enabled = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

highlight Comment cterm=italic gui=italic

set laststatus=2
" set showtabline=2

" true colours
set background=dark
set t_Co=256

if (has("termguicolors"))
  set termguicolors
endif

colorscheme iceberg
hi NonText guifg=bg

set nu rnu " relative line numbering
set clipboard=unnamed " public copy/paste register
set ruler
set showcmd
set noswapfile " doesn't create swap files
set noshowmode
set shortmess+=c
set omnifunc=syntaxcomplete#Complete
set visualbell 
set t_vb=

set backspace=indent,eol,start " let backspace delete over lines
set autoindent " enable auto indentation of lines
set smartindent " allow vim to best-effort guess the indentation
set pastetoggle=<F2> " enable paste mode

" Menu
set wildmode=longest,list,full
set wildmenu "graphical auto complete menu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*


set lazyredraw "redraws the screne when it needs to
set showmatch "highlights matching brackets
set incsearch "search as characters are entered
set hlsearch "highlights matching searches

" c++11 support in syntastic
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11'


" run code
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

augroup compileandrun
    autocmd!
    autocmd filetype python nnoremap <f5> :w <bar> :!python3 % <cr>
    autocmd filetype cpp nnoremap <f5> :w <bar> !g++ -std=c++11 % <cr> :vnew <bar> :te "a.exe" <cr><cr>
    autocmd filetype cpp nnoremap <f6> :vnew <bar> :te "a.exe" <cr>
    autocmd filetype c nnoremap <f5> :w <bar> !gcc % && a.exe <cr>
    autocmd filetype java nnoremap <f5> :w <bar> !javac % && java %:r <cr>
augroup END