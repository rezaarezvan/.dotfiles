filetype plugin indent on
syntax on

set encoding=utf-8
set path+=**
set hidden
set backspace=indent,eol,start
set autoindent smartindent
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set number relativenumber
set splitbelow splitright
set incsearch hlsearch ignorecase smartcase showmatch
set wildmenu wildmode=longest:full,full
set wildignore+=*.pyc,**/.git/*,**/node_modules/*,**/__pycache__/*
set foldmethod=syntax foldlevel=99
set clipboard=unnamed
set noswapfile nobackup noundofile
set ruler showcmd laststatus=0 shortmess+=I
set belloff=all
set lazyredraw
set background=dark
if has('termguicolors') | set termguicolors | endif
highlight Comment cterm=italic gui=italic

nnoremap <space> za
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap <C-s> :w<CR>
vnoremap <tab> >gv
vnoremap <S-tab> <gv
command! W w
command! Q q
