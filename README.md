# Dotfiles

Configuración minimalista de terminal/editor para **Debian/WSL** y **macOS**, gestionada con **GNU Stow**. Sin frameworks ni gestores de plugins: solo lo que zsh, vim y las herramientas clásicas de Unix ya traen (el resaltado de sintaxis de zsh viene de los paquetes del sistema, apt/brew).

## Incluye

- `zsh/.zshrc` — zsh puro: prompt nativo con rama git (`vcs_info`), completado con colores y menú, historial compartido. Carga resaltado de sintaxis, autosugerencias y fzf desde rutas de apt o Homebrew si existen.
- `vim/.vimrc` — vim clásico sin plugins: colorscheme `habamax`, autocompletado automático nativo, netrw, `:find`, `:grep` con ripgrep.
- `git/.gitconfig`
- `alacritty/.config/alacritty/alacritty.toml` (macOS)
- `ssh/.ssh/config` (solo configuración pública) y `ssh/backup.tar.gpg` (config + claves cifradas con gpg; el script de Debian lo restaura pidiendo la passphrase)

> El prompt empieza con el logo de Debian de **Nerd Fonts**: usa una fuente NF (Cascadia Code NF en Windows Terminal, MesloLGS NF en Alacritty) o cambia `PROMPT_ICON` en `.zshrc`.

## Instalación

```bash
git clone git@github.com:dny1020/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup_dotfiles.sh   # detecta el sistema y llama al script correspondiente
```

O directamente por sistema:

```bash
bash setup_dotfiles_macos.sh          # macOS (Homebrew + stow)
sudo bash setup_dotfiles_debian.sh    # Debian/WSL (apt + stow + zsh por defecto)
```

## Paquetes

- `packages/packages.txt` — paquetes apt base para Debian/WSL (vim, git, ripgrep, fzf, zsh-syntax-highlighting, etc.)
- `install_packages_debian.sh` — instala además docker, terraform y node (repos externos):

```bash
sudo bash install_packages_debian.sh
```

## Secretos

- No se versionan claves privadas (ver `.gitignore`).
- Variables sensibles: `~/.zsh_secrets`
- Ajustes locales por máquina: `~/.zshrc.local`
