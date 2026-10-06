# Dotfiles

Terminal y editor minimalistas para **Debian** (nativo o WSL) y **macOS**, gestionados con **GNU Stow**.
zsh sin frameworks, Neovim con lazy.nvim y `lazy-lock.json` para reproducibilidad, IA local opcional con llama.cpp.

## Instalación

```bash
git clone <repo> ~/dotfiles && cd ~/dotfiles

sudo bash setup_debian.sh   # Debian nativo o WSL
bash setup_macos.sh         # macOS
```

Ambos instalan paquetes, aplican stow y dejan zsh por defecto. En Debian los paquetes salen de `packages.txt`, se añaden los repos de Docker y HashiCorp, y **Neovim se instala desde el release oficial en `~/.local`**: trixie solo trae 0.10.4 y el LSP moderno pide 0.11+. En macOS todo va por brew. Al final se sincronizan los plugins de Neovim en headless.

El prompt usa Nerd Font: instala JetBrainsMono NF o quita los iconos de `zsh/.config/starship.toml`.

## Paquetes

| Paquete | Enlaza a | Contenido | Linux | macOS |
|---|---|---|:-:|:-:|
| `alacritty` | `~/.config/alacritty/` | Terminal. Overrides por máquina en `local.toml` | ✓ | ✓ |
| `bin` | `~/.bin/` (en `PATH`) | `vol-boost` (volumen 100%/150%, `$mod+u`), `lock` (i3lock con el wallpaper difuminado), `papirus-recolor` (carpetas Gruvbox sin sudo) | ✓ | |
| `claude` | `~/.claude/` | Config global de Claude Code (ver abajo) | ✓ | ✓ |
| `dunst` | `~/.config/dunst/` | Notificaciones | ✓ | |
| `git` | — | `.gitconfig` versionado pero **no enlazado** (ver abajo): identidad + merges con `nvimdiff`, `zdiff3` y `rerere` | | |
| `herdr` | `~/.config/herdr/` | Multiplexor por defecto (orientado a agentes), arranca solo desde `.zshrc`. Prefijo `C-a`, Gruvbox. Binario aparte en `~/.local/bin/herdr` | ✓ | ✓ |
| `gtk` | `~/.config/gtk-3.0/` | Adwaita-dark repintado a Gruvbox por CSS + iconos Papirus. Afecta a PCManFM y a los diálogos de Firefox | ✓ | |
| `i3` | `~/.config/i3/` | WM, `i3status` (Gruvbox) y `osd.sh` (volumen/brillo/batería) | ✓ | |
| `libinput-gestures` | `~/.config/` | Gestos del touchpad | ✓ | |
| `nvim` | `~/.config/nvim/` | lazy.nvim, LSP (mason + lspconfig + nvim-cmp; pyright + ruff, gopls, ansiblels…), format on save (conform: ruff, stylua/prettier si el proyecto los configura), explorador fijo a la izquierda (nvim-tree, `<espacio>e`), fzf-lua (`<espacio><espacio>` archivos, `<espacio>/` grep, `<espacio>s…` búsquedas, `<espacio>g…` git), which-key, lualine (barra inferior con ruta), dropbar (breadcrumbs arriba, `<espacio>;`), iconos (nvim-web-devicons), treesitter (rama `main`, off en archivos >512 KB), tema **gruvbox** (dark hard) | ✓ | ✓ |
| `opencode` | `~/.config/opencode/` | CLI sin proveedor/modelo fijo; hereda `~/.claude/AGENTS.md` y `skills-index.md` | ✓ | ✓ |
| `pi` | `~/.config/systemd/user/` | Unit de `llama-server` (ver abajo) | ✓ | |
| `picom` | `~/.config/picom.conf` | Compositor: sin tearing, sombras y blur `dual_kawase` | ✓ | |
| `pipewire` | `~/.config/pipewire/`, `~/.config/wireplumber/` | Cancelación de eco para llamadas y Bluetooth fijado en A2DP | ✓ | |
| `redshift` | `~/.config/redshift.conf` | Luz nocturna | ✓ | |
| `rofi` | `~/.config/rofi/` | Launcher | ✓ | |
| `tealdeer` | `~/.config/tealdeer/` | `tldr` con auto-update del cache | ✓ | ✓ |
| `tmux` | `~/.config/tmux/` | Alternativa a herdr (no arranca solo). Prefijo `C-a`, divisiones que heredan el directorio, copia vi con portapapeles del SO, Gruvbox | ✓ | ✓ |
| `xresources` | `~/.Xresources` | xterm/uxterm: fuente, 256 colores, Gruvbox | ✓ | |
| `zsh` | `~/.zshrc`, `~/.config/shell/`, `~/.config/starship.toml` | zsh puro: completado con menú, historial compartido, `vim`→`nvim`, arranque de herdr. Prompt Starship con iconos Nerd Font | ✓ | ✓ |

`setup_debian.sh` enlaza también los paquetes de escritorio en WSL, donde son inertes: no hay X.

## Tema

Todo lo visual comparte una paleta Gruvbox dark hard: fondo `#1d2021`, acento `#d79921`. La comparten i3bar, rofi, dunst, alacritty, tmux, xterm, GTK y el tema de VS Code, que viaja por Settings Sync y no por este repo.

El cristal esmerilado lo pone picom con `blur-background`: cada programa solo declara su propio alfa y picom difumina lo que quede detrás. Por eso lo tienen i3bar, rofi, dunst y alacritty, y **no** VS Code, Firefox ni PCManFM, que abren su ventana sin canal alfa. Forzarlo con una regla de opacidad de picom volvería translúcido también el texto, no solo el fondo.

En GTK los `@define-color` no bastan: desde 3.20 Adwaita compila sus colores como literales, así que `gtk/.config/gtk-3.0/gtk.css` lleva reglas explícitas por widget. `bin/.bin/papirus-recolor` genera `~/.local/share/icons/Papirus-Gruvbox` reapuntando las carpetas a las variantes amarillas que **ya trae** `papirus-icon-theme`, sin sudo ni descargas. No se versiona porque son enlaces a rutas del sistema; lo regenera `setup_debian.sh`.

Esta máquina no usa gestor de sesión: lightdm está enmascarado, `getty@tty1` autologuea y `.zprofile` lanza `startx`. El bloqueo manual es `$mod+Shift+x` → `~/.bin/lock`.

## Audio

PipeWire con compatibilidad PulseAudio; el PulseAudio clásico no está instalado. Firefox decodifica con el `ffmpeg` del sistema (sin él no hay H.264 ni AAC), Chrome trae los suyos compilados.

`99-echo-cancel.conf` carga `libpipewire-module-echo-cancel`, que Debian instala pero WirePlumber no activa. Va en `monitor.mode`, así que usa el monitor de la salida actual como referencia en vez de crear un sink virtual: solo hay que elegir la fuente **Micro (eco cancelado)**, y la salida puede cambiar libremente sin reconfigurar nada.

`51-bluetooth.conf` desactiva `bluetooth.autoswitch-to-headset-profile`. Bluetooth no puede dar estéreo de calidad y micrófono a la vez: A2DP es solo salida y al abrir el micro el auricular cae a HFP, mono y de banda estrecha. Con el autoswitch apagado los auriculares se quedan en A2DP y el micro sale del portátil, ya con cancelación de eco. **Contrapartida: el micrófono del auricular deja de ofrecerse**; para recuperarlo hay que cambiar el perfil a mano con `pactl set-card-profile`.

Bluetooth tiene SBC, aptX, LDAC, LC3 y Opus, pero **no AAC**: `fdk-aac` es non-free en Debian. Solo afecta a auriculares Apple, que caen a SBC.

`zsh/.config/shell/` son tres archivos: `tools.zsh` (reemplazos como **alias** sobre el comando de siempre — `ls`→eza, `cd`→zoxide, `cat`→bat, `fd`, `tldr`; en Debian resuelve `batcat`/`fdfind`), `ai.zsh` (copiloto local) y `zsh-enhance.zsh` (autosuggestions, syntax-highlighting y fzf; **debe cargarse el último**).

## IA local (opcional)

Sin llama.cpp todo lo demás funciona igual. Un único servidor para FIM y chat:

| Puerto | Modelo | Para qué | Unit |
|---|---|---|---|
| 8082 | `qwen2.5-coder-1.5b-instruct` | FIM/autocompletado en Neovim (minuet-ai; aceptar `<A-y>`, una línea `<A-l>`, descartar `<A-e>`), `gen.nvim` (`<espacio>a` sobre una selección) y los atajos de shell `ai`, `explain`, `cmd`, `why`, `gitai`, más `Ctrl+X Ctrl+A` | `llama-server.service` |

`qwen2.5-coder` **no hace tool-calling nativo** — emite la llamada como texto JSON en `content` — así que no sirve para agentes. Los atajos que generan comandos los dejan en el prompt con `print -z` para revisar: **nunca se auto-ejecutan**.

La unit se enlaza desde `pi/` y se activa con `systemctl --user enable --now llama-server`. Escucha solo en `127.0.0.1`: es un portátil que se conecta a wifis ajenas. Si otra máquina necesita `0.0.0.0` (WSL2, donde los clientes llegan por la IP de la VM), se pone `LLAMA_BIND=0.0.0.0` en `~/.config/llama-server.env`, no versionado; zsh y Neovim usan esa IP automáticamente en WSL. Cambia modelo o puerto de los atajos con `AI_MODEL` y `LLAMA_HOST`.

## Claude Code (`claude/`)

Solo lo declarativo: `AGENTS.md` (guías de ingeniería globales), `CLAUDE.md` (contexto personal), `skills-index.md` (lo lee opencode), `settings.json`, y:

- `skills/` — build-agentic-agent, build-backend, build-robot, devops, etl-pipeline, graphify, linux-best-practices, terraform-deploy, write-tests, más archify, codebase-discovery, excalidraw-skill, knowledge-curation y security-audit. `skills/synced/` (skills sincronizados desde claude.ai) es estado en tiempo de ejecución y no se versiona
- `agents/` — ai, architect, graph-ml, iac-expert, voip. Solo donde compensa un contexto aparte

`settings.json` **sí se versiona**: el token del MCP es la referencia `${env:DOCTION_MCP_TOKEN}`, no un literal, así que modelo, `effortLevel`, plugins y MCP se reproducen en una máquina nueva. Claude Code reescribe ese archivo al tocar `/config`, así que comprueba de vez en cuando que sigue siendo enlace: `ls -l ~/.claude/settings.json`.

Fuera del repo a propósito (archivo real en `~/.claude/`): `.credentials.json`, `settings.local.json`, `projects/`, `sessions/`, `history.jsonl` y demás estado en tiempo de ejecución.

## Local, no versionado

| Archivo | Para qué |
|---|---|
| `~/.zsh_secrets` | Secretos |
| `~/.zshrc.local` | Aliases y vars de una sola máquina |
| `~/.config/alacritty/local.toml` | Tamaño de fuente y demás por equipo |
| `~/.gitconfig` | Identidad de git (distinta según el equipo) |

`git/.gitconfig` está versionado pero **ningún script lo enlaza**, y lleva una identidad distinta de la que usa esta máquina. Es intencionado mientras la identidad varíe por equipo; si algún día se unifica, añade `git` a las listas de stow de ambos scripts.

## Cabos sueltos conocidos

- `packages.txt` no lista el stack de escritorio (i3, dunst, rofi, picom, redshift, playerctl, wireplumber, papirus-icon-theme): en un Debian limpio hay que instalarlo a mano. Sin resolver porque `setup_debian.sh` usa el mismo `packages.txt` en WSL, donde arrastrar X11 no tiene sentido.
- `.claudeignore.md` no lo lee nada — ni Claude Code ni ningún script del repo. Es vestigial.
