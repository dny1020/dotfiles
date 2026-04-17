# Dotfiles (Stow)

Configuración personal para macOS/Linux gestionada con GNU Stow.

## Contenido

- `zsh/.zshrc`
- `tmux/.tmux.conf`
- `vim/.vimrc`
- `starship/.config/starship.toml`
- `alacritty/.config/alacritty/alacritty.toml`
- `nvim/.config/nvim/init.lua`
- `nvim/.config/nvim/lazy-lock.json`

## Instalación

```bash
git clone git@github.com:dny1020/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x setup_dotfiles.sh
./setup_dotfiles.sh
```

## Remoto GitHub

```bash
git remote add github git@github.com:dny1020/dotfiles.git
git push github main
```
