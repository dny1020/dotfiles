# Dotfiles (Stow)

Configuración personal para macOS/Linux gestionada con GNU Stow.

## Contenido

- `zsh/.zshrc`
- `tmux/.tmux.conf`
- `vim/.vimrc`
- `starship/.config/starship.toml`
- `alacritty/.config/alacritty/alacritty.toml`
- `nvim/.config/nvim/init.lua`
- `nvim/.config/nvim/lazy-lock.json`
- `ssh/backup.tar.gpg`
- `packages/debian-manual.txt`

## SSH

- `ssh/backup.tar.gpg` contains encrypted `~/.ssh/config` and keys.
- Restore is handled by the Debian deploy script.
- No plaintext private keys are stored in the repo.

## Debian packages

- `packages/debian-manual.txt` captures the current `apt-mark showmanual` inventory.
- The Debian deploy script installs it automatically.

## Full Deploy

```bash
sudo bash setup_dotfiles.sh
```

That will:

- install Debian packages
- apply dotfiles via stow
- decrypt and restore `~/.ssh`
- set zsh as default shell

You will be prompted for the SSH bundle passphrase during deploy.

## Instalación

```bash
git clone git@github.com:dny1020/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x setup_dotfiles.sh setup_dotfiles_macos.sh setup_dotfiles_debian.sh
./setup_dotfiles.sh
```

También puedes ejecutar el script específico por sistema:

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
