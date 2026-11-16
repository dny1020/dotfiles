#!/usr/bin/env bash
# Selección compartida por el instalador y sus pruebas; no modifica el sistema.
select_environment() {
  local kernel="$1" branch="$2" repo_dir="$3"
  DOTFILES_ENV=debian_nativo
  if [[ "${kernel,,}" == *microsoft* || "${kernel,,}" == *wsl* ]]; then
    DOTFILES_ENV=debian_wsl
  fi

  case "$branch" in
    debian_nativo|debian_wsl)
      if [[ "$branch" != "$DOTFILES_ENV" ]]; then
        echo "ERROR: entorno $DOTFILES_ENV con rama $branch. Usa git switch $DOTFILES_ENV." >&2
        return 1
      fi
      ;;
  esac

  PACKAGE_LISTS=("$repo_dir/packages.txt")
  STOW_PACKAGES=(nvim zsh tmux herdr pi opencode tealdeer claude scripts)
  if [[ "$DOTFILES_ENV" == debian_nativo ]]; then
    PACKAGE_LISTS+=("$repo_dir/packages_debian_nativo.txt")
    STOW_PACKAGES+=(alacritty i3 autorandr dunst rofi picom gtk pipewire redshift libinput-gestures templates bin xresources)
  fi
}
