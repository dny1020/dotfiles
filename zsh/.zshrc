# ~/.zshrc

# herdr vive en ~/.local/bin: tiene que estar en el PATH antes del autoarranque
export PATH="$HOME/.local/bin:$PATH"

# ── Arrancar herdr automáticamente al abrir la terminal ──────────────────────
# Se adjunta a su sesión persistente o la crea. Guardas: solo en shell
# interactiva, si no estamos ya dentro de herdr/tmux, si no es una terminal
# "tonta" (TTY de rescate/dumb) ni el shell integrado de un editor.
# Para desactivarlo, comenta este bloque.
if command -v herdr >/dev/null \
   && [[ $- == *i* ]] && [[ -z "$HERDR_ENV$TMUX" ]] \
   && [[ "$TERM" != dumb && "$TERM" != linux ]] \
   && [[ -z "$VSCODE_INJECTION$INSIDE_EMACS$CLAUDECODE" ]]; then
  exec herdr
fi

# Prompt
command -v starship >/dev/null && eval "$(starship init zsh)"

# Completado
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
# Bloqueo fcntl al escribir el historial: con muchos paneles de tmux guardando
# a la vez, el método por defecto puede pisarse y perder entradas.
setopt HIST_FCNTL_LOCK

# Editor
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# PATH personal
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

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
alias gl='git log --oneline --graph --decorate -20'

# wt <branch>: one git worktree per agent/herdr pane, next to the repo as
# ../<repo>-<branch>, so parallel agents never share a working tree.
# No args lists them; clean up with `git worktree remove <dir>`.
wt() {
  [[ -z "$1" ]] && { git worktree list; return; }
  local root dir
  root=$(git rev-parse --show-toplevel) || return
  dir="${root:h}/${root:t}-${1//\//-}"
  if git show-ref --quiet --verify "refs/heads/$1"; then
    git worktree add "$dir" "$1" || return
  else
    git worktree add -b "$1" "$dir" || return
  fi
  cd "$dir"
}

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

# AWS local: siempre usa el endpoint del contenedor y credenciales no reales.
alias awsl='AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test aws'

# AWS production: elimina configuracion local antes de usar el perfil real.
awsp() {
  env -u AWS_ENDPOINT_URL -u AWS_ACCESS_KEY_ID -u AWS_SECRET_ACCESS_KEY \
    -u AWS_SESSION_TOKEN -u AWS_SECURITY_TOKEN \
    AWS_PROFILE="${AWS_PROD_PROFILE:-default}" aws "$@"
}

# Terraform: los mismos comandos sirven desde cualquier repositorio.
alias tf-local='AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test terraform'
alias tf-prod='env -u AWS_ENDPOINT_URL -u AWS_ACCESS_KEY_ID -u AWS_SECRET_ACCESS_KEY -u AWS_SESSION_TOKEN -u AWS_SECURITY_TOKEN AWS_PROFILE="${AWS_PROD_PROFILE:-default}" terraform'
[[ -d "$HOME/.npm-global/bin" ]] && export PATH="$HOME/.npm-global/bin:$PATH"

# zoxide: tu `cd` de siempre, pero recuerda a dónde sueles ir.
# Va al final del todo porque zoxide exige inicializarse el último; si queda
# algo después, avisa en cada arranque con "possible configuration issue".
# Claude Code replays this shell's functions in its own non-interactive shells,
# where zoxide's hook is missing: every `cd` printed a doctor warning and a
# mistyped path would silently jump elsewhere. Agents get the plain builtin.
if command -v zoxide >/dev/null && [[ -z "$CLAUDECODE" ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi
