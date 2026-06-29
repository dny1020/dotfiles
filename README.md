# Dotfiles

Configuración minimalista de terminal/editor para **Debian/WSL** y **macOS**, gestionada con **GNU Stow**. La shell (zsh) va sin frameworks; Neovim usa **lazy.nvim** con `lazy-lock.json` para reproducibilidad.

## Contenido

- `nvim/.config/nvim/` — Neovim con lazy.nvim: LSP completo (mason + lspconfig + nvim-cmp), resaltado por treesitter, tema Dracula y statusline (lualine). Conserva los mismos atajos del antiguo `.vimrc` (`<leader>`=espacio: `e` explorador, `g` grep, `w` guardar, `h` quitar resaltado) y añade los de LSP (`gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, …).
- Autocompletado con IA local estilo Copilot (ghost text inline) vía **minuet-ai.nvim** + **Ollama** (`qwen2.5-coder:3b`, FIM). Aceptar: `<Tab>` o `<A-y>` (toda la sugerencia), `<A-l>` (una línea); ciclar: `<A-]>`/`<A-[>`; descartar: `<A-e>`. Requiere `ollama serve` con el modelo descargado (`ollama pull qwen2.5-coder:3b`); si Ollama no está, el resto de nvim funciona igual.
- `zsh/.zshrc` — zsh puro: completado con menú, historial compartido, `alias vim='nvim'`. Prompt con **Starship** (`zsh/.config/starship.toml`: 2 líneas, colores suaves, iconos Nerd Font discretos, muestra dir/git y python/terraform/aws/k8s solo si existen); si Starship no está instalado, cae a un prompt nativo con rama git (`vcs_info`).
- `zsh/.config/shell/` (versionado) — `zsh-enhance.zsh` (autosuggestions + syntax-highlighting + fzf + ↑/↓ por prefijo), `tools.zsh` (reemplazos modernos como **alias** sobre el comando de siempre: `ls`→eza, `cd`→zoxide, `bat`/`fd`, `tldr`) y `ai.zsh` (copiloto local con Ollama: `ai`, `explain`, `cmd`, `why`, `gitai` con `qwen2.5-coder:3b`; los que generan comandos los dejan en el prompt para revisar, nunca auto-ejecutan).
- `alacritty/.config/alacritty/alacritty.toml` — Alacritty (solo macOS).
- `packages.txt` — paquetes apt instalados manualmente en Debian/WSL.

## Instalación

```bash
git clone <repo> ~/dotfiles && cd ~/dotfiles

sudo bash setup_debian.sh   # Debian/WSL: apt + Neovim + stow (nvim, zsh) + zsh por defecto
bash setup_macos.sh         # macOS: brew + stow (nvim, zsh, alacritty) + zsh por defecto
```

`setup_debian.sh` instala los paquetes de `packages.txt`, añade los repos externos
necesarios (Docker para buildx/compose, HashiCorp para terraform) e instala **Neovim
0.11+** (release oficial en `~/.local`, porque apt en trixie solo trae 0.10.4 y el LSP
moderno requiere 0.11+). Tras stow, sincroniza los plugins en headless; treesitter y los
servidores LSP terminan de instalarse al abrir `nvim` por primera vez.

> El prompt empieza con un icono de Nerd Font: usa una fuente NF o cambia el
> carácter en `zsh/.zshrc`.

## Local (no versionado)

- Secretos: `~/.zsh_secrets`
- Ajustes por máquina: `~/.zshrc.local`
