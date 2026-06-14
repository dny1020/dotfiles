# Dotfiles

Configuración minimalista de terminal/editor para **Debian/WSL** y **macOS**, gestionada con **GNU Stow**. Sin frameworks ni gestores de plugins: solo zsh, vim y herramientas Unix clásicas.

## Contenido

- `vim/.vimrc` — vim sin plugins: sintaxis nativa, completado automático, netrw, `:grep` con ripgrep, undofile.
- `zsh/.zshrc` — zsh puro: prompt nativo con rama git (`vcs_info`), completado con menú, historial compartido.
- `alacritty/.config/alacritty/alacritty.toml` — Alacritty (solo macOS).
- `packages.txt` — paquetes apt instalados manualmente en Debian/WSL.

## Instalación

```bash
git clone <repo> ~/dotfiles && cd ~/dotfiles

sudo bash setup_debian.sh   # Debian/WSL: apt + stow (vim, zsh) + zsh por defecto
bash setup_macos.sh         # macOS: brew + stow (vim, zsh, alacritty) + zsh por defecto
```

`setup_debian.sh` instala los paquetes de `packages.txt` y añade los repos externos
necesarios (Docker para buildx/compose, HashiCorp para terraform).

> El prompt empieza con un icono de Nerd Font: usa una fuente NF o cambia el
> carácter en `zsh/.zshrc`.

## Local (no versionado)

- Secretos: `~/.zsh_secrets`
- Ajustes por máquina: `~/.zshrc.local`
