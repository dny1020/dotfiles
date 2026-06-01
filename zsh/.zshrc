# Zsh Configuration - Debian WSL

# OH-MY-ZSH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  sudo
  z
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

# GENERAL SETTINGS
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
[[ -z "${TERM:-}" ]] && export TERM="xterm-256color"

# HISTORY
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
export HISTORY_IGNORE="(ls|cd|pwd|exit|cd ..|clear|cls)"

setopt HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS HIST_VERIFY INC_APPEND_HISTORY
setopt SHARE_HISTORY EXTENDED_HISTORY

# ZSH OPTIONS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
unsetopt CORRECT
setopt COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS AUTO_MENU AUTO_LIST MENU_COMPLETE GLOB_DOTS

# PATH
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/bin
  $HOME/go/bin
  $HOME/.npm-global/bin
  $HOME/.local/share/pi-node/node-v22.22.3-linux-x64/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

[[ -d "$HOME/.codeium/windsurf/bin" ]] && path=("$HOME/.codeium/windsurf/bin" $path)
[[ -d "$HOME/.local/share/nvim/mason/bin" ]] && path=("$HOME/.local/share/nvim/mason/bin" $path)
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && path=("$HOME/.antigravity/antigravity/bin" $path)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)

export PATH

# ENVIRONMENT
export FZF_BASE="$HOME/.fzf"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,info:#83a598,prompt:#bdae93,pointer:#fe8019,marker:#fe8019,spinner:#fabd2f,header:#665c54"

if command -v fd &> /dev/null; then
  export FZF_FD_CMD='fd'
elif command -v fdfind &> /dev/null; then
  export FZF_FD_CMD='fdfind'
fi

if [[ -n "${FZF_FD_CMD:-}" ]]; then
  export FZF_DEFAULT_COMMAND="${FZF_FD_CMD} --type f --hidden --follow --exclude .git"
  export FZF_ALT_C_COMMAND="${FZF_FD_CMD} --type d --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

[[ -f "$HOME/.ripgreprc" ]] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export LESS='-R -F -X -i -g -s -M'
export LESSCHARSET='utf-8'

command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"
command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# ALIASES - Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Listing
if command -v lsd &> /dev/null; then
  alias ls='lsd'
  alias l='lsd -lh'
  alias la='lsd -lah'
  alias ll='lsd -lh'
  alias lla='lsd -lah'
elif command -v exa &> /dev/null; then
  alias ls='exa --icons'
  alias l='exa -lh --icons'
  alias la='exa -lah --icons'
  alias ll='exa -lh --icons'
  alias lla='exa -lah --icons'
else
  alias ls='ls --color=auto'
  alias l='ls -lh --color=auto'
  alias la='ls -lah --color=auto'
  alias ll='ls -lh --color=auto'
  alias lla='ls -lah --color=auto'
fi

alias lsize='ls -lhS'
alias ltime='ls -lht'
alias ldot='ls -ld .*'

# Files
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# System
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'
alias myip='curl -s ifconfig.me'
alias df='df -h'
alias du='du -h -d 1'
alias ducks='du -cks * | sort -rn | head'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ka='killall'

# Shell
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR} ~/.zshrc'
alias vimrc='${EDITOR} ~/.vimrc'
alias vim='nvim'

# ALIASES - Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit -v --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gm='git merge'
alias gr='git remote'
alias grv='git remote -v'
alias gclean='git clean -fd'
alias greset='git reset --hard'
alias gwip='git add -A && git commit --no-verify -m "WIP"'
alias gunwip='git reset HEAD~1'

# ALIASES - Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dstop='docker stop $(docker ps -q)'

# ALIASES - Node/NPM
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nup='npm update'

# ALIASES - Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# FUNCTIONS

mkcd() { mkdir -p "$1" && cd "$1" }

fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

fv() {
  local file preview_cmd
  if command -v bat &> /dev/null; then
    preview_cmd='bat --color=always --style=numbers --line-range=:500 {}'
  elif command -v batcat &> /dev/null; then
    preview_cmd='batcat --color=always --style=numbers --line-range=:500 {}'
  else
    preview_cmd='sed -n "1,200p" {}'
  fi
  file=$(fzf --preview "$preview_cmd") && ${EDITOR} "$file"
}

fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}

fh() { eval $(history | fzf +s --tac | sed 's/ *[0-9]* *//') }

fgb() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf +s +m -e) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fgl() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
              (grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
              {}
FZF-EOF"
}

fga() {
  git status --short | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}' | xargs git add
}

findreplace() {
  if [ $# -ne 2 ]; then
    echo "Usage: findreplace <search> <replace>"
    return 1
  fi
  grep -rl "$1" . | xargs sed -i "s/$1/$2/g"
}

backup() { cp "$1"{,.bak} }

copyssh() {
  local key="${1:-$HOME/.ssh/id_ed25519.pub}"
  if command -v clip.exe &> /dev/null; then
    clip.exe < "$key"
  elif command -v xclip &> /dev/null; then
    xclip -selection clipboard < "$key"
  else
    echo "No clipboard tool found (clip.exe, xclip)." >&2
    return 1
  fi
}

weather() { curl "wttr.in/${1:-}" }

man() {
  env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

note() { echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$HOME/.notes" }
notes() { ${EDITOR} "$HOME/.notes" }
serve() { python3 -m http.server ${1:-8000} }
cheat() { curl "cheat.sh/$1" }
qr() { curl "qrenco.de/$1" }

alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

updateall() {
  echo "Updating apt..."
  sudo apt update && sudo apt upgrade -y

  echo "\nUpdating npm globals..."
  npm update -g

  echo "\nUpdating pip..."
  pip3 install --upgrade pip setuptools wheel

  echo "\nUpdating Oh My Zsh..."
  omz update

  echo "\nDone!"
}

unalias tree 2>/dev/null
tree() {
  if (( $+commands[eza] )); then
    command eza --tree --icons --color=always "$@"
  elif (( $+commands[exa] )); then
    command exa --tree --icons --color=always "$@"
  elif (( $+commands[tree] )); then
    command tree -C "$@"
  else
    find "${1:-.}" -print | sed -e 's;[^/]*/;|____;g;s;____|;  |;g'
  fi
}

if command -v bat &> /dev/null; then
  alias cat='bat --style=plain'
  alias catn='bat --style=numbers'
  alias cata='bat --style=full'
elif command -v batcat &> /dev/null; then
  alias bat='batcat'
  alias cat='batcat --style=plain'
  alias catn='batcat --style=numbers'
  alias cata='batcat --style=full'
fi

# SECRETS (not tracked in git)
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# KEYBINDINGS
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# NVM (lazy load)
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  alias nvm='unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@'
  alias node='unalias node; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; node $@'
  alias npm='unalias npm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npm $@'
fi

# FZF keybindings/completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local customizations (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

eval "$(starship init zsh)"

# WSL: VS Code
[[ -d "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin" ]] && \
  export PATH="$PATH:/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
