#!/bin/bash

# 📌 Nombre del repositorio en GitHub (ajústalo si es diferente)
REPO_NAME="dotfiles"

# 📌 Ruta destino
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"

echo "🔄 Renombrando directorio '$REPO_NAME' a '$DOTFILES_DIR'..."
mv "$HOME/$REPO_NAME" "$DOTFILES_DIR"

# 📌 Instalar stow si no está presente
if ! command -v stow &> /dev/null; then
    echo "🛠 Instalando GNU Stow..."
    sudo apt update && sudo apt install -y stow  # Debian/WSL
    # brew install stow  # MacOS (Descomentar si estás en Mac)
fi

# 📌 Crear directorio de respaldo
mkdir -p "$BACKUP_DIR"

# 📌 Archivos que queremos gestionar con Stow
CONFIGS=("vim" "zsh" "tmux")

echo "🚀 Creando enlaces simbólicos con Stow..."
for config in "${CONFIGS[@]}"; do
    # Verifica si hay archivos preexistentes y muévelos a backup
    for file in $(ls "$DOTFILES_DIR/$config"); do
        if [ -e "$HOME/.$file" ] && [ ! -L "$HOME/.$file" ]; then
            echo "📦 Moviendo $HOME/.$file a backup..."
            mv "$HOME/.$file" "$BACKUP_DIR/"
        fi
    done
    
    # Ejecutar Stow
    stow -d "$DOTFILES_DIR" -t "$HOME" "$config"
done

echo "✅ Dotfiles configurados correctamente con Stow."

