# Dotfiles

Configuración para Debian nativo y Debian WSL con GNU Stow: zsh, Neovim,
terminal y Claude Code. Escritorio i3 en Debian nativo e IA local con
llama.cpp opcional.

## Ramas e instalación

- `debian_nativo`: laptop con escritorio i3.
- `debian_wsl`: Debian dentro de Windows, sin instalar ni enlazar el escritorio.

```bash
# En WSL, cambia el nombre de rama por debian_wsl.
git clone --branch debian_nativo <repo> ~/dotfiles
cd ~/dotfiles
sudo bash setup_debian.sh
```

El instalador detecta WSL y comprueba que la rama corresponda al entorno.
Instala paquetes sin recomendaciones de apt, enlaza la configuración y deja
zsh como shell. Neovim se descarga del release oficial en `~/.local/nvim`;
sus plugins se sincronizan con `lazy-lock.json`.

| Lista | Cuándo se instala |
|---|---|
| `packages.txt` | Siempre: terminal, desarrollo y compilación de llama.cpp |
| `packages_debian_nativo.txt` | Solo nativo: utilidades de escritorio |
| `packages_extras.txt` | Con `--with-extras`: infraestructura, depuración y PHP |

```bash
sudo bash setup_debian.sh --with-extras
```

Los extras incluyen Docker, Ansible, AWS CLI, Terraform, GDB y Valgrind.
Los repos de Docker y HashiCorp solo se añaden con los extras. No se instala
LaTeX ni se eliminan paquetes existentes.

En cada equipo, trabaja y sube cambios en su rama. Usa `git pull --ff-only`
antes de editar y `git push` después de guardar los commits. Comparte cambios
puntuales con `git cherry-pick <commit>` para evitar mezclar ajustes de equipos.

## Configuración

| Paquetes de Stow | Función | Entorno |
|---|---|---|
| `zsh`, `tmux`, `herdr` | Shell y multiplexores; herdr arranca si está disponible | Ambos |
| `nvim` | Editor, LSP, búsqueda, formato y autocompletado | Ambos |
| `claude` | Instrucciones, agentes, skills y settings de Claude Code | Ambos |
| `llama` | Servicio de usuario `llama-server` | Ambos |
| `tealdeer`, `scripts` | tldr y comando `verify` | Ambos |
| `alacritty`, `i3`, `autorandr` | Terminal, gestor de ventanas y monitores | Nativo |
| `dunst`, `rofi`, `picom`, `gtk`, `xresources` | Notificaciones, launcher y apariencia Gruvbox | Nativo |
| `pipewire`, `redshift`, `libinput-gestures` | Audio, luz nocturna y gestos | Nativo |
| `bin`, `templates` | Scripts de escritorio y plantillas | Nativo |

Los binarios de herdr y llama.cpp se instalan aparte. La lista nativa todavía
no incluye todas las dependencias del escritorio: i3, dunst, rofi, picom,
redshift, playerctl, wireplumber y papirus-icon-theme deben estar instalados.
El instalador no retira enlaces de escritorio aplicados antes en WSL.

El prompt usa Nerd Font. Alacritty admite ajustes por equipo en `local.toml`.
En i3, `Super+p` aplica el perfil de monitores y `Super+Shift+x` bloquea la sesión.
En WSL el portapapeles usa `clip.exe`.

## llama.cpp

Se conserva el servicio en `llama/.config/systemd/user/llama-server.service`.
Espera el binario en `~/llama.cpp/build/bin/llama-server` y el modelo en
`~/models/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf`. El instalador no descarga
modelos ni activa el servidor automáticamente.

```bash
systemctl --user enable --now llama-server
```

El servicio usa el puerto 8082 para autocompletado y chat en Neovim y los
atajos `ai`, `explain`, `cmd`, `why` y `gitai` en zsh. Escucha en `127.0.0.1`;
si WSL necesita acceso por la IP de la VM, configura `LLAMA_BIND=0.0.0.0` en
`~/.config/llama-server.env`. Los clientes admiten `LLAMA_HOST`; los atajos
usan `AI_MODEL`. Los comandos generados quedan en el prompt para revisarlos.

## Ajustes locales

No se versionan secretos, credenciales, sesiones ni historial de agentes.
Claude puede usar `~/.claude/CLAUDE.local.md` para contexto de cada equipo.

| Archivo | Uso |
|---|---|
| `~/.zsh_secrets` | Secretos de shell |
| `~/.zshrc.local` | Alias y variables del equipo |
| `~/.config/alacritty/local.toml` | Ajustes de terminal |
| `~/.config/llama-server.env` | Variables del servidor local |
| `~/.gitconfig` | Identidad y preferencias de Git |

`git/.gitconfig` sirve como referencia y no se enlaza automáticamente.
Los archivos reales que el instalador necesita reemplazar se guardan en
`~/dotfiles_backup`.

## Comprobaciones

```bash
bash scripts/.local/bin/verify
```

Valida la sintaxis de shell, la selección de entorno y paquetes, y el formato
del diff. No instala paquetes ni modifica servicios.
