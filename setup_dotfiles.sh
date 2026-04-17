#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/dotfiles_backup}"
CONFIGS=(vim zsh tmux starship alacritty nvim)

install_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  echo "🛠 Instalando GNU Stow..."
  case "$(uname -s)" in
    Darwin)
      command -v brew >/dev/null 2>&1 || { echo "❌ Homebrew no está instalado."; exit 1; }
      brew install stow
      ;;
    Linux)
      if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y stow
      else
        echo "❌ No se encontró apt. Instala stow manualmente."
        exit 1
      fi
      ;;
    *)
      echo "❌ Sistema no soportado para instalación automática de stow."
      exit 1
      ;;
  esac
}

backup_target() {
  local rel="$1"
  local target="$HOME/$rel"
  local backup="$BACKUP_DIR/$rel"

  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$(dirname "$backup")"
    echo "📦 Backup: $target -> $backup"
    mv "$target" "$backup"
  fi
}

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "❌ No existe $DOTFILES_DIR"
  exit 1
fi

install_stow
mkdir -p "$BACKUP_DIR"

# Targets conocidos para evitar conflictos antes de stow
backup_target ".vimrc"
backup_target ".zshrc"
backup_target ".tmux.conf"
backup_target ".config/starship.toml"
backup_target ".config/alacritty/alacritty.toml"
backup_target ".config/nvim/init.lua"
backup_target ".config/nvim/lazy-lock.json"

echo "🚀 Aplicando symlinks con stow..."
for config in "${CONFIGS[@]}"; do
  stow -d "$DOTFILES_DIR" -t "$HOME" "$config"
done

echo "✅ Dotfiles configurados correctamente."
