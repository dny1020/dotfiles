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
PACKAGE_LIST="$DOTFILES_DIR/packages/packages.txt"
SSH_BUNDLE="$DOTFILES_DIR/ssh/backup.tar.gpg"

# Run a command as the real user (not root)
as_user() { sudo -u "$REAL_USER" env HOME="$REAL_HOME" "$@"; }

step() { echo; echo "──> $*"; }
ok()   { echo "    [ok] $*"; }
skip() { echo "    [skip] $*"; }

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

restore_encrypted_ssh() {
  if [[ ! -f "$SSH_BUNDLE" ]]; then
    skip "encrypted SSH bundle not found"
    return
  fi

  if [[ -z "${SSH_PASSPHRASE:-}" ]]; then
    read -rsp "SSH bundle passphrase: " SSH_PASSPHRASE
    echo
  fi

  step "Restoring encrypted SSH bundle"
  install -d -m 700 "$REAL_HOME/.ssh"
  chown "$REAL_USER":"$REAL_USER" "$REAL_HOME/.ssh"

  local tmpdir
  tmpdir=$(mktemp -d /tmp/dotfiles-ssh.XXXXXX)
  trap 'rm -rf "$tmpdir"' RETURN

  as_user gpg --batch --yes --pinentry-mode loopback --passphrase "$SSH_PASSPHRASE" \
    --decrypt "$SSH_BUNDLE" | tar -xz -C "$tmpdir"

  if [[ -d "$tmpdir/.ssh" ]]; then
    cp -a "$tmpdir/.ssh/." "$REAL_HOME/.ssh/"
    chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/.ssh"
    chmod 700 "$REAL_HOME/.ssh"
    [[ -f "$REAL_HOME/.ssh/config" ]] && chmod 600 "$REAL_HOME/.ssh/config"
    [[ -f "$REAL_HOME/.ssh/id_ed25519" ]] && chmod 600 "$REAL_HOME/.ssh/id_ed25519"
    ok "SSH bundle restored"
  else
    echo "ERROR: decrypted SSH bundle did not contain .ssh/"
    exit 1
  fi
}

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run with sudo: sudo bash $0"
  exit 1
fi

# ── 1. System packages ────────────────────────────────────────────────────────
step "Installing system packages"
apt-get update -qq
apt-get install -y $(grep -vE '^(#|$)' "$PACKAGE_LIST" | xargs)
ok "packages installed"

# ── 2. Stow dotfiles ──────────────────────────────────────────────────────────
step "Applying dotfiles with stow"
mkdir -p "$BACKUP_DIR"
chown "$REAL_USER":"$REAL_USER" "$BACKUP_DIR"

backup_target ".zshrc"
backup_target ".vimrc"
backup_target ".gitconfig"

for pkg in vim zsh git; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    as_user stow -d "$DOTFILES_DIR" -t "$REAL_HOME" "$pkg"
    ok "stowed $pkg"
  else
    skip "$pkg directory not found in dotfiles"
  fi
done

# ── 3. SSH ────────────────────────────────────────────────────────────────────
restore_encrypted_ssh

# ── 4. Default shell ──────────────────────────────────────────────────────────
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
