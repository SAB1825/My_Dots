<h1 align="center">Sabari’s dotfiles</h1>

<p align="center">Arch Linux · Hyprland · Quickshell</p>

<p align="center">
  <a href="https://youtu.be/_7CwLcyudi0">
    <img src="https://img.youtube.com/vi/_7CwLcyudi0/hqdefault.jpg" alt="Watch the desktop showcase on YouTube" width="720">
  </a>
</p>

<p align="center"><a href="https://youtu.be/_7CwLcyudi0">▶ Watch the showcase</a></p>

## The setup

| Component | Tools |
| --- | --- |
| Desktop | Hyprland, Quickshell |
| Terminal & shell | Kitty, Zsh |
| Editor | Neovim, Code OSS |
| System tools | Fastfetch, btop, Cava |
| Theming | GTK, Matugen |

Quickshell brings together the bar, app launcher, wallpaper picker, Bluetooth
controls, calendar, and timer.

## Explore

- [`config/`](config/) — application and desktop configuration.
- [`packages/`](packages/) — official and AUR package lists.
- [`wallpapers/`](wallpapers/) — the wallpaper collection.

<details>
<summary>Setup notes</summary>

Configuration lives under `config/`, linked from the matching path in `~/.config`.
Code OSS links only `User/settings.json`; `session/theme-sync` links individual
templates and helpers so session state stays outside the repository.
Link `session/brave-theme` as a directory to enable the Matugen Brave theme.
Tmux plugins are Git submodules; run `git submodule update --init --recursive`
after cloning to populate them. Original
files replaced during this import are retained in `~/.config/dotfiles-backups/`.

`~/Pictures/Wallpapers` points to this repository's `wallpapers/` directory. Images
added through either path appear in the repository automatically; commit and push
them to save them in Git. On a fresh setup, link it with
`ln -s "$(pwd)/wallpapers" ~/Pictures/Wallpapers` from the repository root, after
moving any existing wallpaper folder aside.

Wallpaper theme sources are in `config/session/theme-sync/`. Matugen writes
`generated.css` and `Wallpaper.colors` there at runtime; these palettes are
ignored by Git. On a fresh setup, generate the palette with Quickshell/Matugen
before starting GTK applications. GTK settings also use the local Quickshell-A/B
theme wrappers, which must be installed under `~/.local/share/themes/`.

</details>

## Credits

Inspired by [fedyaqq34356/hyprdots](https://github.com/fedyaqq34356/hyprdots).
Quickshell panel components are adapted from that project.
