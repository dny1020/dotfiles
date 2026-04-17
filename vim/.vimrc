" ========================
"   Professional Vim Configuration
"   VSCode-inspired setup
" ========================

" Compatibility
set nocompatible
filetype plugin indent on
syntax enable

" ========================
" GENERAL SETTINGS
" ========================

" Line numbers
set number
set relativenumber              " Relative line numbers like VSCode
set numberwidth=4

" Tabs and Indentation
set tabstop=2 shiftwidth=2 softtabstop=2
set expandtab smartindent

" Search
set ignorecase smartcase hlsearch incsearch

" Visual
set cursorline showmatch matchtime=2 laststatus=2
set showcmd wildmenu wildmode=longest:full,full ruler

" Behavior
set mouse=a                     " Enable mouse support like VSCode
set clipboard=unnamed           " Use system clipboard
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif
set backspace=indent,eol,start  " Make backspace work as expected
set hidden                      " Allow hidden buffers
set encoding=utf-8
set fileencoding=utf-8

" Splits
set splitbelow                  " Horizontal splits below
set splitright                  " Vertical splits to right

" Scrolling
set scrolloff=8                 " Keep 8 lines visible above/below cursor
set sidescrolloff=8

" Performance
set lazyredraw updatetime=300 timeoutlen=500 ttimeoutlen=10

" Files
set noswapfile nobackup nowritebackup
set undofile undodir=~/.vim/undodir
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p", 0700)
endif

" Misc
set noerrorbells novisualbell history=1000 autoread confirm

" Folding
set foldmethod=indent foldlevel=99 nofoldenable

" ========================
" PLUGIN MANAGER (vim-plug)
" ========================

" Auto-install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ========================
" PLUGINS
" ========================

call plug#begin('~/.vim/plugged')

" Appearance & Navigation
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

" Code Intelligence
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'

call plug#end()

" ========================
" THEME & COLORS
" ========================

" Enable 256 colors (works on macOS Terminal.app)
set t_Co=256
set background=dark

" Only enable true colors if terminal supports it (iTerm, modern terminals)
" macOS Terminal.app doesn't support this well, so we detect it
if exists('+termguicolors')
  " Check if we're in iTerm or another terminal with true color support
  if $TERM_PROGRAM == "iTerm.app" || $COLORTERM == "truecolor" || $COLORTERM == "24bit"
    set termguicolors
  endif
endif

" Gruvbox theme
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_termcolors = 256
silent! colorscheme gruvbox

if !exists('g:colors_name')
  colorscheme desert
endif

" ========================
" PLUGIN CONFIGURATION
" ========================

" --- Lightline ---
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

" --- NERDTree ---
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
let NERDTreeIgnore=['\.git$', '\.DS_Store$', 'node_modules', '__pycache__']
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" --- GitGutter ---
set signcolumn=yes

" --- FZF ---
let g:fzf_layout = { 'down': '40%' }

" --- CoC (Autocomplete & LSP) ---
" Use tab for trigger completion
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" GoTo code navigation
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

" Rename and format
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>fm <Plug>(coc-format)

" ========================
" KEY MAPPINGS
" ========================

" Leader key
let mapleader = " "
let maplocalleader = " "

" Save
nnoremap <leader>w :w<CR>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Quit
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :q!<CR>

" Clear search highlight
nnoremap <silent> <leader>h :nohlsearch<CR>

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" --- Plugin Shortcuts ---
" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" FZF
nnoremap <C-p> :Files<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :Rg<CR>

" Git
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

" ========================
" AUTO COMMANDS
" ========================

augroup general_config
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd BufWritePre * %s/\s\+$//e
augroup END

augroup filetype_config
  autocmd!
  autocmd FileType python setlocal colorcolumn=88
augroup END

" ========================
" CUSTOM FUNCTIONS
" ========================

" Toggle relative line numbers
nnoremap <leader>tn :set relativenumber!<CR>

" ========================
" POST-PLUGIN SETTINGS
" ========================

autocmd VimEnter * ++nested colorscheme gruvbox

" ========================
"   End of Configuration
" ========================
