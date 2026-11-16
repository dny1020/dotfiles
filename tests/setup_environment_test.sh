#!/usr/bin/env bash
set -euo pipefail
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/setup_environment.sh"

select_environment '6.12.0-amd64' debian_nativo "$repo_dir"
[[ "$DOTFILES_ENV" == debian_nativo ]]
[[ ${#PACKAGE_LISTS[@]} == 2 ]]
for pkg in i3 autorandr pipewire gtk bin xresources; do
  [[ " ${STOW_PACKAGES[*]} " == *" $pkg "* ]]
done
for kernel in '6.6.87.2-microsoft-standard-WSL2' '4.4.0-Microsoft'; do
  select_environment "$kernel" debian_wsl "$repo_dir"
  [[ "$DOTFILES_ENV" == debian_wsl ]]
  [[ ${#PACKAGE_LISTS[@]} == 1 ]]
  for pkg in i3 autorandr alacritty dunst rofi picom gtk pipewire redshift libinput-gestures templates bin xresources; do
    [[ " ${STOW_PACKAGES[*]} " != *" $pkg "* ]]
  done
  for pkg in nvim zsh claude scripts; do
    [[ " ${STOW_PACKAGES[*]} " == *" $pkg "* ]]
  done
done

if select_environment '6.12.0-amd64' debian_wsl "$repo_dir" 2>/dev/null; then
  echo 'ERROR: permitió rama WSL en Debian nativo' >&2
  exit 1
fi
if select_environment '6.6.87-microsoft-standard-WSL2' debian_nativo "$repo_dir" 2>/dev/null; then
  echo 'ERROR: permitió rama nativa en WSL' >&2
  exit 1
fi
if grep -Eq '^(xclip|feh|autorandr|bc)$' "$repo_dir/packages.txt"; then
  echo 'ERROR: paquetes de escritorio en la lista compartida' >&2
  exit 1
fi
echo 'OK: perfiles nativo/WSL y bloqueo de ramas incorrectas'
