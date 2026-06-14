#!/usr/bin/env bash
# Despliegue para Debian/WSL: paquetes (packages.txt) + dotfiles vim y zsh.
# Uso: sudo bash setup_debian.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: ejecuta con sudo: sudo bash $0"
  exit 1
fi

# Usuario real cuando se invoca con sudo
if [[ -n "${SUDO_USER:-}" ]]; then
  REAL_USER="$SUDO_USER"
  REAL_HOME="$(eval echo "~$SUDO_USER")"
else
  REAL_USER="$USER"
  REAL_HOME="$HOME"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_LIST="$SCRIPT_DIR/packages.txt"
BACKUP_DIR="$REAL_HOME/dotfiles_backup"

as_user() { sudo -u "$REAL_USER" env HOME="$REAL_HOME" "$@"; }
step()    { echo; echo "──> $*"; }
ok()      { echo "    [ok] $*"; }
skip()    { echo "    [skip] $*"; }
need()    { grep -qxF "$1" "$PACKAGE_LIST"; }

backup_target() {
  local rel="$1" target="$REAL_HOME/$1" backup="$BACKUP_DIR/$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$(dirname "$backup")"
    chown "$REAL_USER":"$REAL_USER" "$(dirname "$backup")"
    mv "$target" "$backup"
    ok "respaldado $rel"
  fi
}

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

# ── 1. Repos externos (solo si hacen falta y no existen) ──────────────────────
if need docker.io && [[ ! -f /etc/apt/sources.list.d/docker.sources ]]; then
  step "Añadiendo repo de Docker (buildx/compose)"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $CODENAME
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  ok "repo docker añadido"
fi

if need terraform && [[ ! -f /etc/apt/sources.list.d/hashicorp.list ]]; then
  step "Añadiendo repo de HashiCorp (terraform)"
  install -m 0755 -d /usr/share/keyrings
  wget -qO /usr/share/keyrings/hashicorp-archive-keyring.gpg https://apt.releases.hashicorp.com/gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" \
    > /etc/apt/sources.list.d/hashicorp.list
  ok "repo hashicorp añadido"
fi

# ── 2. Paquetes ───────────────────────────────────────────────────────────────
step "Instalando paquetes"
apt-get update -qq
apt-get install -y $(grep -vE '^\s*(#|$)' "$PACKAGE_LIST" | xargs)
ok "paquetes instalados"

# ── 3. Dotfiles con stow ──────────────────────────────────────────────────────
step "Aplicando dotfiles con stow"
mkdir -p "$BACKUP_DIR"
chown "$REAL_USER":"$REAL_USER" "$BACKUP_DIR"
backup_target ".vimrc"
backup_target ".zshrc"
for pkg in vim zsh; do
  as_user stow -d "$SCRIPT_DIR" -t "$REAL_HOME" "$pkg"
  ok "stow $pkg"
done

# ── 4. zsh como shell por defecto ─────────────────────────────────────────────
step "Estableciendo zsh como shell por defecto"
ZSH_BIN="$(command -v zsh)"
if [[ "$(getent passwd "$REAL_USER" | cut -d: -f7)" != "$ZSH_BIN" ]]; then
  chsh -s "$ZSH_BIN" "$REAL_USER"
  ok "shell cambiado a $ZSH_BIN"
else
  skip "zsh ya es el shell por defecto"
fi

echo
echo "Listo. Abre una nueva shell o ejecuta: exec zsh"
