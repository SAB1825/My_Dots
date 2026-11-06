# Sabari’s dotfiles

Hyprland, Quickshell, Neovim, and Zsh configuration for Arch Linux.

```text
config/
  hypr/                 Hyprland configuration and Lua modules
  nvim/                 Neovim configuration and plugin lockfile
  quickshell/minimal/   Bar, launcher, themes, and panels
.zshrc                  Zsh configuration
packages/               Installed package inventories
```

## Setup

```sh
git clone git@github.com:SAB1825/My_Dots.git ~/dotfiles
cd ~/dotfiles
```

The repository contains copies of the configs. Back up and move aside your existing
`~/.config/hypr`, `~/.config/quickshell`, `~/.config/nvim`, and `~/.zshrc` before creating these links:

```sh
mkdir -p "$HOME/.config"
ln -s "$HOME/dotfiles/config/hypr" "$HOME/.config/hypr"
ln -s "$HOME/dotfiles/config/quickshell" "$HOME/.config/quickshell"
ln -s "$HOME/dotfiles/config/nvim" "$HOME/.config/nvim"
ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
```

After linking, edits to your active configs also appear in this repository.

## Dependencies

`packages/official.txt` and `packages/aur.txt` are machine inventories, not minimal
requirements. Review them before installing packages.

Hyprland uses its Lua API and needs a compatible build. Adjust monitor settings in
`config/hypr/modules/display.lua` for your machine.

See [Quickshell setup](config/quickshell/minimal/README.md) and
[theme setup](config/quickshell/minimal/THEMES.md). Generated themes, local state,
wallpapers, caches, and historical backups are excluded.

See [Neovim setup](config/nvim/README.md) for editor dependencies and keymaps.

The `panels/` panel components are adapted from Ricelin, rather than a separate
Ricelin configuration. Upstream MIT licenses and attribution are retained.

## Update

```sh
cd ~/dotfiles
git status
git add config .zshrc
git diff --cached --check
git diff --cached
git commit -m "Update configs"
git push
```

Keep secrets in untracked local files and review staged changes before committing.
