# Quickshell pill

Run `qs -c minimal -n` from Hyprland; startup already uses this configuration.
Super+Space or Super+R opens applications, Super+W opens wallpapers,
Super+C opens themes, and Super+B toggles the bar.
The idle bar sits below fullscreen windows; requested panels open above them.
Hover the pill to reveal controls. Click the clock for the calendar.
Escape or clicking outside closes panels.

- JetBrains Mono Nerd Font, workspaces, clock, always-visible battery percentage.
- Wi-Fi scan/connect/password/disconnect and Bluetooth scan/pair/connect/disconnect.
- Calendar month navigation, date selection and Today button.
- Fuzzy launcher with usage ranking, calculator and keyboard control.
- Landscape wallpaper filmstrip: scroll/drag/arrows to browse; click the selected
  card or press Enter to apply. Local images come from ~/Pictures/Wallpapers.
- Five shared themes: Catppuccin Mocha, Monochrome, Gruvbox Dark, Nord, Dynamic.
- MPRIS/CAVA playback and Sabari session/sound panels, including EQ, app volumes,
  output routing and microphone controls. See [sabari/README.md](sabari/README.md).

See [THEMES.md](THEMES.md) for application integrations, generated Neovim colors,
file locations, validation, backup and theme CLI details.

Connection panels support saved/open/PSK Wi-Fi. New enterprise profiles need
external configuration. Bluetooth devices requiring PIN entry need an external
pairing agent. Real network/Bluetooth actions require desktop verification.

The launcher uses fuzzy.js and calc.js from the user's Gakuseei/Ricelin ZIP;
the MIT license is preserved in lib/RICELIN-LICENSE. AppImage installation and
upstream flame animation are not included. Backups are under backups/.

## Code layout

- `shell.qml`: entry point; creates shared state and one bar per screen.
- `ShellState.qml`: panel state, IPC commands, audio, backend processes and refresh timers.
- `BarWindow.qml`: layer placement, sizing, workspace strip and bar controls.
- `PanelContent.qml`: panel header, page routing and page actions.
- `Launcher.qml`, `CalendarView.qml`, `ConnectionsView.qml`, `WallpaperStrip.qml`:
  individual feature views.
- `Theme.qml`, `Chip.qml`, `IslandButton.qml`, `ThemePreview.qml`: shared styling and UI.
- `backend.py`: system command adapter; `theming.py`: theme generation and application.
- `lib/`: launcher helpers and their license; `tests/`: theme regression tests.
- `sabari/`: adapted reference panels, shared controls and isolated audio state.
- `generated/`: generated theme artifacts; `backups/`: historical configuration copies.

Views receive the shared `ShellState` through a typed `controller` property.
Use its methods for wallpaper/theme changes rather than reaching into process IDs.
Keep backend paths relative to the configuration root via `Quickshell.shellPath()`.

Format QML with `/usr/lib/qt6/bin/qmlformat -i *.qml` from this directory.
Run regression tests with `python3 -m unittest discover -s tests -v`.
