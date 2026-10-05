# ~/.config/shell/zsh-enhance.zsh
# Autosuggestions + syntax highlighting + fzf + historial.
# Sourceado AL FINAL de .zshrc (syntax-highlighting debe ir el último).
# Cada bloque va con guardia: si el paquete no está, no falla.

# --- Historial (mejoras sobre lo que ya tienes en .zshrc) -------------------
setopt HIST_FIND_NO_DUPS      # al buscar, no repite entradas iguales
setopt HIST_REDUCE_BLANKS     # normaliza espacios al guardar
setopt HIST_VERIFY            # al expandir !! deja editar antes de ejecutar
setopt EXTENDED_HISTORY       # guarda timestamp por comando

# --- ↑/↓ buscan por prefijo --------------------------------------------------
# Escribe "curl" y pulsa ↑ -> recorre SOLO comandos que empiezan por "curl".
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # flecha arriba
bindkey '^[[B' down-line-or-beginning-search  # flecha abajo
bindkey '^[OA' up-line-or-beginning-search    # variante (terminal en modo app)
bindkey '^[OB' down-line-or-beginning-search

# Los plugins viven en rutas distintas según el SO:
#   Debian/WSL: /usr/share/<plugin>/         (apt)
#   macOS:      $(brew --prefix)/share/<plugin>/  (brew; /opt/homebrew o /usr/local)
_plugin_source() {  # busca y sourcea la primera ruta que exista
  local f
  for f in "/usr/share/$1/$1.zsh" \
           "/opt/homebrew/share/$1/$1.zsh" \
           "/usr/local/share/$1/$1.zsh"; do
    [[ -f "$f" ]] && { source "$f"; return 0; }
  done
  return 1
}

# --- zsh-autosuggestions (la sugerencia gris desde historial) ---------------
if _plugin_source zsh-autosuggestions; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # historial y, si no, completado
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'         # gris tenue
  bindkey '^ '  autosuggest-accept               # Ctrl+Espacio acepta entero
  bindkey '^[[C' forward-char                    # -> avanza/acepta letra a letra
fi

# --- fzf: Ctrl-R historial fuzzy, Ctrl-T archivos, Alt-C cd ------------------
if command -v fzf >/dev/null; then
  # Ctrl-T over ripgrep: respects .gitignore, skips .git/node_modules on big repos
  if command -v rg >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  source <(fzf --zsh)
fi

# --- zsh-syntax-highlighting (SIEMPRE el último que se sourcea) -------------
_plugin_source zsh-syntax-highlighting

unfunction _plugin_source
