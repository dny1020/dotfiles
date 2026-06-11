# ~/.zshrc - configuracion minima, sin frameworks

# -- Prompt (rama git via vcs_info, nativo de zsh) -------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%n@%m %1~${vcs_info_msg_0_} %# '

# -- Completado -------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

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
alias ls='ls --color=auto'
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

# -- fzf (keybindings del paquete de Debian, si existe) ---------------------
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh

# -- WSL: VS Code -----------------------------------------------------------
[[ -d "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin" ]] && \
  path+=("/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin")

# -- Secretos y ajustes locales (no versionados) -----------------------------
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
