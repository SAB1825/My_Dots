# My Arch dotfiles

Hyprland, Quickshell, and Zsh configurations, organized as GNU Stow packages.

## Install

```sh
sudo pacman -S --needed git stow
git clone https://github.com/SAB1825/My_Dots.git ~/dotfiles
cd ~/dotfiles
stow --simulate --verbose --target="$HOME" hypr quickshell zsh
stow --target="$HOME" hypr quickshell zsh
```

Back up existing config files and move them aside before applying Stow links. Stow will report conflicts if they remain. This repository initially contains snapshots; existing live configs are unchanged until you replace them with links.

## Dependencies

`packages/official.txt` lists explicitly installed official packages; `packages/aur.txt` lists explicitly installed foreign packages. Review both before installing; these are machine inventories, not minimal requirements. AUR packages need separate review and installation.

Neovim configuration is intentionally excluded for now.

Hyprland configuration uses the Lua API and requires a compatible Hyprland build. Check monitor configuration in `hypr/.config/hypr/modules/display.lua` for your machine.

See [Quickshell setup](quickshell/.config/quickshell/minimal/README.md) and [theme setup](quickshell/.config/quickshell/minimal/THEMES.md). Generated themes, local state, wallpapers, caches, and historical backups are excluded. Generate a theme using the documented theme CLI after installation. Third-party Ricelin license files are preserved.

## Update

When the configs are linked with Stow, edit them normally, then:

```sh
cd ~/dotfiles
git status
git add hypr # choose the package you changed
git diff --cached --check
git diff --cached
git commit -m "feat(hypr): describe the change"
git push
```

Keep secrets in untracked local files and review staged changes before every commit.
