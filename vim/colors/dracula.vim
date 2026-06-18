" dracula.vim - colorscheme Dracula hecho a mano (sin plugin)
" Paleta oficial: https://draculatheme.com
" Define gui (hex real) y cterm (aprox. 256 colores) para que se vea bien
" tanto en gvim/truecolor como en xterm de 256 colores.

hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'dracula'
set background=dark

" Truecolor solo si la terminal lo declara (xterm usa 256, ruta segura)
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  set termguicolors
endif

" Paleta        gui        cterm
"   bg          #282a36    236
"   bg+         #44475a    239
"   fg          #f8f8f2    253
"   comment     #6272a4    61
"   cyan        #8be9fd    117
"   green       #50fa7b    84
"   orange      #ffb86c    215
"   pink        #ff79c6    212
"   purple      #bd93f9    141
"   red         #ff5555    203
"   yellow      #f1fa8c    228

" --- UI ---
hi Normal         guifg=#f8f8f2 guibg=#282a36 ctermfg=253 ctermbg=236
hi NonText        guifg=#6272a4 ctermfg=61
hi SpecialKey     guifg=#6272a4 ctermfg=61
hi Cursor         guifg=#282a36 guibg=#f8f8f2 ctermfg=236 ctermbg=253
hi CursorLine     guibg=#2c2e3e ctermbg=237 cterm=NONE
hi CursorColumn   guibg=#2c2e3e ctermbg=237
hi CursorLineNr   guifg=#f1fa8c guibg=#2c2e3e ctermfg=228 ctermbg=237 cterm=NONE
hi LineNr         guifg=#6272a4 ctermfg=61
hi SignColumn     guibg=#282a36 ctermbg=236
hi ColorColumn    guibg=#2c2e3e ctermbg=237
hi VertSplit      guifg=#44475a guibg=#282a36 ctermfg=239 ctermbg=236 cterm=NONE
hi Folded         guifg=#6272a4 guibg=#21222c ctermfg=61 ctermbg=235
hi FoldColumn     guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=236
hi MatchParen     guifg=#50fa7b ctermfg=84 cterm=bold gui=bold
hi Visual         guibg=#44475a ctermbg=239
hi Search         guifg=#282a36 guibg=#f1fa8c ctermfg=236 ctermbg=228
hi IncSearch      guifg=#282a36 guibg=#ffb86c ctermfg=236 ctermbg=215
hi StatusLine     guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=239 cterm=NONE gui=NONE
hi StatusLineNC   guifg=#6272a4 guibg=#21222c ctermfg=61 ctermbg=235 cterm=NONE gui=NONE
hi WildMenu       guifg=#282a36 guibg=#bd93f9 ctermfg=236 ctermbg=141
hi Pmenu          guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=239
hi PmenuSel       guifg=#282a36 guibg=#bd93f9 ctermfg=236 ctermbg=141
hi PmenuSbar      guibg=#21222c ctermbg=235
hi PmenuThumb     guibg=#bd93f9 ctermbg=141
hi TabLine        guifg=#6272a4 guibg=#21222c ctermfg=61 ctermbg=235 cterm=NONE
hi TabLineSel     guifg=#f8f8f2 guibg=#282a36 ctermfg=253 ctermbg=236
hi TabLineFill    guibg=#21222c ctermbg=235
hi Title          guifg=#bd93f9 ctermfg=141 gui=bold cterm=bold
hi Directory      guifg=#8be9fd ctermfg=117
hi ErrorMsg       guifg=#ff5555 ctermfg=203 gui=bold cterm=bold
hi WarningMsg     guifg=#ffb86c ctermfg=215
hi Question       guifg=#50fa7b ctermfg=84
hi ModeMsg        guifg=#f1fa8c ctermfg=228
hi MoreMsg        guifg=#8be9fd ctermfg=117

" --- Sintaxis ---
hi Comment        guifg=#6272a4 ctermfg=61 gui=italic cterm=NONE
hi Constant       guifg=#bd93f9 ctermfg=141
hi String         guifg=#f1fa8c ctermfg=228
hi Character      guifg=#f1fa8c ctermfg=228
hi Number         guifg=#bd93f9 ctermfg=141
hi Boolean        guifg=#bd93f9 ctermfg=141
hi Float          guifg=#bd93f9 ctermfg=141
hi Identifier     guifg=#8be9fd ctermfg=117 cterm=NONE
hi Function       guifg=#50fa7b ctermfg=84
hi Statement      guifg=#ff79c6 ctermfg=212 gui=NONE cterm=NONE
hi Conditional    guifg=#ff79c6 ctermfg=212
hi Repeat         guifg=#ff79c6 ctermfg=212
hi Label          guifg=#ff79c6 ctermfg=212
hi Operator       guifg=#ff79c6 ctermfg=212
hi Keyword        guifg=#ff79c6 ctermfg=212
hi Exception      guifg=#ff79c6 ctermfg=212
hi PreProc        guifg=#ff79c6 ctermfg=212
hi Include        guifg=#ff79c6 ctermfg=212
hi Define         guifg=#ff79c6 ctermfg=212
hi Macro          guifg=#ff79c6 ctermfg=212
hi PreCondit      guifg=#ff79c6 ctermfg=212
hi Type           guifg=#8be9fd ctermfg=117 gui=NONE cterm=NONE
hi StorageClass   guifg=#8be9fd ctermfg=117
hi Structure      guifg=#8be9fd ctermfg=117
hi Typedef        guifg=#8be9fd ctermfg=117
hi Special        guifg=#ffb86c ctermfg=215
hi SpecialChar    guifg=#ffb86c ctermfg=215
hi Tag            guifg=#ff79c6 ctermfg=212
hi Delimiter      guifg=#f8f8f2 ctermfg=253
hi SpecialComment guifg=#6272a4 ctermfg=61
hi Debug          guifg=#ff5555 ctermfg=203
hi Underlined     guifg=#8be9fd ctermfg=117 gui=underline cterm=underline
hi Ignore         guifg=#6272a4 ctermfg=61
hi Error          guifg=#f8f8f2 guibg=#ff5555 ctermfg=253 ctermbg=203
hi Todo           guifg=#282a36 guibg=#f1fa8c ctermfg=236 ctermbg=228 gui=bold cterm=bold

" --- Diffs ---
hi DiffAdd        guifg=#50fa7b guibg=#283a2e ctermfg=84 ctermbg=22
hi DiffChange     guifg=#ffb86c guibg=#3a3326 ctermfg=215 ctermbg=58
hi DiffDelete     guifg=#ff5555 guibg=#3a2630 ctermfg=203 ctermbg=52
hi DiffText       guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=239 gui=bold cterm=bold

" --- Spell ---
hi SpellBad       guisp=#ff5555 gui=undercurl ctermfg=203 cterm=underline
hi SpellCap       guisp=#bd93f9 gui=undercurl ctermfg=141 cterm=underline
hi SpellRare      guisp=#ffb86c gui=undercurl ctermfg=215 cterm=underline
hi SpellLocal     guisp=#8be9fd gui=undercurl ctermfg=117 cterm=underline
