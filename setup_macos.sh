#!/usr/bin/env bash
# Despliegue para macOS: paquetes brew + dotfiles nvim, zsh y alacritty.
# Uso: bash setup_macos.sh
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "ERROR: ejecuta sin sudo en macOS: bash $0"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup"

step() { echo; echo "──> $*"; }
ok()   { echo "    [ok] $*"; }
skip() { echo "    [skip] $*"; }

backup_target() {
  local rel="$1" target="$HOME/$1" backup="$BACKUP_DIR/$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    ok "respaldado $rel"
  fi
}

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
step "Comprobando Homebrew"
command -v brew >/dev/null || { echo "ERROR: instala Homebrew primero: https://brew.sh/"; exit 1; }
ok "brew encontrado"

# ── 2. Paquetes ───────────────────────────────────────────────────────────────
step "Instalando paquetes con brew"
brew install stow git neovim zsh curl wget fzf ripgrep universal-ctags jq tree htop \
  eza zoxide tealdeer bat fd starship tmux
ok "paquetes instalados"
brew install --cask alacritty || skip "alacritty (cask) — instálalo manualmente si lo necesitas"

# ── 3. Dotfiles con stow ──────────────────────────────────────────────────────
step "Aplicando dotfiles con stow"
mkdir -p "$BACKUP_DIR"
backup_target ".config/nvim"
backup_target ".zshrc"
backup_target ".config/alacritty/alacritty.toml"
mkdir -p "$HOME/.config/opencode"   # solo enlaza opencode.json; runtime/node_modules fuera del repo
mkdir -p "$HOME/.config/tealdeer"   # solo enlaza config.toml; el cache vive en ~/.cache
for pkg in nvim zsh tmux alacritty opencode tealdeer; do
  stow -d "$SCRIPT_DIR" -t "$HOME" "$pkg"
  ok "stow $pkg"
done

# Semilla del cache de tldr (sin esto el primer `tldr` falla pidiendo --update).
if command -v tldr >/dev/null 2>&1; then
  tldr --update >/dev/null 2>&1 && ok "cache de tldr descargado" || skip "no se pudo descargar el cache de tldr"
fi

# Instala los plugins (lazy.nvim) según lazy-lock.json, en headless; no es fatal si falla.
step "Instalando plugins de Neovim (versiones del lockfile)"
nvim --headless "+Lazy! restore" +qa 2>/dev/null && ok "plugins instalados" \
  || skip "instálalos luego con: nvim (lazy lo hace solo al primer arranque)"

# ── 4. zsh como shell por defecto ─────────────────────────────────────────────
step "Estableciendo zsh como shell por defecto"
ZSH_BIN="$(command -v zsh)"
if [[ "$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')" != "$ZSH_BIN" ]]; then
  chsh -s "$ZSH_BIN"
  ok "shell cambiado a $ZSH_BIN"
else
  skip "zsh ya es el shell por defecto"
fi

echo
echo "Listo. Abre una nueva shell o ejecuta: exec zsh"
