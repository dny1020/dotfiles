" ~/.vimrc

set nocompatible
filetype plugin indent on
syntax on

" Tema Dracula (colorscheme propio en ~/dotfiles/vim/colors, sin plugins)
set runtimepath+=$HOME/dotfiles/vim
silent! colorscheme dracula

set cursorline
" Apariencia
set number
set ruler

" Edicion
set encoding=utf-8
set backspace=indent,eol,start
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent

" Busqueda
set ignorecase
set smartcase
set incsearch
set hlsearch

" Archivos
set hidden
set autoread
set undofile

" Ripgrep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
endif

" Completado nativo
set omnifunc=syntaxcomplete#Complete
set complete=.,w,b,u,t
set completeopt=menuone,noinsert,noselect

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3

" Leader
let mapleader = ' '

nnoremap <leader>e :Explore<CR>
nnoremap <leader>g :grep<Space>
nnoremap <leader>w :w<CR>
nnoremap <leader>h :nohlsearch<CR>

" Volver al ultimo cursor
augroup vimrc
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END
