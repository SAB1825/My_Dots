# Shared themes

Super+C opens the theme picker. It uses the wallpaper filmstrip with landscape
previews, mouse wheel/drag, Left/Right keys, arrow buttons, search and Enter.
Click a neighboring card to select it, then click it again to apply.
The active theme is marked with a check and selected when opening the picker.
The bar's palette button opens the same picker.

Choices: Catppuccin Mocha, Monochrome, Gruvbox Dark, Nord, Dynamic.
Monochrome is selected initially. All choices currently use dark backgrounds.

Dynamic uses Matugen to extract colors from the current awww wallpaper. The
wallpaper picker updates all exports immediately when Dynamic is active.
External awww wallpaper changes are detected every 15 seconds while in Dynamic.
Presets retain their palette when the wallpaper changes. The Dynamic preview
uses a cached palette from the actual wallpaper, not a fixed example.

## Targets

- Quickshell: every bar, panel, launcher and picker reads the shared palette.
- Kitty: include at the end of kitty.conf updates UI colors and all 16 ANSI
  colors; existing Kitty processes receive SIGUSR1 to reload. Font, padding,
  opacity (0.75) and blur settings are preserved.
- GTK3: two generated themes, Quickshell-A and Quickshell-B, alternate to
  trigger reloads. Both use Adwaita's base styles and generated color overrides.
  gtk-theme is saved through gsettings and GTK settings.ini.
- GTK4: generated theme plus user stylesheet import. Applications that cache
  styles, particularly libadwaita applications, may need reopening. App-specific
  accent handling can differ.
- Brave: brave-flags.conf selects GTK3. Open Settings → Appearance and choose
  Use GTK once. The theme picker links to this page. Restart Brave once after
  setup so the launch flag takes effect. Browser profiles are not edited.
  Website content is controlled by websites; GTK does not recolor web pages.
- Hyprland: generated Lua changes active/inactive border colors and shadows.
  The appearance module loads it on startup/reload and the theme engine applies
  it live through hyprctl eval. Existing zero-width borders remain zero-width;
  geometry, window rules, opacity and blur are unchanged.
- Neovim: a standalone colorscheme is generated with 48 highlight groups,
  Tree-sitter groups, diagnostics and 16 terminal colors. No Neovim config,
  plugins, runtimepath or installation is changed.

Generated Neovim file:
`~/.config/quickshell/minimal/generated/current/nvim/colors/quickshell.lua`

For later use, add generated/current/nvim to Neovim's runtimepath and select
`colorscheme quickshell`. It will pick up the last generated theme on load.
Existing editor sessions do not auto-refresh; reload the colorscheme when needed.

## Files and commands

Theming lives in theming.py, with shared semantic roles for backgrounds, text,
accents, on-accent text and syntax/terminal colors. Theme.qml watches
`$XDG_STATE_HOME/quickshell/minimal/theme.json` (default ~/.local/state).
The file stores theme selection, palette, source wallpaper and revision.

All application files are staged in generated/generations/<revision>, then
`generated/current` is switched atomically to that directory. The palette state
is committed after exports. Failed writes restore the prior pointer and GTK
settings; failed extraction retains the previous palette. Failed live refreshes
are reported separately from successfully saved colors. Eight generations are kept.
Concurrent theme and wallpaper operations are serialized by a file lock.

```sh
qs -c minimal ipc call shell themes
python3 ~/.config/quickshell/minimal/backend.py theme-apply nord
python3 ~/.config/quickshell/minimal/backend.py theme-apply monochrome
python3 ~/.config/quickshell/minimal/backend.py theme-apply dynamic
python3 ~/.config/quickshell/minimal/backend.py theme-refresh
```

Initial files were backed up under backups/themes-20261105-172436, retaining
their paths relative to ~/.config. The integration uses small includes and
separate generated files so your application settings remain editable.
Changing presets does not install packages or download theme code.

## Verification

- Unit tests cover preset exports, invalid input, extraction failure, simulated
  commit failure/rollback, GTK setting preservation, wallpaper mode behavior,
  sync behavior and generation retention.
- Real Matugen extraction validated with both local wallpapers.
- All panels loaded in an offscreen Quickshell harness; live palette file
  changes updated Theme.qml. Theme picker selection, filtering, Enter and
  keyboard/button navigation passed Qt tests.
- Kitty's own config parser validated the include and preserved 0.75 opacity.
- Generated Hyprland and Neovim files passed Lua syntax checks; Neovim output
  executed against a highlight API stub (Neovim is not installed).
- GTK3 parsed both generated theme files and the Adwaita import.
- Running Quickshell logs report successful reload; the initial Hyprland reload
  completed through the running shell. Brave/GTK appearance still requires a
  visual desktop check.
