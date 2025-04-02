# ==============================
#         BEAUTIFUL ZSH
# ==============================

# Enable Powerlevel10k instant prompt (should be at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k theme before anything else
source $HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# Oh My Zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# ==============================
#        🛠️ PLUGINS
# ==============================
plugins=(
  git                  # Git integration
  zsh-syntax-highlighting  # Colorizes commands
  zsh-autosuggestions  # Suggests commands based on history
  zsh-completions      # Improves autocomplete
  fzf                  # Fuzzy finder
  docker               # Docker aliases & autocomplete
  kubectl              # Kubernetes aliases & autocomplete
  extract              # Extracts files easily
  sudo                # Enables !! and !* with sudo
  history-substring-search  # Smarter history search
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ==============================
#      🚀 PERFORMANCE TWEAKS
# ==============================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt append_history          # Append to history instead of overwriting
setopt histignoredups          # Ignore duplicate history entries
setopt histignorespace         # Ignore commands that start with a space
setopt share_history           # Share history across sessions
setopt inc_append_history      # Save commands as they are typed
setopt autocd                  # Change directories without typing `cd`
setopt nocorrect               # Disable autocorrect for commands

# ==============================
#     🎨 BEAUTIFUL UI
# ==============================
setopt prompt_subst
autoload -Uz colors && colors   # Enable color support
export TERM="xterm-256color"

# Enable Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==============================
#       🏗️ ALIASES
# ==============================

# 🌟 Directory Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias home="cd ~"
alias dl="cd ~/Downloads"

# 🔍 Listing & Searching
alias ls='eza --icons --color=auto --long --group-directories-first'
alias ll='ls -lAh'
alias la='ls -A'
alias l='ls -CF'
alias findbig="du -hsx * | sort -rh | head -10"

# 📝 Text Editing
export VISUAL=nvim
export EDITOR="$VISUAL"


# 🖥️ System Monitoring
alias cpu="top -o cpu"
alias mem="top -o rsize"
alias dfh="df -h"

# 🌍 Network
alias myip="curl ifconfig.me"
alias speedtest="speedtest-cli"

# 🛠️ Utilities
alias reload!='source ~/.zshrc'  # Reload Zsh config
alias cls="clear"
alias grep="grep --color=auto"
alias update="sudo apt update && sudo apt upgrade -y"

# ==============================
#      🚀 FUNCTION SHORTCUTS
# ==============================

# Extract files easily
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Unknown file format" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Fuzzy finder directory navigation
fd() {
  local dir
  dir=$(find ${1:-.} -type d | fzf) && cd "$dir"
}

# Search history with fzf
fh() {
  history | fzf
}

# ==============================
#     🔥 AUTO-COMPLETION
# ==============================
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

# ==============================
#     ⚡ PATH CONFIGURATION
# ==============================
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
export PATH="$HOME/.local/bin:$PATH"

# Add Go, Rust, Node.js paths
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# ==============================
#     ⏩ STARTUP SPEEDUP
# ==============================
if [ -n "$SSH_CONNECTION" ]; then
  export DISABLE_UPDATE_PROMPT=true
fi

# ==============================
#     🎯 FINAL TOUCHES
# ==============================
# Load fzf keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load Powerlevel10k prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias dotfiles='git --git-dir=/Users/Dny/.dotfiles --work-tree=/Users/Dny'
