# ~/.config/shell/zsh-enhance.zsh
# Autosuggestions + syntax highlighting + fzf + historial.
# Sourceado AL FINAL de .zshrc (syntax-highlighting debe ir el último).
# Cada bloque va con guardia: si el paquete no está, no falla.

# --- Historial (mejoras sobre lo que ya tienes en .zshrc) -------------------
setopt HIST_FIND_NO_DUPS      # al buscar, no repite entradas iguales
setopt HIST_REDUCE_BLANKS     # normaliza espacios al guardar
setopt HIST_VERIFY            # al expandir !! deja editar antes de ejecutar
setopt EXTENDED_HISTORY       # guarda timestamp por comando
# Si quieres más memoria de comandos, sube esto (están en 5000 en tu .zshrc):
# HISTSIZE=50000; SAVEHIST=50000

# --- ↑/↓ buscan por prefijo --------------------------------------------------
# Escribe "curl" y pulsa ↑ -> recorre SOLO comandos que empiezan por "curl".
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # flecha arriba
bindkey '^[[B' down-line-or-beginning-search  # flecha abajo
bindkey '^[OA' up-line-or-beginning-search    # variante (terminal en modo app)
bindkey '^[OB' down-line-or-beginning-search

# --- zsh-autosuggestions (la sugerencia gris desde historial) ---------------
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # historial y, si no, completado
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'         # gris tenue
  bindkey '^ '  autosuggest-accept               # Ctrl+Espacio acepta entero
  bindkey '^[[C' forward-char                    # -> avanza/acepta letra a letra
fi

# --- fzf: Ctrl-R historial fuzzy, Ctrl-T archivos, Alt-C cd ------------------
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

# --- zsh-syntax-highlighting (SIEMPRE el último que se sourcea) -------------
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# --- (OPCIONAL) Prompt con iconos Nerd Font ---------------------------------
# Descomenta para sustituir tu prompt actual por uno con iconos.
# Requiere que Alacritty use "JetBrainsMono Nerd Font" (ya la tienes instalada).
# zstyle ':vcs_info:git:*' formats ' %F{176} %b%f'
# PROMPT='%F{114} %n%f %F{222} %1~%f${vcs_info_msg_0_} %(?.%F{114}.%F{203})❯%f '
# RPROMPT='%(?..%F{203}[%?]%f)'
