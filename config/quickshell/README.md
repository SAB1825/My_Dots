# Quickshell

Desktop shell for this Hyprland configuration, with a status bar, launcher,
notifications, lock screen, and system control panels.

## Layout

| Path | Purpose |
| --- | --- |
| `shell.qml` | Shell entry point and global shortcuts |
| `bar/`, `panels/`, `overlays/` | Desktop interface components |
| `design/`, `reusables/` | Theme, animations, shaders, and shared controls |
| `services/` | System integrations and application state |
| `lang/` | Translation dictionaries |
| `src/islandd/` | Rust system helper |
| `config/`, `bin/` | Integration templates and helper scripts |
| `generated/` | Ignored local output, including palettes and showcase captures |

## Setup and launch

Keep this directory at `~/.config/quickshell`, normally through the dotfiles
repository's configuration links. Setup expects the neighboring Hyprland and
Kitty configurations from this repository.

```sh
python3 setup.py --help
python3 setup.py
./start.sh
```

Setup checks for Cargo, Rust, Matugen, Quickshell (`qs`), ImageMagick (`magick`),
`jq`, `hyprlock`, `notify-send`, and `luac`. It builds the Rust helper, installs
integration files, generates colors and sounds, and records changed-file backups
under `backups/`. Review the script before running it on another machine: it writes
to the user's configuration, local binaries, and state directories.

Use `python3 setup.py --activate` to also install shell shortcuts, reload Hyprland,
stop Dunst, and start Quickshell. Clipboard watching uses `wl-paste` and `cliphist`;
individual panels require their corresponding system utilities and services.

## Maintenance

Keep `qmldir` entries aligned with their component files. Shader `.frag.qsb` files
are runtime assets and belong in Git alongside their `.frag` sources; rebuild the
corresponding binary with Qt's `qsb` after changing a shader.

Build the helper without installing or activating the desktop integration:

```sh
cargo check --locked --manifest-path src/islandd/Cargo.toml --target-dir build
```

Local builds, generated palettes, backups, and showcase captures are excluded
from version control. Retain `Cargo.lock` for reproducible helper builds.

## Attribution

Adapted from [fedyaqq34356/hyprdots](https://github.com/fedyaqq34356/hyprdots).
The original revision is recorded in `upstream.json`; licensing is in `LICENSE`.
