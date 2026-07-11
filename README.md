# Dotfiles

Configuración minimalista de terminal/editor para **Debian (nativo o WSL)** y **macOS**, gestionada con **GNU Stow**. La shell (zsh) va sin frameworks; Neovim usa **lazy.nvim** con `lazy-lock.json` para reproducibilidad.

`alacritty`, `zsh`, `tmux` y `nvim` son universales (mismo archivo en los tres sistemas); `i3`, `dunst`, `rofi`, `picom`, `redshift` y `libinput-gestures` son solo para el escritorio Linux/i3.

## Contenido

- `nvim/.config/nvim/` — Neovim con lazy.nvim: LSP completo (mason + lspconfig + nvim-cmp), resaltado por treesitter (rama `main`, desactivado en archivos >512 KB), tema Dracula y statusline (lualine). Conserva los atajos del antiguo `.vimrc` (`<leader>`=espacio: `e` explorador, `g` grep, `w` guardar, `h` quitar resaltado) y añade los de LSP (`gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, …).
- IA local (Ollama, opcional — si no está, todo lo demás funciona igual):
  - **nvim**: ghost text estilo Copilot vía minuet-ai (`qwen2.5-coder:3b`, FIM). Aceptar `<A-y>`, una línea `<A-l>`, descartar `<A-e>`. Y **gen.nvim**: selecciona código y `<espacio>a` → menú (Explicar, Fix_Code, Review_Code, Chat…).
  - **zsh** (`ai.zsh`): `ai`, `explain`, `cmd`, `why`, `gitai`, y `Ctrl+X Ctrl+A` (escribe lo que quieres en el prompt y se reemplaza por el comando; nunca auto-ejecuta).
  - **tmux**: `Ctrl+a e` explica/diagnostica lo que hay en pantalla (popup).
- `zsh/.zshrc` — zsh puro: completado con menú, historial compartido, `alias vim='nvim'`, arranque automático de tmux. Prompt con **Starship** (`zsh/.config/starship.toml`); si no está instalado, cae a un prompt nativo con rama git (`vcs_info`).
- `zsh/.config/shell/` — `zsh-enhance.zsh` (autosuggestions + syntax-highlighting + fzf, rutas apt y brew), `tools.zsh` (reemplazos modernos como **alias** sobre el comando de siempre: `ls`→eza, `cd`→zoxide, `cat`→bat, `fd`, `tldr`) y `ai.zsh`.
- `tmux/` — prefijo `Ctrl+a`, divisiones que heredan el directorio, modo copia vi con portapapeles del sistema (pbcopy/xclip según SO), tema Gruvbox.
- `alacritty/` — universal; overrides por máquina (p. ej. tamaño de fuente) en `~/.config/alacritty/local.toml` (no versionado).
- `i3/`, `dunst/`, `rofi/`, `picom/`, `redshift/`, `libinput-gestures/` — escritorio Linux: i3 + barra, OSD de volumen/brillo/batería (`osd.sh`), notificaciones, launcher, compositor, luz nocturna y gestos del touchpad.
- `packages.txt` — paquetes apt (Debian/WSL). En macOS los instala `setup_macos.sh` con brew.

## Instalación

```bash
git clone <repo> ~/dotfiles && cd ~/dotfiles

sudo bash setup_debian.sh   # Debian/WSL: apt + Neovim + stow + zsh por defecto
bash setup_macos.sh         # macOS: brew + stow + zsh por defecto
```

`setup_debian.sh` instala los paquetes de `packages.txt`, añade los repos externos
necesarios (Docker, HashiCorp) e instala **Neovim** release oficial en `~/.local`
(apt en trixie solo trae 0.10.4 y el LSP moderno requiere 0.11+). Tras stow,
sincroniza los plugins en headless.

> El prompt usa iconos de Nerd Font: instala una (JetBrainsMono NF) o quítalos en `starship.toml`.

## Local (no versionado)

- Secretos: `~/.zsh_secrets`
- Ajustes por máquina: `~/.zshrc.local` (aliases/vars que solo aplican a un equipo)
- Alacritty por máquina: `~/.config/alacritty/local.toml`
