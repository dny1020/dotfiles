# ========================
#   Professional Zsh Configuration
#   macOS Optimized
# ========================

# ========================
# POWERLEVEL10K INSTANT PROMPT (DISABLED)
# ========================
# Using Starship; keep this block commented.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# ========================
# OH-MY-ZSH CONFIGURATION
# ========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# Plugins (minimal set for speed)
plugins=(
  git
  sudo
  z
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config (disabled)
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ========================
# GENERAL SETTINGS
# ========================

# Editor
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Terminal
export TERM="xterm-256color"

# ========================
# HISTORY CONFIGURATION
# ========================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000              # Memory history size
export SAVEHIST=100000              # File history size
export HISTORY_IGNORE="(ls|cd|pwd|exit|cd ..|clear|cls)"

# History options
setopt HIST_FIND_NO_DUPS           # Don't show duplicates in search
setopt HIST_IGNORE_ALL_DUPS        # Remove older duplicate entries
setopt HIST_IGNORE_DUPS            # Don't record duplicates
setopt HIST_IGNORE_SPACE           # Don't record entries starting with space
setopt HIST_REDUCE_BLANKS          # Remove superfluous blanks
setopt HIST_SAVE_NO_DUPS           # Don't write duplicates to history file
setopt HIST_VERIFY                 # Don't execute immediately upon history expansion
setopt INC_APPEND_HISTORY          # Write to history file immediately
setopt SHARE_HISTORY               # Share history between sessions
setopt EXTENDED_HISTORY            # Record timestamp of command

# ========================
# ZSH OPTIONS
# ========================
setopt AUTO_CD                     # cd by typing directory name
setopt AUTO_PUSHD                  # Push directories onto stack
setopt PUSHD_IGNORE_DUPS           # Don't push duplicates
setopt PUSHD_SILENT                # Don't print directory stack
unsetopt CORRECT                  # Disable spell correction (faster command submit)
setopt COMPLETE_IN_WORD            # Complete from both ends of word
setopt ALWAYS_TO_END               # Move cursor to end after completion
setopt PATH_DIRS                   # Perform path search even on command names with slashes
setopt AUTO_MENU                   # Show completion menu on successive tab press
setopt AUTO_LIST                   # Automatically list choices on ambiguous completion
setopt MENU_COMPLETE               # Insert first match immediately
setopt GLOB_DOTS                   # Match hidden files without explicitly specifying dot

# ========================
# PATH CONFIGURATION
# ========================
# Remove duplicates from PATH
typeset -U path

# Build PATH (order matters - first has priority)
path=(
  $HOME/.local/bin
  $HOME/bin
  $HOME/.cargo/bin              # Rust
  $HOME/go/bin                  # Go
  $HOME/.npm-global/bin         # Node global
  /usr/local/opt/python@3.11/libexec/bin  # Python 3.11
  /opt/homebrew/bin             # Homebrew (Apple Silicon)
  /opt/homebrew/sbin
  /usr/local/bin                # Homebrew (Intel)
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

# Windsurf (added by installer)
[[ -d "$HOME/.codeium/windsurf/bin" ]] && path=("$HOME/.codeium/windsurf/bin" $path)

export PATH

# ========================
# ENVIRONMENT VARIABLES
# ========================

# FZF Configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,info:#83a598,prompt:#bdae93,pointer:#fe8019,marker:#fe8019,spinner:#fabd2f,header:#665c54"

# Use fd if available
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ripgrep configuration (avoid errors if file doesn't exist)
if [[ -f "$HOME/.ripgreprc" ]]; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
else
  unset RIPGREP_CONFIG_PATH
fi

# Less configuration (better paging)
export LESS='-R -F -X -i -g -s -M'
export LESSCHARSET='utf-8'

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# zoxide (smarter cd)
eval "$(zoxide init zsh)"

# ========================
# ALIASES - GENERAL
# ========================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List directory contents (icons + muted colors)
alias ls='lsd'
alias l='lsd -lh'
alias la='lsd -lah'
alias ll='lsd -lh'
alias lla='lsd -lah'

# Better directory listing
alias lsize='ls -lhS'               # Sort by size
alias ltime='ls -lht'               # Sort by time
alias ldot='ls -ld .*'              # List dot files

# File operations
alias cp='cp -iv'                   # Interactive, verbose
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'             # Create parent dirs, verbose

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# System
alias c='clear'
alias cls='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'

# Reload shell
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR} ~/.zshrc'
alias vimrc='${EDITOR} ~/.vimrc'
alias vim='nvim'

# ========================
# ALIASES - macOS SPECIFIC
# ========================

# macOS shortcuts
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop true; killall Finder'
alias hidedesktop='defaults write com.apple.finder CreateDesktop false; killall Finder'

# Quick access
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias docs='cd ~/Documents'
alias dev='cd ~/Developer'

# System monitoring
alias cpu='top -o cpu'
alias mem='top -o rsize'
alias battery='pmset -g batt'

# Network
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Disk usage
alias df='df -h'
alias du='du -h -d 1'
alias ducks='du -cks * | sort -rn | head'

# Processes
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ka='killall'

# Copy SSH key
alias copyssh='pbcopy < ~/.ssh/id_rsa.pub'

# macOS app shortcuts (use 'open -a AppName' directly if rarely used)

# Lock screen
alias afk='pmset displaysleepnow'

# ========================
# ALIASES - GIT
# ========================

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

# Git WIP shortcuts
alias gwip='git add -A && git commit --no-verify -m "WIP"'
alias gunwip='git reset HEAD~1'

# ========================
# ALIASES - DEVELOPMENT
# ========================

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dstop='docker stop $(docker ps -q)'

# Node/NPM/Yarn
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nup='npm update'
alias yi='yarn install'
alias ya='yarn add'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Brew
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewinfo='brew leaves | xargs brew desc --eval-all'

# ========================
# FUNCTIONS
# ========================

# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives (oh-my-zsh extract plugin provides this, kept for redundancy)
# Usage: extract <file>

# FZF enhanced functions
# Fuzzy find directory and cd
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# Fuzzy find file and open in editor
fv() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && ${EDITOR} "$file"
}

# Fuzzy kill process
fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}

# Fuzzy history search and execute
fh() {
  eval $(history | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Fuzzy git branch checkout
fgb() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf +s +m -e) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Fuzzy git log browser
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

# Fuzzy git add
fga() {
  git status --short | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}' | xargs git add
}

# Find and replace in files
findreplace() {
  if [ $# -ne 2 ]; then
    echo "Usage: findreplace <search> <replace>"
    return 1
  fi
  grep -rl "$1" . | xargs sed -i "" "s/$1/$2/g"
}

# Create a backup of a file
backup() {
  cp "$1"{,.bak}
}

# Get the weather
weather() {
  curl "wttr.in/${1:-}"
}

# Man pages with colors
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

# Quick note taking
note() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$HOME/.notes"
}

notes() {
  ${EDITOR} "$HOME/.notes"
}

# Server a directory over HTTP
serve() {
  python3 -m http.server ${1:-8000}
}

# Get cheatsheet from cheat.sh
cheat() {
  curl "cheat.sh/$1"
}

# Create a QR code
qr() {
  curl "qrenco.de/$1"
}

# Dotfiles management (bare git repo)
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Update all: Homebrew, npm, pip, etc.
updateall() {
  echo "Updating Homebrew..."
  brew update && brew upgrade && brew cleanup

  echo "\nUpdating npm..."
  npm update -g

  echo "\nUpdating pip..."
  pip3 install --upgrade pip setuptools wheel

  echo "\nUpdating Oh My Zsh..."
  omz update

  echo "\nDone!"
}

# Show file tree with colored output
tree() {
  if command -v tree &> /dev/null; then
    command tree -C "$@"
  else
    find ${1:-.} -print | sed -e 's;[^/]*/;|____;g;s;____|;  |;g'
  fi
}

# Better cat with syntax highlighting (if bat is installed)
if command -v bat &> /dev/null; then
  alias cat='bat --style=plain'
  alias catn='bat --style=numbers'
  alias cata='bat --style=full'
fi

# ========================
# SECURITY & SECRETS
# ========================

# Load secrets from a separate file (not tracked in git)
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# Example ~/.zsh_secrets file:
# export OPENAI_API_KEY="sk-..."
# export AWS_ACCESS_KEY_ID="..."
# export AWS_SECRET_ACCESS_KEY="..."

# If you need AI tools, uncomment and move to ~/.zsh_secrets:
# export OPENAI_API_KEY="sk-XXX"
# alias ai="sgpt"

# ========================
# KEYBINDINGS
# ========================

# Vi mode
# bindkey -v  # Uncomment for vi mode

# Use emacs keybindings
bindkey -e

# Better history search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl+Z to foreground last background job
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

# ========================
# PERFORMANCE
# ========================

# Lazy load nvm (Node Version Manager) for faster shell startup
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  alias nvm='unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@'
  alias node='unalias node; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; node $@'
  alias npm='unalias npm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npm $@'
fi

# ========================
# WELCOME MESSAGE
# ========================

# Uncomment to show system info on startup
# if command -v neofetch &> /dev/null; then
#   neofetch
# fi

# ========================
# ADDITIONAL SOURCES
# ========================

# FZF keybindings/completion (single source)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local customizations (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ========================
#   End of Configuration
# ========================

eval "$(starship init zsh)"

export PATH=~/.opencode/bin:$PATH
export PATH="$PATH:/mnt/c/Users/user/AppData/Local/Programs/Microsoft VS Code/bin"
alias cat="batcat"
