# Dotfiles

Configuración minimalista de terminal/editor para **Debian (nativo o WSL)** y **macOS**, gestionada con **GNU Stow**. La shell (zsh) va sin frameworks; Neovim usa **lazy.nvim** con `lazy-lock.json` para reproducibilidad.

`alacritty`, `zsh`, `tmux` y `nvim` son universales (mismo archivo en los tres sistemas); `i3`, `dunst`, `rofi`, `picom`, `redshift` y `libinput-gestures` son solo para el escritorio Linux/i3.

## Contenido

- `nvim/.config/nvim/` — Neovim con lazy.nvim: LSP completo (mason + lspconfig + nvim-cmp), resaltado por treesitter (rama `main`, desactivado en archivos >512 KB), tema Dracula y statusline (lualine). Conserva los atajos del antiguo `.vimrc` (`<leader>`=espacio: `e` explorador, `g` grep, `w` guardar, `h` quitar resaltado) y añade los de LSP (`gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, …).
- IA local (Ollama, opcional — si no está, todo lo demás funciona igual):
  - **nvim**: ghost text estilo Copilot vía minuet-ai (`qwen2.5-coder:3b`, FIM). Aceptar `<A-y>`, una línea `<A-l>`, descartar `<A-e>`. Y **gen.nvim**: selecciona código y `<espacio>a` → menú (Explicar, Fix_Code, Review_Code, Chat…).
  - **zsh** (`ai.zsh`): `ai`, `explain`, `cmd`, `why`, `gitai`, y `Ctrl+X Ctrl+A` (escribe lo que quieres en el prompt y se reemplaza por el comando; nunca auto-ejecuta).
  - **tmux**: `Ctrl+a e` explica/diagnostica lo que hay en pantalla (popup).
- `zsh/.zshrc` — zsh puro: completado con menú, historial compartido, `alias vim='nvim'`, arranque automático de tmux, carga de **nvm** (`~/.nvm`, necesario para `pi`, ver abajo). Prompt con **Starship** (`zsh/.config/starship.toml`); si no está instalado, cae a un prompt nativo con rama git (`vcs_info`).
- `zsh/.config/shell/` — `zsh-enhance.zsh` (autosuggestions + syntax-highlighting + fzf, rutas apt y brew), `tools.zsh` (reemplazos modernos como **alias** sobre el comando de siempre: `ls`→eza, `cd`→zoxide, `cat`→bat, `fd`, `tldr`) y `ai.zsh`.
- `tmux/` — prefijo `Ctrl+a`, divisiones que heredan el directorio, modo copia vi con portapapeles del sistema (pbcopy/xclip según SO), tema Gruvbox.
- `pi/` — agente de código **pi** (`@earendil-works/pi-coding-agent`) corriendo 100% local contra **llama.cpp**, para tareas agénticas (lee/edita/escribe archivos, ejecuta bash) sin salir a internet. Solo Linux/systemd, opcional. Contiene:
  - `.config/systemd/user/llama-server.service` — arranca `llama-server` (puerto 8080) al iniciar sesión, sirviendo **Qwen3-4B** (`--alias qwen3-4b`, thinking off, ctx 16384). Se eligió Qwen3-4B porque, a diferencia de Qwen2.5-Coder-7B, emite `<tool_call>` bien formado (verificado con pruebas end-to-end); sin eso pi nunca ejecuta sus tools, solo pide el contenido de los archivos a mano.
  - `.local/bin/llama-serve` — arranque manual del servidor (alternativa al servicio); `.local/bin/pil` — wrapper de `pi --provider llama-server=... --model ...` para no repetir flags.
  - `.pi/agent/settings.json` — registra la extensión `pi-llama-cpp` (conecta pi al servidor) y `pi-ollama` (provider alterno, por si se quiere apuntar a Ollama puntualmente).
  - **No versionados** (binarios grandes/específicos de máquina): el propio `llama.cpp` compilado en `~/llama.cpp` (`cmake` ya está en `packages.txt`) y el modelo `~/models/Qwen3-4B-Q4_K_M.gguf` (~2.5GB, HF: `Qwen/Qwen3-4B-GGUF`). Tras el `stow`, compilar llama.cpp y bajar el modelo a mano; luego `systemctl --user enable --now llama-server`.
  - Uso: `pil` (sesión interactiva) o `pil -p "..." @archivo` (one-shot). En CPU va a ~4-9 tok/s: turnos agénticos tardan segundos-decenas de segundos, no instantáneo.
- `alacritty/` — universal; overrides por máquina (p. ej. tamaño de fuente) en `~/.config/alacritty/local.toml` (no versionado).
- `i3/`, `dunst/`, `rofi/`, `picom/`, `redshift/`, `libinput-gestures/` — escritorio Linux: i3 + barra, OSD de volumen/brillo/batería (`osd.sh`), notificaciones, launcher, compositor, luz nocturna y gestos del touchpad.
- `claude/` — configuración global de **Claude Code**, enlazada a `~/.claude/`. Solo lo declarativo: `agents/` (subagentes propios: ai, architect, backend, frontend, graph-ml, iac-expert, voip-expert, webrtc-media), `skills/` (build-react-feature, create-api, devops, etl-pipeline, graphify, linux-best-practices, sip-debug, terraform-deploy, write-tests), `AGENTS.md` y `CLAUDE.md`. **No versionado a propósito** (queda como archivo real en `~/.claude/`, nunca dentro del repo): `.credentials.json`, `settings.json` (trae un token del MCP `doction` en texto plano), `settings.local.json`, `projects/`, `sessions/`, `history.jsonl`, cache y demás estado en tiempo de ejecución. Antes vivía en un repo aparte (`dny1020/claude`); se centralizó aquí y se eliminó el `.git` anidado.
- `templates/` — scaffolding de proyectos (`new.sh` + plantillas jinja: api, etl, frontend, webservice, agentic, chatbot, voicebot, robot), enlazado a `~/templates/`.
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
