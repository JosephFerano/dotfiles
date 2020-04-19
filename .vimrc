set nocompatible
syntax on
set number
set relativenumber
set splitbelow
set splitright
set tabstop=4
set shiftwidth=4
set expandtab
set nowrap
set hlsearch
set ignorecase
set smartcase
nohlsearch
set timeoutlen=1000 
set ttimeoutlen=0
set noswapfile
set nobackup
set hidden
color peachpuff
let mapleader = "\<Space>"

noremap <Space> <nop>
noremap <Leader>/ :nohlsearch<CR>
nnoremap D d$
nnoremap Y y$
nnoremap vv ^v$h
noremap \ q
noremap $ g_
nnoremap ' `
nnoremap ` '

nnoremap <Leader>w :w<CR>
nnoremap <Leader>rl :so $MYVIMRC<CR>
nnoremap <Leader>q :q<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

if system('uname -r') =~ "Microsoft"
  augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('clip.exe ',@")
  augroup END
endif
