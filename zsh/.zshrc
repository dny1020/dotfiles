# ~/.zshrc

# ── Arrancar tmux automáticamente al abrir la terminal ───────────────────────
# Se adjunta a la sesión 'main' si ya existe, o la crea (new-session -A).
# Guardas: solo en shell interactiva, si no estamos ya dentro de tmux, si no es
# una terminal "tonta" (TTY de rescate/dumb) ni el shell integrado de un editor.
# Para desactivarlo, comenta este bloque.
if command -v tmux >/dev/null \
   && [[ $- == *i* ]] && [[ -z "$TMUX" ]] \
   && [[ "$TERM" != dumb && "$TERM" != linux ]] \
   && [[ -z "$VSCODE_INJECTION$INSIDE_EMACS" ]]; then
  exec tmux new-session -A -s main
fi

# Prompt: Starship si está instalado; si no, prompt nativo zsh (fallback)
autoload -Uz add-zsh-hook
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
else
  # Prompt Git nativo
  autoload -Uz vcs_info
  add-zsh-hook precmd vcs_info   # via hook para poder anteponer otros precmd (p.ej. ai.zsh)

  zstyle ':vcs_info:git:*' formats ' %F{176}(%b)%f'

  setopt PROMPT_SUBST

  PROMPT='%F{114}%n%f %F{222}%1~%f${vcs_info_msg_0_} %(?.%F{114}.%F{203})%#%f '
  RPROMPT='%(?..%F{203}[%?]%f)'
fi

# Completado
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# Editor
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# PATH personal
export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
[[ -d "$HOME/.bin" ]] && export PATH="$HOME/.bin:$PATH"

# Alias
alias vim='nvim'   # migrado a Neovim; el comando `vim` sigue funcionando
alias ll='ls -lh'
alias la='ls -lah'

alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'

# clip: copiar stdin al portapapeles, según el SO (macOS / Linux X11 / WSL)
if command -v pbcopy >/dev/null; then
  alias clip='pbcopy'
elif command -v xclip >/dev/null; then
  alias clip='xclip -selection clipboard'
elif command -v clip.exe >/dev/null; then
  alias clip='clip.exe'
fi

# Secretos y ajustes por máquina (no versionados; ver README)
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Herramientas modernas como alias (eza/zoxide/bat/fd) y copiloto local llama.cpp
[[ -f ~/.config/shell/tools.zsh ]] && source ~/.config/shell/tools.zsh
[[ -f ~/.config/shell/ai.zsh ]] && source ~/.config/shell/ai.zsh

# Autosuggestions / highlighting / fzf / historial (debe ir el ÚLTIMO source)
[[ -f ~/.config/shell/zsh-enhance.zsh ]] && source ~/.config/shell/zsh-enhance.zsh

# zoxide: tu `cd` de siempre, pero recuerda a dónde sueles ir.
# Va al final del todo porque zoxide exige inicializarse el último.
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# alias awsl: AWS CLI con MiniStack
alias awsl='aws --endpoint-url=http://localhost:4566'

# alias awsp: AWS CLI con perfil de produccion
alias awsp='aws --profile produccion'
# alias aws-dev: alias directo sin perfil (default)
alias aws-default='aws --profile default'
DOCTION_MCP_TOKEN=REMOVED
