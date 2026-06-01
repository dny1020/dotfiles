# Dotfiles

Configuración personal de terminal/editor para **macOS** y **Debian/WSL**, gestionada con **GNU Stow**.

## Incluye

- `zsh/.zshrc`
- `tmux/.tmux.conf`
- `nvim/.config/nvim/init.lua`
- `starship/.config/starship.toml`
- `alacritty/.config/alacritty/alacritty.toml`
- `git/.gitconfig`
- `ssh/.ssh/config` (solo configuración pública)

## Instalación rápida

```bash
git clone git@github.com:dny1020/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x setup_dotfiles.sh setup_dotfiles_macos.sh setup_dotfiles_debian.sh
./setup_dotfiles.sh
```

También puedes usar el script por sistema:

```bash
# macOS
bash setup_dotfiles_macos.sh

# Debian/Linux
sudo bash setup_dotfiles_debian.sh
```

## Debian: guardar/restaurar paquetes

```bash
apt-mark showmanual | sort > packages/apt-manual.txt
sudo apt update
sudo xargs -a packages/apt-manual.txt apt install -y
```

## SSH y secretos

- No se versionan claves privadas.
- Variables sensibles: `~/.zsh_secrets`
- Llaves SSH: `~/.ssh/`
- Backup cifrado opcional: `ssh/backup.tar.gpg`
