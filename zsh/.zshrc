# ~/.zshrc

# Prompt Git nativo
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats ' %F{176}(%b)%f'

setopt PROMPT_SUBST

PROMPT='%F{114}%n%f %F{222}%1~%f${vcs_info_msg_0_} %(?.%F{114}.%F{203})%#%f '
RPROMPT='%(?..%F{203}[%?]%f)'

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
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# PATH personal
export PATH="$HOME/.local/bin:$PATH"

# Alias
alias ll='ls -lh'
alias la='ls -lah'

alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'

# Secretos locales
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
