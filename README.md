# Sabari’s dotfiles

Arch Linux · Niri · Kitty · Fish

A focused collection of desktop and terminal configuration.

| Directory | Configuration |
| --- | --- |
| [`config/nvim`](config/nvim/) | Neovim |
| [`config/tmux`](config/tmux/) | tmux, plugins, and wallpaper palette helper |
| [`config/kitty`](config/kitty/) | Kitty appearance and transparency |
| [`config/niri`](config/niri/) | Niri desktop and custom rules |
| [`config/fish`](config/fish/) | Fish prompt, functions, and shell integration |
| [`config/fastfetch`](config/fastfetch/) | Fastfetch layout and image |

The root [`.zshrc`](.zshrc) preserves the previous Zsh setup.
[`wallpapers/`](wallpapers/) contains the wallpaper collection.
Package lists and showcase assets are omitted for now.

## Setup

Back up existing configuration before copying or linking individual directories
from `config/` into `~/.config/`. Install the corresponding applications separately.

Initialize tmux plugin submodules after cloning:

```sh
git submodule update --init --recursive
```

tmux uses the backtick prefix. Some optional shortcuts need additional tools
such as sesh, fzf, gum, yazi, lazygit, and rmpc. The sessionizer shortcut expects
`~/scripts/tmux-sessionizer.sh`.

## Desktop integration

The current desktop uses [DarkShadow’s Shell](https://github.com/shadowww-dev/DarkShadowShell),
installed separately. Its Quickshell source and generated `rice/` settings are
not included here. Niri’s configuration and Fish integrations reference helpers
from that installation; these are personal configurations, not a standalone
installer for the shell.

DarkShadow’s Shell generates `config/niri/config.kdl`. Put persistent custom Niri
rules in `config/niri/user.kdl`. Use the shell’s settings for blur and generated
desktop settings; its generator can replace the main Niri file.

Kitty retains 92% background opacity. Niri provides background blur. The retained
Kitty configuration launches Zsh from `~/.config/zsh` when available, otherwise
Bash; set `shell fish` in Kitty if you want Fish instead. For Zsh, copy the root
`.zshrc` to `~/.config/zsh/.zshrc` or adjust Kitty’s shell command.

tmux follows `~/.config/rice/palette.json` from the installed shell, with the old
Matugen palette as a fallback. Built-in fallback colors work without either file.
