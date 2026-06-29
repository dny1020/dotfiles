# ~/.config/shell/tools.zsh
# Herramientas modernas expuestas como ALIAS sobre el comando de siempre:
# no hay nada nuevo que aprender, y si el binario no está, el alias no se crea.
# (Versionado en el repo dotfiles; sourceado desde ~/.zshrc.)

# --- bat reemplaza a cat / fd reemplaza a find -------------------------------
# En Debian los binarios son batcat / fdfind; en macOS son bat / fd.
# cat → bat con syntax highlight + nº de línea, SIN pager (se comporta como cat).
if command -v batcat >/dev/null; then
  alias bat='batcat'
  alias cat='batcat --style=numbers --paging=never'
elif command -v bat >/dev/null; then
  alias cat='bat --style=numbers --paging=never'
fi
command -v fdfind >/dev/null && alias fd='fdfind'
# Tema Dracula para bat/cat (consistente con nvim; colores suaves)
export BAT_THEME="Dracula"

# --- eza: reemplaza a ls (mismos ls/ll/la), con iconos Nerd Font y git --------
# ¿Demasiados iconos/color? quita --icons o añade --color=never a los alias.
if command -v eza >/dev/null; then
  # Permisos (rwx) en monocromático; el resto de colores (nombres, git, fecha) intactos.
  export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0:xx=0"
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l  --icons=auto --git --group-directories-first --time-style=long-iso'
  alias la='eza -la --icons=auto --git --group-directories-first --time-style=long-iso'
fi

# --- zoxide: tu `cd` de siempre, pero recuerda a dónde sueles ir -------------
# Sigues escribiendo `cd`; tras visitar dirs, `cd nombre-parcial` salta directo.
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# --- tldr (tealdeer): ejemplos prácticos en vez de man ----------------------
# No es alias de nada (no hay equivalente), pero solo corre cuando lo llamas.
# uso: tldr tar
