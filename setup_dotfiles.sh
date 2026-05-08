#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

case "$OS" in
  Darwin)
    exec bash "$SCRIPT_DIR/setup_dotfiles_macos.sh"
    ;;
  Linux)
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      exec bash "$SCRIPT_DIR/setup_dotfiles_debian.sh"
    fi
    exec sudo bash "$SCRIPT_DIR/setup_dotfiles_debian.sh"
    ;;
  *)
    echo "Unsupported OS: $OS"
    echo "Use setup_dotfiles_macos.sh on macOS or setup_dotfiles_debian.sh on Debian/Linux."
    exit 1
    ;;
esac
