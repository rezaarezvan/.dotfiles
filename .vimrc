call plug#begin('~/.vim/plugged')
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'
	Plug 'sheerun/vim-polyglot'
	Plug 'Raimondi/delimitMate'
	Plug 'vim-syntastic/syntastic'
	Plug 'ryanoasis/vim-devicons'
	Plug 'ervandew/supertab'
	Plug 'tek256/simple-dark'
call plug#end()

set path+=**

" For fzf
nnoremap <C-p> :Files<cr>
nnoremap <C-b> :Buffers<cr>
nnoremap <C-g> :Rg<cr>

" Movement
noremap <C-h> b
noremap <C-l> w
noremap <C-k> 5k
noremap <C-j> 5j

" QoLs
noremap <C-BS> <C-w>
noremap <C-f> /
noremap <C-r> :%s/
noremap <C-s> :w<cr>
noremap <S-a> :tabp<cr>
noremap <S-d> :tabn<cr>
command W w
command Q q

" Select All, Copy, cut, paste for normal people
noremap <C-a> ggVG
noremap <C-c> yy
noremap <C-x> d
noremap <C-v> p

" Indents
nnoremap <tab> >>
noremap <S-tab> <<
vmap <tab> >gv
vmap <S-tab> <gv

" Undo and redo
noremap <C-z> u

filetype plugin on
set hlsearch
set splitbelow
set splitright

" Enable folding
set foldmethod=syntax
set foldlevel=99

"Enable folding with the spacebar
nnoremap <space> za

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
highlight Comment cterm=italic gui=italic
set showtabline=2

" true colours
set background=dark
set t_Co=256

if (has("termguicolors"))
  set termguicolors
endif

colorscheme simple-dark
hi NonText guifg=bg

set nu rnu " relative line numbering
set clipboard=unnamed " public copy/paste register
set ruler
set showcmd

set noundofile
set noswapfile " doesn't create swap files
set nobackup

set omnifunc=syntaxcomplete#Complete

" no annoying windows bell sound...
set visualbell
set t_vb=

set shortmess+=I
set nonumber
set laststatus=0

set backspace=indent,eol,start " let backspace delete over lines
set autoindent " enable auto indentation of lines
set smartindent " allow vim to best-effort guess the indentation
set pastetoggle=<F2> " enable paste mode

" Graphical auto complete menu
set wildmode=longest,list,full
set wildmenu

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
