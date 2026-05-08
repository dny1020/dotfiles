#!/usr/bin/env bash
# Usage: bash setup_dotfiles_macos.sh
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "ERROR: run without sudo on macOS: bash $0"
  exit 1
fi

REAL_USER="$USER"
REAL_HOME="$HOME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
BACKUP_DIR="$REAL_HOME/dotfiles_backup"
ZSH_CUSTOM="${ZSH_CUSTOM:-$REAL_HOME/.oh-my-zsh/custom}"

step() { echo; echo "──> $*"; }
ok()   { echo "    [ok] $*"; }
skip() { echo "    [skip] $*"; }

backup_target() {
  local rel="$1"
  local target="$REAL_HOME/$rel"
  local backup="$BACKUP_DIR/$rel"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    ok "backed up $rel"
  fi
}

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "ERROR: dotfiles directory not found: $DOTFILES_DIR"
  exit 1
fi

step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew is required. Install it first from https://brew.sh/"
  exit 1
fi
ok "brew found"

step "Installing system packages with brew"
brew install stow git zsh wget curl starship zoxide fzf lsd
ok "stow git zsh wget curl starship zoxide fzf lsd"

step "Installing oh-my-zsh"
if [[ ! -d "$REAL_HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  ok "oh-my-zsh installed"
else
  skip "oh-my-zsh already present"
fi

step "Installing zsh plugins"
install_plugin() {
  local name="$1" repo="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"
  if [[ ! -d "$dest" ]]; then
    git clone --depth=1 "$repo" "$dest"
    ok "$name"
  else
    skip "$name already present"
  fi
}

install_plugin zsh-autosuggestions       https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting   https://github.com/zsh-users/zsh-syntax-highlighting
install_plugin history-substring-search  https://github.com/zsh-users/zsh-history-substring-search

step "Applying dotfiles with stow"
mkdir -p "$BACKUP_DIR"

backup_target ".zshrc"
backup_target ".tmux.conf"
backup_target ".vimrc"
backup_target ".config/starship.toml"
backup_target ".config/alacritty/alacritty.toml"
backup_target ".config/nvim/init.lua"
backup_target ".config/nvim/lazy-lock.json"

for pkg in vim zsh tmux starship alacritty nvim; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    stow -d "$DOTFILES_DIR" -t "$REAL_HOME" "$pkg"
    ok "stowed $pkg"
  else
    skip "$pkg directory not found in dotfiles"
  fi
done

step "Setting zsh as default shell"
ZSH_BIN="$(command -v zsh)"
CURRENT_SHELL="$(dscl . -read "/Users/$REAL_USER" UserShell | awk '{print $2}')"
if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
  chsh -s "$ZSH_BIN"
  ok "default shell changed to $ZSH_BIN"
else
  skip "zsh is already the default shell"
fi

echo
echo "macOS setup complete. Start a new shell or run: exec zsh"
