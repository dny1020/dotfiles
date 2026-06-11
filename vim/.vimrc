" ~/.vimrc - vim clasico, sin plugins

set nocompatible
filetype plugin indent on
syntax on

" -- Interfaz ------------------------------------------------------------
set number
set ruler
set laststatus=2
set statusline=%f\ %m%r%=%y\ %l:%c\ %p%%
set wildmenu
set wildmode=longest:full,full
set showcmd
set showmatch
set scrolloff=5
set noerrorbells visualbell t_vb=

" -- Edicion -------------------------------------------------------------
set encoding=utf-8
set backspace=indent,eol,start
set hidden
set autoread
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set autoindent
set splitbelow splitright

" -- Busqueda ------------------------------------------------------------
set ignorecase smartcase
set incsearch hlsearch

" :grep usa ripgrep si esta disponible
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

" -- Archivos ------------------------------------------------------------
set noswapfile nobackup
set undofile undodir=~/.vim/undo
if !isdirectory($HOME . '/.vim/undo')
  call mkdir($HOME . '/.vim/undo', 'p', 0700)
endif

" :find busca recursivo desde el directorio actual
set path+=**

" -- Completado nativo ---------------------------------------------------
" <C-n>/<C-p> palabras, <C-x><C-o> omni, <C-x><C-f> rutas
set omnifunc=syntaxcomplete#Complete
set completeopt=menuone,longest

" -- netrw como explorador -----------------------------------------------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25

" -- Mapeos --------------------------------------------------------------
let mapleader = ' '

nnoremap <leader>e :Explore<CR>
nnoremap <leader>f :find<Space>
nnoremap <leader>b :buffer<Space>
nnoremap <leader>g :grep<Space>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>w :w<CR>

" Moverse entre ventanas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Mantener seleccion al indentar
vnoremap < <gv
vnoremap > >gv

" -- Autocomandos --------------------------------------------------------
augroup vimrc
  autocmd!
  " Volver a la ultima posicion al abrir un archivo
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  " Quitar espacios al final de linea al guardar
  autocmd BufWritePre * %s/\s\+$//e
augroup END
