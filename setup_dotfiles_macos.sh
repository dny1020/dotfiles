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

step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew is required. Install it first from https://brew.sh/"
  exit 1
fi
ok "brew found"

step "Installing system packages with brew"
brew install stow git zsh wget curl vim fzf ripgrep universal-ctags
ok "stow git zsh wget curl vim fzf ripgrep universal-ctags"

step "Applying dotfiles with stow"
mkdir -p "$BACKUP_DIR"

backup_target ".zshrc"
backup_target ".vimrc"
backup_target ".gitconfig"
backup_target ".config/alacritty/alacritty.toml"

for pkg in vim zsh git alacritty; do
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
