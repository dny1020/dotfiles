# ~/.zshrc - configuracion minima, sin frameworks

# -- Prompt (rama git via vcs_info, nativo de zsh) -------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats ' %F{176}(%b%u%c)%f'
setopt PROMPT_SUBST
# Icono al inicio (logo Debian de Nerd Fonts, U+F306). Requiere una fuente NF,
# p.ej. "CaskaydiaCove NF" / "Cascadia Code NF" en Windows Terminal.
# Alternativas:  (tux, U+F31A)  🐧  λ  ➜
PROMPT_ICON=$''
# icon user ruta (rama*+) %   — el simbolo se pone rojo si el ultimo comando fallo
PROMPT='%F{168}${PROMPT_ICON}%f %F{114}%n%f %F{222}%2~%f${vcs_info_msg_0_} %(?.%F{114}.%F{203})%#%f '
# codigo de salida a la derecha, solo cuando hay error
RPROMPT='%(?..%F{203}[%?]%f)'

# -- Completado -------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
# insensible a mayusculas + parcial: "g-c" completa a "git-commit", "doc" a ".docker"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
# colores en el menu (mismos que ls) y titulos por grupo
(( $+commands[dircolors] )) && [[ -z $LS_COLORS ]] && eval "$(dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{222}— %d —%f'
zstyle ':completion:*:warnings' format '%F{203}— sin coincidencias —%f'
# cache (acelera completados pesados como apt o dpkg)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# -- Historial ----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY SHARE_HISTORY

# Flechas: buscar en historial por prefijo
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# -- Opciones ------------------------------------------------------------------
setopt AUTO_CD
bindkey -e

# -- Entorno ---------------------------------------------------------------
# Homebrew (macOS)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LANG=en_US.UTF-8

typeset -U path
path=($HOME/.local/bin $path)
[[ -d $HOME/go/bin ]] && path+=($HOME/go/bin)
[[ -d $HOME/.npm-global/bin ]] && path+=($HOME/.npm-global/bin)
export PATH

# -- Aliases ---------------------------------------------------------------
# ls con color: GNU (Debian) usa --color, BSD (macOS) usa CLICOLOR
if [[ $OSTYPE == darwin* ]]; then
  export CLICOLOR=1
else
  alias ls='ls --color=auto'
fi
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'

# -- fzf (keybindings del paquete del sistema, si existe) --------------------
for _f in /usr/share/doc/fzf/examples/key-bindings.zsh \
          /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
          /usr/local/opt/fzf/shell/key-bindings.zsh; do
  [[ -f $_f ]] && { source "$_f"; break; }
done

# -- WSL: VS Code -----------------------------------------------------------
[[ -d "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin" ]] && \
  path+=("/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin")

# -- Secretos y ajustes locales (no versionados) -----------------------------
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# -- Resaltado de sintaxis y sugerencias (paquetes del sistema, si existen) --
# Debian: sudo apt install zsh-autosuggestions zsh-syntax-highlighting
# macOS:  brew install zsh-autosuggestions zsh-syntax-highlighting
for _f in /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
          /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
          /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -f $_f ]] && { source "$_f"; break; }
done
# este debe cargarse al final del .zshrc
for _f in /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
          /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
          /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f $_f ]] && { source "$_f"; break; }
done
unset _f
