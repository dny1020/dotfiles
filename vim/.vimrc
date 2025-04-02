" =============================
"      AWESOME VIM CONFIG
" =============================

" Ensure Vim-Plug is installed (for plugins)
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" =========== BASIC SETTINGS ===========
set number                " Enable line numbers
set tabstop=4             " Tab width
set shiftwidth=4          " Indentation width
set expandtab             " Convert tabs to spaces
set autoindent            " Maintain previous indentation
set smartindent           " Smarter indentation

" =========== SEARCH ===========
set ignorecase            " Ignore case in searches
set smartcase             " Case-sensitive if uppercase is used
set hlsearch              " Highlight search results
set incsearch             " Search as you type
set wrapscan              " Wrap search around file

" =========== UI IMPROVEMENTS ===========
set cursorline            " Highlight current line
set showcmd               " Show last command in status line
set wildmenu              " Enhanced command-line completion
set wildmode=longest,list " Better tab completion
set lazyredraw            " Faster scrolling
set scrolloff=5           " Keep 5 lines visible when scrolling
set sidescrolloff=8       " Keep 8 columns visible when scrolling horizontally

" =========== SPLITS & WINDOW MANAGEMENT ===========
set splitbelow            " Horizontal splits open below
set splitright            " Vertical splits open to the right
nnoremap <C-h> <C-w>h     " Move left in split
nnoremap <C-l> <C-w>l     " Move right in split
nnoremap <C-j> <C-w>j     " Move down in split
nnoremap <C-k> <C-w>k     " Move up in split

" =========== SYSTEM CLIPBOARD ===========
set clipboard=unnamedplus " Use system clipboard
nnoremap <leader>y "+y    " Copy to clipboard
nnoremap <leader>p "+p    " Paste from clipboard

" =========== PLUGINS ===========
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'                   " Colorscheme
Plug 'vim-airline/vim-airline'           " Status bar
Plug 'vim-airline/vim-airline-themes'    " Themes for status bar
Plug 'preservim/nerdtree'                " File explorer
Plug 'jiangmiao/auto-pairs'              " Auto-closing brackets
Plug 'tpope/vim-surround'                " Surrounding text with brackets/quotes
Plug 'tpope/vim-commentary'              " Easy commenting
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy finder
Plug 'junegunn/fzf.vim'                  " FZF for searching
Plug 'tpope/vim-fugitive'                " Git integration

call plug#end()

" =========== COLORSCHEME ===========
set termguicolors
colorscheme gruvbox
let g:airline_theme='gruvbox'
set background=dark
" =========== NERDTREE (File Explorer) ===========
nnoremap <leader>n :NERDTreeToggle<CR>

" =========== MISC IMPROVEMENTS ===========
set history=1000          " Long command history
set noerrorbells          " No error sounds
set noswapfile            " Disable swap files
set nobackup              " No backup files
set nowritebackup         " Prevent unnecessary writes

" =========== FZF (Fuzzy Finder) ===========
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<CR>

" =========== KEYBINDINGS ===========
nnoremap <leader>w :w<CR>    " Save file
nnoremap <leader>q :q<CR>    " Quit
nnoremap <leader>Q :q!<CR>   " Force quit

" =========== STATUS BAR ===========
let g:airline_powerline_fonts = 1

