set nocompatible
filetype plugin indent on
syntax enable

set number relativenumber numberwidth=4
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab smartindent
set ignorecase smartcase hlsearch incsearch
set cursorline showmatch matchtime=2 laststatus=2
set showcmd wildmenu wildmode=longest:full,full ruler
set mouse=a
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
else
  set clipboard=unnamed
endif
set backspace=indent,eol,start hidden encoding=utf-8 fileencoding=utf-8
set splitbelow splitright
set scrolloff=8 sidescrolloff=8
set lazyredraw updatetime=300 timeoutlen=500 ttimeoutlen=10
set noswapfile nobackup nowritebackup
set undofile undodir=~/.vim/undodir
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p", 0700)
endif
set noerrorbells novisualbell history=1000 autoread confirm
set foldmethod=indent foldlevel=99 nofoldenable
set signcolumn=yes

" Auto-install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
call plug#end()

set t_Co=256
set background=dark
if exists('+termguicolors')
  if $TERM_PROGRAM == "iTerm.app" || $COLORTERM == "truecolor" || $COLORTERM == "24bit"
    set termguicolors
  endif
endif
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_termcolors = 256
silent! colorscheme gruvbox
if !exists('g:colors_name')
  colorscheme desert
endif

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
      \   'filename': 'LightlineFilename'
      \ },
      \ }

function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
let NERDTreeIgnore=['\.git$', '\.DS_Store$', 'node_modules', '__pycache__']
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:fzf_layout = { 'down': '40%' }

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)
nmap <leader>fm <Plug>(coc-format)

let mapleader = " "
let maplocalleader = " "

nnoremap <leader>w :w<CR>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :q!<CR>
nnoremap <silent> <leader>h :nohlsearch<CR>
vnoremap < <gv
vnoremap > >gv
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <C-p> :Files<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :Rg<CR>
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>tn :set relativenumber!<CR>

augroup general_config
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd BufWritePre * %s/\s\+$//e
augroup END

augroup filetype_config
  autocmd!
  autocmd FileType python setlocal colorcolumn=88
augroup END

autocmd VimEnter * ++nested colorscheme gruvbox
