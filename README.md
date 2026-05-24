# Dotfiles (Stow)

Configuracion personal para macOS/Linux gestionada con GNU Stow.

## Contenido

- `zsh/.zshrc`
- `tmux/.tmux.conf`
- `vim/.vimrc`
- `starship/.config/starship.toml`
- `alacritty/.config/alacritty/alacritty.toml`
- `nvim/.config/nvim/init.lua`
- `nvim/.config/nvim/lazy-lock.json`
- `ssh/backup.tar.gpg`
- `ssh/.ssh/config`
- `git/.gitconfig`
- `packages/apt-manual.txt`

## SSH

- `ssh/backup.tar.gpg` contiene `~/.ssh/config` y llaves cifradas con GPG.
- El deploy de Debian restaura automaticamente.
- No se versionan llaves privadas en texto plano.

## WSL Debian

Este repo esta preparado para WSL Debian. Usa stow para instalar los symlinks.

### Paquetes

Guarda y restaura la lista de paquetes instalados manualmente (apt):

```bash
apt-mark showmanual | sort > packages/apt-manual.txt
sudo apt update
sudo xargs -a packages/apt-manual.txt apt install -y
```

### SSH y secretos

No se versionan claves privadas. Usa un archivo separado para secretos:

- `~/.zsh_secrets` para variables sensibles.
- `~/.ssh/` para llaves y config. Si necesitas versionar configuracion publica,
  usa `ssh/.ssh/config` y mantiene las llaves privadas fuera del repo.

## Instalacion

```bash
git clone git@github.com:dny1020/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x setup_dotfiles.sh setup_dotfiles_macos.sh setup_dotfiles_debian.sh
./setup_dotfiles.sh
```

Tambien puedes ejecutar el script especifico por sistema:

```bash
# macOS
bash setup_dotfiles_macos.sh

# Debian/Linux
sudo bash setup_dotfiles_debian.sh
```

## Remoto GitHub

```bash
git remote add github git@github.com:dny1020/dotfiles.git
git push github main
```
