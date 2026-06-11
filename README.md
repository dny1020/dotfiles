# Dotfiles

Configuración minimalista de terminal/editor para **Debian/WSL** y **macOS**, gestionada con **GNU Stow**. Sin frameworks, sin plugins: solo lo que zsh, vim y las herramientas clásicas de Unix ya traen.

## Incluye

- `zsh/.zshrc` — zsh puro: prompt nativo con rama git (`vcs_info`), completado e historial integrados
- `vim/.vimrc` — vim clásico sin plugins: netrw, `:find`, `:grep` con ripgrep, completado nativo
- `git/.gitconfig`
- `alacritty/.config/alacritty/alacritty.toml` (macOS)
- `ssh/.ssh/config` (solo configuración pública)

## Instalación rápida

```bash
git clone git@github.com:dny1020/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup_dotfiles.sh
```

También puedes usar el script por sistema:

```bash
# macOS
bash setup_dotfiles_macos.sh

# Debian/Linux
sudo bash setup_dotfiles_debian.sh
```

## Paquetes

- `packages/packages.txt` — paquetes apt base (vim, git, ripgrep, fzf, etc.)
- `install_packages_debian.sh` — instala además docker, terraform, node y ansible (repos externos)

```bash
sudo bash install_packages_debian.sh
```

## SSH y secretos

- No se versionan claves privadas.
- Variables sensibles: `~/.zsh_secrets`
- Ajustes locales de zsh: `~/.zshrc.local`
- Backup cifrado opcional: `ssh/backup.tar.gpg`
