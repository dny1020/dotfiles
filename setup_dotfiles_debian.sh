#!/usr/bin/env bash
# Usage: sudo bash setup_dotfiles_debian.sh
set -euo pipefail

# ── Resolve real user when invoked via sudo ───────────────────────────────────
if [[ -n "${SUDO_USER:-}" ]]; then
  REAL_USER="$SUDO_USER"
  REAL_HOME="$(eval echo "~$SUDO_USER")"
else
  REAL_USER="$USER"
  REAL_HOME="$HOME"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
BACKUP_DIR="$REAL_HOME/dotfiles_backup"
ZSH_CUSTOM="$REAL_HOME/.oh-my-zsh/custom"

# Run a command as the real user (not root)
as_user() { sudo -u "$REAL_USER" env HOME="$REAL_HOME" "$@"; }

# ── Helpers ───────────────────────────────────────────────────────────────────
step()    { echo; echo "──> $*"; }
ok()      { echo "    [ok] $*"; }
skip()    { echo "    [skip] $*"; }

backup_target() {
  local rel="$1"
  local target="$REAL_HOME/$rel"
  local backup="$BACKUP_DIR/$rel"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$(dirname "$backup")"
    chown "$REAL_USER":"$REAL_USER" "$(dirname "$backup")"
    mv "$target" "$backup"
    ok "backed up $rel"
  fi
}

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "ERROR: dotfiles directory not found: $DOTFILES_DIR"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run with sudo: sudo bash $0"
  exit 1
fi

# ── 1. System packages (needs root) ──────────────────────────────────────────
step "Installing system packages"
apt-get update -qq
apt-get install -y stow curl wget git zsh unzip
ok "stow curl wget git zsh unzip"

# ── 2. oh-my-zsh ─────────────────────────────────────────────────────────────
step "Installing oh-my-zsh"
if [[ ! -d "$REAL_HOME/.oh-my-zsh" ]]; then
  as_user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  ok "oh-my-zsh installed"
else
  skip "oh-my-zsh already present"
fi

# ── 3. zsh plugins ───────────────────────────────────────────────────────────
step "Installing zsh plugins"

install_plugin() {
  local name="$1" repo="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"
  if [[ ! -d "$dest" ]]; then
    as_user git clone --depth=1 "$repo" "$dest"
    ok "$name"
  else
    skip "$name already present"
  fi
}

install_plugin zsh-autosuggestions       https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting   https://github.com/zsh-users/zsh-syntax-highlighting
install_plugin history-substring-search  https://github.com/zsh-users/zsh-history-substring-search

# ── 4. starship ──────────────────────────────────────────────────────────────
step "Installing starship"
if ! command -v starship &>/dev/null; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  ok "starship installed"
else
  skip "starship already installed ($(starship --version))"
fi

# ── 5. zoxide ────────────────────────────────────────────────────────────────
step "Installing zoxide"
if ! command -v zoxide &>/dev/null; then
  as_user sh -c "$(curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"
  ok "zoxide installed"
else
  skip "zoxide already installed"
fi

# ── 6. fzf ───────────────────────────────────────────────────────────────────
step "Installing fzf"
if ! command -v fzf &>/dev/null; then
  as_user git clone --depth 1 https://github.com/junegunn/fzf.git "$REAL_HOME/.fzf"
  as_user "$REAL_HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc
  ok "fzf installed"
else
  skip "fzf already installed"
fi

# ── 7. lsd ───────────────────────────────────────────────────────────────────
step "Installing lsd"
if ! command -v lsd &>/dev/null && [[ ! -f "$REAL_HOME/.local/bin/lsd" ]]; then
  LSD_VERSION=$(curl -fsSL https://api.github.com/repos/lsd-rs/lsd/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  ARCHIVE="lsd-${LSD_VERSION}-x86_64-unknown-linux-gnu"
  curl -fsSLo /tmp/lsd.tar.gz \
    "https://github.com/lsd-rs/lsd/releases/download/${LSD_VERSION}/${ARCHIVE}.tar.gz"
  tar -xzf /tmp/lsd.tar.gz -C /tmp
  mkdir -p "$REAL_HOME/.local/bin"
  mv "/tmp/${ARCHIVE}/lsd" "$REAL_HOME/.local/bin/lsd"
  chown "$REAL_USER":"$REAL_USER" "$REAL_HOME/.local/bin/lsd"
  rm -rf /tmp/lsd.tar.gz "/tmp/${ARCHIVE}"
  ok "lsd ${LSD_VERSION} installed to ~/.local/bin"
else
  skip "lsd already installed"
fi

# ── 8. Stow dotfiles ─────────────────────────────────────────────────────────
step "Applying dotfiles with stow"
mkdir -p "$BACKUP_DIR"
chown "$REAL_USER":"$REAL_USER" "$BACKUP_DIR"

backup_target ".zshrc"
backup_target ".tmux.conf"
backup_target ".vimrc"
backup_target ".config/starship.toml"
backup_target ".config/alacritty/alacritty.toml"
backup_target ".config/nvim/init.lua"
backup_target ".config/nvim/lazy-lock.json"

for pkg in vim zsh tmux starship alacritty nvim; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    as_user stow -d "$DOTFILES_DIR" -t "$REAL_HOME" "$pkg"
    ok "stowed $pkg"
  else
    skip "$pkg directory not found in dotfiles"
  fi
done

# ── 9. Default shell ──────────────────────────────────────────────────────────
step "Setting zsh as default shell"
ZSH_BIN="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$REAL_USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
  chsh -s "$ZSH_BIN" "$REAL_USER"
  ok "default shell changed to $ZSH_BIN"
else
  skip "zsh is already the default shell"
fi

echo
echo "Debian setup complete. Start a new shell or run: exec zsh"
